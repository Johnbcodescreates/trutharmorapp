import '../../models/ai_analysis.dart';

/// What the app sends for AI contextual analysis.
///
/// [text] and string [answers] are ALREADY REDACTED by the Redactor.
/// The app sends a category id — never a system prompt. Prompts live on the
/// secure backend.
class AnalysisRequest {
  const AnalysisRequest({
    required this.categoryId,
    required this.text,
    required this.answers,
    required this.ruleSignalIds,
    required this.urls,
    this.simpleMode = false,
  });

  final String categoryId;
  final String text;
  final Map<String, dynamic> answers;
  final List<String> ruleSignalIds;
  final List<String> urls;
  final bool simpleMode;

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'text': text,
        'answers': answers,
        'rule_signal_ids': ruleSignalIds,
        'urls': urls,
        'simple_mode': simpleMode,
      };
}

/// A friendly, user-facing failure (no internet, timeout, server busy…).
class AnalysisException implements Exception {
  const AnalysisException(this.userMessage);
  final String userMessage;
  @override
  String toString() => 'AnalysisException: $userMessage';
}

/// The AI half of the hybrid engine. Two implementations:
///  * [BackendAnalysisService] — PRODUCTION: calls the secure backend.
///  * [DemoAnalysisService]    — DEMO: offline mock, clearly labeled.
abstract class AnalysisService {
  bool get isDemo;
  Future<AiAnalysis> analyze(AnalysisRequest request);
}
