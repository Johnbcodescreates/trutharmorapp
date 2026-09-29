import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/ai_analysis.dart';
import 'analysis_service.dart';

/// PRODUCTION FUNCTIONALITY.
///
/// Sends the (redacted) request over HTTPS to the TruthArmor backend
/// (Firebase Cloud Function `analyze`). The backend holds the OpenAI API key
/// as a secret — the app never sees it.
class BackendAnalysisService implements AnalysisService {
  BackendAnalysisService({required this.endpoint, http.Client? client, this.timeout = const Duration(seconds: 30)})
      : _client = client ?? http.Client();

  final Uri endpoint;
  final http.Client _client;
  final Duration timeout;

  @override
  bool get isDemo => false;

  @override
  Future<AiAnalysis> analyze(AnalysisRequest request) async {
    if (endpoint.scheme != 'https' && endpoint.host != 'localhost' && endpoint.host != '10.0.2.2') {
      throw const AnalysisException('The analysis server must use a secure (https) connection.');
    }

    http.Response response;
    try {
      response = await _client
          .post(
            endpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const AnalysisException('The analysis took too long. Please check your connection and try again.');
    } on http.ClientException {
      throw const AnalysisException("We couldn't analyze this right now. Please check your connection and try again.");
    } catch (_) {
      throw const AnalysisException("We couldn't analyze this right now. Please check your connection and try again.");
    }

    if (response.statusCode == 429) {
      throw const AnalysisException('TruthArmor is busy right now. Please wait a minute and try again.');
    }
    if (response.statusCode != 200) {
      throw const AnalysisException('The AI analysis service is unavailable right now.');
    }

    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) throw const FormatException('Not an object');
      return AiAnalysis.fromJson(json);
    } catch (_) {
      throw const AnalysisException('We received an unexpected response from the analysis service.');
    }
  }
}
