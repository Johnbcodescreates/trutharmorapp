/// Risk-assessment data model. Pure Dart (no Flutter) so it is easy to test.

enum RiskLevel { low, caution, elevated, high }

extension RiskLevelX on RiskLevel {
  /// Score bands (0-100): 0-24 low, 25-49 caution, 50-74 elevated, 75-100 high.
  static RiskLevel fromScore(int score) {
    if (score >= 75) return RiskLevel.high;
    if (score >= 50) return RiskLevel.elevated;
    if (score >= 25) return RiskLevel.caution;
    return RiskLevel.low;
  }

  /// Never "SAFE" — green only means no major warning signs were found.
  String get label => switch (this) {
        RiskLevel.low => 'LOW RISK',
        RiskLevel.caution => 'CAUTION',
        RiskLevel.elevated => 'ELEVATED RISK',
        RiskLevel.high => 'HIGH RISK',
      };

  String get emoji => switch (this) {
        RiskLevel.low => '🟢',
        RiskLevel.caution => '🟡',
        RiskLevel.elevated => '🟠',
        RiskLevel.high => '🔴',
      };

  String get defaultHeadline => switch (this) {
        RiskLevel.low => 'No major warning signs detected.',
        RiskLevel.caution => 'This contains some patterns that deserve verification.',
        RiskLevel.elevated => 'Several patterns commonly associated with scams were identified.',
        RiskLevel.high => 'Multiple patterns commonly associated with scams were identified.',
      };
}

enum ConfidenceLevel { low, moderate, high }

extension ConfidenceLevelX on ConfidenceLevel {
  String get label => switch (this) {
        ConfidenceLevel.low => 'Low',
        ConfidenceLevel.moderate => 'Moderate',
        ConfidenceLevel.high => 'High',
      };
}

/// The transparent signal groups shown in "What we found".
enum SignalGroup { identity, financial, impersonation, urgency, source, behavioral, link, context }

extension SignalGroupX on SignalGroup {
  String get label => switch (this) {
        SignalGroup.identity => 'Identity / Personal Data',
        SignalGroup.financial => 'Financial',
        SignalGroup.impersonation => 'Impersonation',
        SignalGroup.urgency => 'Urgency / Pressure',
        SignalGroup.source => 'Source',
        SignalGroup.behavioral => 'Behavior',
        SignalGroup.link => 'Link / Website',
        SignalGroup.context => 'Context',
      };

  String get simpleLabel => switch (this) {
        SignalGroup.identity => 'Your private information',
        SignalGroup.financial => 'Your money',
        SignalGroup.impersonation => 'Pretending to be someone',
        SignalGroup.urgency => 'Rushing or scaring you',
        SignalGroup.source => 'Where it came from',
        SignalGroup.behavioral => 'How they are acting',
        SignalGroup.link => 'Links and websites',
        SignalGroup.context => 'Other details',
      };
}

/// Per-group level shown in the simplified breakdown.
enum GroupLevel { none, low, moderate, high }

extension GroupLevelX on GroupLevel {
  String get label => switch (this) {
        GroupLevel.none => 'None found',
        GroupLevel.low => 'LOW',
        GroupLevel.moderate => 'MODERATE',
        GroupLevel.high => 'HIGH',
      };
}

/// A known warning sign TruthArmor can detect. Weights are fixed here —
/// NOT chosen by the AI — which keeps scoring transparent and stable.
class SignalDefinition {
  const SignalDefinition({
    required this.id,
    required this.group,
    required this.weight,
    required this.reason,
    required this.simpleReason,
    this.action,
    this.simpleAction,
    this.onlyCategories,
    this.excludedCategories = const {},
  });

  final String id;
  final SignalGroup group;

  /// Points added to the 0-100 risk score.
  final int weight;

  /// "Why this was flagged" text (standard mode).
  final String reason;

  /// Same idea in plain, non-technical words (Simple Mode).
  final String simpleReason;

  /// Optional "What to do next" action this signal adds.
  final String? action;
  final String? simpleAction;

  /// If set, the signal only applies inside these category ids.
  final Set<String>? onlyCategories;
  final Set<String> excludedCategories;

  bool appliesTo(String categoryId) {
    if (excludedCategories.contains(categoryId)) return false;
    final only = onlyCategories;
    return only == null || only.contains(categoryId);
  }
}

/// Where a detected signal came from — shown for transparency.
enum SignalSource { answers, text, link, ai, reputation }

class DetectedSignal {
  const DetectedSignal({required this.definition, required this.source, this.evidence});

  final SignalDefinition definition;
  final SignalSource source;

  /// Short quote or explanation of what triggered it (may be null).
  final String? evidence;

  String get id => definition.id;
}

class GroupBreakdown {
  const GroupBreakdown({required this.group, required this.level, required this.points});
  final SignalGroup group;
  final GroupLevel level;
  final int points;
}

/// One line of "How was this calculated?".
class ScoreStep {
  const ScoreStep(this.label, this.value);
  final String label;
  final String value;
}

/// The complete TruthArmor assessment shown on the results screen.
class Assessment {
  const Assessment({
    required this.id,
    required this.createdAt,
    required this.categoryId,
    required this.title,
    required this.score,
    required this.level,
    required this.confidence,
    required this.headline,
    required this.summary,
    required this.reasons,
    required this.simpleReasons,
    required this.actions,
    required this.simpleActions,
    required this.breakdown,
    required this.signals,
    required this.scoreSteps,
    required this.aiUsed,
    required this.isDemoAi,
    this.aiUnavailableReason,
    this.additionalConcerns = const [],
    this.reassuringFactors = const [],
    this.redactionCount = 0,
    this.isDemoExample = false,
  });

  final String id;
  final DateTime createdAt;
  final String categoryId;

  /// Short, content-free title for history (e.g. "Job Opportunity check").
  final String title;
  final int score;
  final RiskLevel level;
  final ConfidenceLevel confidence;
  final String headline;
  final String summary;
  final List<String> reasons;
  final List<String> simpleReasons;
  final List<String> actions;
  final List<String> simpleActions;
  final List<GroupBreakdown> breakdown;
  final List<DetectedSignal> signals;
  final List<ScoreStep> scoreSteps;

  /// True when AI contextual analysis contributed to this result.
  final bool aiUsed;

  /// True when the DEMO (mock) AI service produced the AI part.
  final bool isDemoAi;
  final String? aiUnavailableReason;
  final List<String> additionalConcerns;
  final List<String> reassuringFactors;

  /// How many sensitive items were redacted before any AI call.
  final int redactionCount;
  final bool isDemoExample;
}

/// The standard disclaimer — shown on EVERY assessment.
const String kAssessmentDisclaimer =
    'This assessment is based on patterns, signals, and information provided by the user. '
    'It is not a guarantee that something is legitimate or fraudulent and may not be 100% accurate. '
    'Always verify important information through trusted, independent sources before taking action.';

const String kConfidenceExplanation =
    'Analysis confidence reflects how strongly the available information matches the patterns '
    'evaluated. It does not guarantee that the assessment is correct.';
