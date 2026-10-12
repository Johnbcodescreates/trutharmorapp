import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Friendly, user-facing transcription failure.
class TranscriptionException implements Exception {
  const TranscriptionException(this.userMessage);
  final String userMessage;
}

/// Turns a voice message into text so TruthArmor can check what it asks for.
///
/// It does NOT decide whether a voice is real or AI-generated — that can't be
/// done reliably. The scam is in the request, whoever (or whatever) is speaking.
abstract class TranscriptionService {
  /// False in DEMO MODE (no secure backend configured).
  bool get isAvailable;

  Future<String> transcribe(Uint8List audio, String mimeType);

  /// Audio types the backend (OpenAI speech-to-text) accepts.
  static const Map<String, String> mimeByExtension = {
    'mp3': 'audio/mpeg',
    'mpeg': 'audio/mpeg',
    'mpga': 'audio/mpeg',
    'm4a': 'audio/mp4',
    'wav': 'audio/wav',
    'mp4': 'video/mp4',
    'webm': 'audio/webm',
  };

  static const int maxBytes = 20 * 1024 * 1024;
}

/// DEMO MODE: transcription needs the secure backend.
class UnavailableTranscriptionService implements TranscriptionService {
  const UnavailableTranscriptionService();

  @override
  bool get isAvailable => false;

  @override
  Future<String> transcribe(Uint8List audio, String mimeType) => Future.error(
        const TranscriptionException(
          'Voice messages need the TruthArmor secure server, which is not set up in demo mode. '
          'Try the demo voicemail example instead.',
        ),
      );
}

/// PRODUCTION: sends the audio over HTTPS to the same `analyze` endpoint with
/// `"action": "transcribe"`. The OpenAI key stays on the server.
class BackendTranscriptionService implements TranscriptionService {
  BackendTranscriptionService({required this.endpoint, http.Client? client})
      : _client = client ?? http.Client();

  final Uri endpoint;
  final http.Client _client;

  @override
  bool get isAvailable => true;

  @override
  Future<String> transcribe(Uint8List audio, String mimeType) async {
    if (audio.isEmpty) throw const TranscriptionException('That file seems to be empty.');
    if (audio.length > TranscriptionService.maxBytes) {
      throw const TranscriptionException('This recording is too large. Please use a file under 20 MB.');
    }

    http.Response response;
    try {
      response = await _client
          .post(
            endpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'action': 'transcribe', 'audio_base64': base64Encode(audio), 'mime_type': mimeType}),
          )
          .timeout(const Duration(seconds: 120));
    } on TimeoutException {
      throw const TranscriptionException('Transcribing took too long. Please try a shorter recording.');
    } catch (_) {
      throw const TranscriptionException(
        "We couldn't reach the TruthArmor server. Please check your connection and try again.",
      );
    }

    if (response.statusCode == 429) {
      throw const TranscriptionException('TruthArmor is busy right now. Please wait a minute and try again.');
    }
    if (response.statusCode == 413) {
      throw const TranscriptionException('This recording is too large. Please use a file under 20 MB.');
    }
    if (response.statusCode == 400) {
      throw const TranscriptionException("We couldn't use this file. Try an MP3, M4A, or WAV recording.");
    }
    if (response.statusCode != 200) {
      throw const TranscriptionException('Transcription is unavailable right now. Please try again later.');
    }

    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final text = (json['text'] as String? ?? '').trim();
      if (text.isEmpty) {
        throw const TranscriptionException(
          "We couldn't hear any words in this recording. Try a clearer recording, or type what was said.",
        );
      }
      return text;
    } on TranscriptionException {
      rethrow;
    } catch (_) {
      throw const TranscriptionException('We received an unexpected response from the server.');
    }
  }
}
