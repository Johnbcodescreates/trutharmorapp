import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Friendly OCR failure.
class OcrException implements Exception {
  const OcrException(this.userMessage);
  final String userMessage;
}

/// On-device text recognition with Google ML Kit (Android + iOS).
///
/// The screenshot is processed ON THE PHONE. The image itself is never
/// uploaded; only the text the user reviews and approves is analyzed.
class OcrService {
  const OcrService();

  bool get isSupported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<String> extractText(String imagePath) async {
    if (!isSupported) {
      throw const OcrException(
        'Screenshot reading works on Android and iPhone. On this device, please paste the text instead.',
      );
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(imagePath));
      final text = result.text.trim();
      if (text.isEmpty) {
        throw const OcrException(
          "We couldn't find readable text in this image. Try a clearer screenshot, or paste the text instead.",
        );
      }
      return text;
    } on OcrException {
      rethrow;
    } catch (_) {
      throw const OcrException(
        "We couldn't read this image. It may be unsupported or unclear. Try another screenshot, or paste the text.",
      );
    } finally {
      await recognizer.close();
    }
  }
}
