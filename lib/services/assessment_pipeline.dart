import '../data/categories.dart';
import '../models/ai_analysis.dart';
import '../models/assessment_draft.dart';
import '../models/risk.dart';
import 'ai/analysis_service.dart';
import 'evidence_summary.dart';
import 'privacy/redactor.dart';
import 'risk/risk_scorer.dart';
import 'rules/rule_engine.dart';

/// Orchestrates one TruthArmor check:
///
///   user input ─► rule engine (on-device)
///              ─► redaction ─► AI service (backend or demo)
///              ─► risk scorer ─► Assessment
///
/// If the AI is unavailable, the user STILL gets a rule-based assessment
/// with a clear note — the app never just fails.
class AssessmentPipeline {
  const AssessmentPipeline({
    required this.ai,
    this.rules = const RuleEngine(),
    this.scorer = const RiskScorer(),
    this.redactor = const Redactor(),
  });

  final AnalysisService ai;
  final RuleEngine rules;
  final RiskScorer scorer;
  final Redactor redactor;

  bool get isDemo => ai.isDemo;

  Future<Assessment> run(AssessmentDraft draft, {bool simpleMode = false}) async {
    final category = Categories.byId(draft.categoryId);
    final text = draft.text.length > 8000 ? draft.text.substring(0, 8000) : draft.text;

    // 1) Deterministic rules (never leave the device).
    final ruleResult = rules.evaluate(category: category, text: text, answers: draft.answers);

    // 2) Redact before anything is sent off-device.
    final redactedText = redactor.redact(text);
    var redactionCount = redactedText.count;
    final safeAnswers = <String, dynamic>{};
    draft.answers.forEach((key, value) {
      if (value is String) {
        final r = redactor.redact(value);
        redactionCount += r.count;
        safeAnswers[key] = r.text;
      } else if (value is List) {
        safeAnswers[key] = value.whereType<String>().toList();
      }
    });

    // 3) AI contextual analysis (optional — failures are handled gracefully).
    AiAnalysis? aiResult;
    String? aiError;
    try {
      aiResult = await ai.analyze(AnalysisRequest(
        categoryId: category.id,
        text: redactedText.text,
        answers: safeAnswers,
        ruleSignalIds: ruleResult.signals.map((s) => s.id).toList(),
        urls: ruleResult.urls.map((u) => redactor.redact(u).text).toList(),
        simpleMode: simpleMode,
      ));
    } on AnalysisException catch (e) {
      aiError = '${e.userMessage} This result is based on TruthArmor\'s built-in safety rules only.';
    } catch (_) {
      aiError = 'AI analysis was unavailable. This result is based on TruthArmor\'s built-in safety rules only.';
    }

    // 4) Transparent scoring.
    final result = scorer.score(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      category: category,
      rules: ruleResult,
      ai: aiResult,
      answeredCount: draft.answeredCount,
      textLength: text.trim().length,
      aiUnavailableReason: aiError,
      redactionCount: redactionCount,
      isDemoExample: draft.isDemoExample,
    );

    final evidence = EvidenceSummary.build(
      category: category,
      assessment: result,
      urls: ruleResult.urls,
      ai: aiResult,
      source: draft.source,
      textLength: text.trim().length,
      answeredCount: draft.answeredCount,
    );

    return result.copyWith(
      // Use the simple AI summary in Simple Mode when one is available.
      summary: simpleMode && aiResult != null && aiResult.simpleSummary.isNotEmpty ? aiResult.simpleSummary : null,
      // Kept in memory only for highlighting — never saved or sent anywhere.
      checkedText: text,
      knownFacts: evidence.known,
      unknowns: evidence.unknown,
    );
  }
}
