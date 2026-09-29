import '../../data/categories.dart';
import '../../data/signal_catalog.dart';
import '../../models/ai_analysis.dart';
import '../../models/risk.dart';
import 'analysis_service.dart';

/// DEMO FUNCTIONALITY — NOT REAL AI.
///
/// Used automatically when no backend URL is configured, so the app can be
/// demonstrated offline. It writes a plain-language summary from the RULE
/// ENGINE's findings and does not add any new signals of its own. Every
/// result produced with it is labeled "Demo AI" on the results screen.
class DemoAnalysisService implements AnalysisService {
  const DemoAnalysisService({this.delay = const Duration(milliseconds: 900)});

  final Duration delay;

  @override
  bool get isDemo => true;

  @override
  Future<AiAnalysis> analyze(AnalysisRequest request) async {
    await Future<void>.delayed(delay);

    final category = Categories.byId(request.categoryId);
    final found = request.ruleSignalIds.map(signalById).whereType<SignalDefinition>().toList();
    final defs = found.length;
    final names = found.map((d) => d.reason.toLowerCase()).take(2).toList();

    final String summary;
    final String simple;
    if (defs == 0) {
      summary = 'No common scam patterns stood out in what you shared about this '
          '${category.shortTitle.toLowerCase()}. That does not guarantee it is legitimate.';
      simple = 'Nothing obvious stood out. It is still smart to double-check anything important.';
    } else if (defs <= 2) {
      summary = 'This ${category.shortTitle.toLowerCase()} contains some patterns that deserve verification, '
          'including: ${names.join('; ')}.';
      simple = 'A few things here are worth double-checking before you do anything.';
    } else {
      summary = 'This ${category.shortTitle.toLowerCase()} combines several patterns commonly associated with scams, '
          'including: ${names.join('; ')}.';
      simple = 'Several things here are common in scams. Please slow down and check with someone you trust.';
    }

    return AiAnalysis(
      summary: summary,
      simpleSummary: simple,
      signals: const [], // Demo mode never invents signals.
      riskEstimate: 0, // Ignored: demo results never adjust the score.
      isDemo: true,
      likelyCategory: request.categoryId,
      additionalConcerns: const [],
      reassuringFactors: const [],
    );
  }
}
