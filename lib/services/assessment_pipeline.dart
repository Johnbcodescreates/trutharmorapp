import '../data/categories.dart';
import '../models/ai_analysis.dart';
import '../models/assessment_draft.dart';
import '../models/risk.dart';
import 'ai/analysis_service.dart';
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

    // Use the simple AI summary in Simple Mode when one is available.
    if (simpleMode && aiResult != null && aiResult.simpleSummary.isNotEmpty) {
      return _withSummary(result, aiResult.simpleSummary);
    }
    return result;
  }

  Assessment _withSummary(Assessment a, String summary) => Assessment(
        id: a.id,
        createdAt: a.createdAt,
        categoryId: a.categoryId,
        title: a.title,
        score: a.score,
        level: a.level,
        confidence: a.confidence,
        headline: a.headline,
        summary: summary,
        reasons: a.reasons,
        simpleReasons: a.simpleReasons,
        actions: a.actions,
        simpleActions: a.simpleActions,
        breakdown: a.breakdown,
        signals: a.signals,
        scoreSteps: a.scoreSteps,
        aiUsed: a.aiUsed,
        isDemoAi: a.isDemoAi,
        aiUnavailableReason: a.aiUnavailableReason,
        additionalConcerns: a.additionalConcerns,
        reassuringFactors: a.reassuringFactors,
        redactionCount: a.redactionCount,
        isDemoExample: a.isDemoExample,
      );
}
