import 'dart:math' as math;

import '../../data/signal_catalog.dart';
import '../../models/ai_analysis.dart';
import '../../models/risk.dart';
import '../../models/scan_category.dart';
import '../rules/rule_engine.dart';

/// A combination of signals that is so strongly associated with scams that
/// the score can never drop below [floor] — no matter what the AI says.
class ComboRule {
  const ComboRule({required this.label, required this.floor, this.allOf = const {}, this.anyOf = const {}});
  final String label;
  final int floor;
  final Set<String> allOf;
  final Set<String> anyOf;

  bool matches(Set<String> ids) =>
      ids.containsAll(allOf) && (anyOf.isEmpty || anyOf.any(ids.contains));
}

const _moneyAsks = {'payment_requested', 'gift_cards', 'crypto_requested', 'wire_transfer'};

const List<ComboRule> kComboRules = [
  ComboRule(label: 'SSN and banking information both requested', allOf: {'ssn_requested', 'bank_info_requested'}, floor: 75),
  ComboRule(label: 'SSN requested together with a payment', allOf: {'ssn_requested', 'payment_requested'}, floor: 75),
  ComboRule(label: 'Gift-card payment demanded', allOf: {'gift_cards'}, floor: 60),
  ComboRule(label: 'Gift cards demanded by a claimed agency or bank', allOf: {'gift_cards'}, anyOf: {'government_impersonation', 'bank_impersonation'}, floor: 85),
  ComboRule(label: 'Verification code requested', allOf: {'verification_code_requested'}, floor: 55),
  ComboRule(label: 'Verification code requested by a claimed bank', allOf: {'verification_code_requested', 'bank_impersonation'}, floor: 80),
  ComboRule(label: 'Password requested', allOf: {'password_requested'}, floor: 50),
  ComboRule(label: 'Arrest threat combined with a demand for money', allOf: {'arrest_threat'}, anyOf: _moneyAsks, floor: 85),
  ComboRule(label: 'Cryptocurrency demanded by a claimed agency', allOf: {'crypto_requested', 'government_impersonation'}, floor: 85),
  ComboRule(label: 'Link flagged by a security reputation service', allOf: {'known_malicious_url'}, floor: 80),
  ComboRule(label: 'Look-alike website', allOf: {'lookalike_domain'}, floor: 50),
  ComboRule(label: 'Look-alike website asking you to log in', allOf: {'lookalike_domain', 'login_requested'}, floor: 75),
  ComboRule(label: 'Check deposit with money sent back', allOf: {'check_overpayment'}, floor: 60),
  ComboRule(label: 'Check deposit plus equipment purchase (classic fake-job pattern)', allOf: {'check_overpayment', 'equipment_purchase'}, floor: 85),
  ComboRule(label: 'Asked to move money for someone else', allOf: {'money_mule'}, floor: 60),
  ComboRule(label: 'Remote-access software requested', allOf: {'remote_access'}, floor: 60),
  ComboRule(label: 'Remote access requested by a claimed bank', allOf: {'remote_access', 'bank_impersonation'}, floor: 85),
  ComboRule(label: 'Investment pitch from an online relationship', allOf: {'investment_request'}, anyOf: {'fast_affection', 'remote_story', 'avoids_verification'}, floor: 75),
  ComboRule(label: 'Money requested by someone who avoids verification', allOf: {'avoids_verification'}, anyOf: _moneyAsks, floor: 75),
  // Youth safety
  ComboRule(label: 'Sexual or inappropriate content involving a young person', allOf: {'youth_sexual_content'}, floor: 90),
  ComboRule(label: 'Threats or blackmail', allOf: {'youth_threats'}, floor: 80),
  ComboRule(label: 'Secrecy combined with pressure to meet', allOf: {'youth_secrecy', 'youth_meet_pressure'}, floor: 85),
  ComboRule(label: 'Secrecy combined with photo requests', allOf: {'youth_secrecy', 'youth_photo_request'}, floor: 80),
  ComboRule(label: 'Request for secrecy from parents/guardians', allOf: {'youth_secrecy'}, floor: 50),
];

/// Turns rule + AI findings into a transparent, explainable assessment.
///
/// Scoring model (all visible in "How was this calculated?"):
///   1. Rule-detected signals add their FIXED catalog weight.
///   2. AI-only signals (validated against the catalog) add 70% weight.
///   3. The AI's overall estimate can nudge the score by at most ±12.
///   4. Known high-risk combinations set a minimum score (floor).
/// A single AI-generated number can never decide the result.
class RiskScorer {
  const RiskScorer();

  static const double aiSignalFactor = 0.7;
  static const int maxAiAdjustment = 12;

  Assessment score({
    required String id,
    required ScanCategory category,
    required RuleResult rules,
    required AiAnalysis? ai,
    required int answeredCount,
    required int textLength,
    String? aiUnavailableReason,
    int redactionCount = 0,
    bool isDemoExample = false,
    DateTime? now,
  }) {
    // ── Merge signals ──
    final signals = <String, DetectedSignal>{for (final s in rules.signals) s.id: s};
    final aiOnly = <String>{};

    if (ai != null) {
      for (final s in ai.signals) {
        final def = signalById(s.id);
        if (def == null || !def.appliesTo(category.id) || signals.containsKey(def.id)) continue;
        signals[def.id] = DetectedSignal(
          definition: def,
          source: SignalSource.ai,
          evidence: s.evidence.isEmpty ? null : s.evidence,
        );
        aiOnly.add(def.id);
      }
      for (final r in ai.reputation.where((r) => r.flagged)) {
        final def = signalById('known_malicious_url')!;
        signals.putIfAbsent(
          def.id,
          () => DetectedSignal(
            definition: def,
            source: SignalSource.reputation,
            evidence: '${r.url}${r.threatTypes.isEmpty ? '' : ' (${r.threatTypes.join(', ')})'}',
          ),
        );
      }
    }

    int effectiveWeight(DetectedSignal s) =>
        aiOnly.contains(s.id) ? (s.definition.weight * aiSignalFactor).round() : s.definition.weight;

    final rulePoints = signals.values.where((s) => !aiOnly.contains(s.id)).fold<int>(0, (a, s) => a + effectiveWeight(s));
    final aiPoints = signals.values.where((s) => aiOnly.contains(s.id)).fold<int>(0, (a, s) => a + effectiveWeight(s));
    final base = math.min(100, rulePoints + aiPoints);

    // Demo AI is not real analysis, so it never adjusts the score.
    final realAi = ai != null && !ai.isDemo;
    var adjustment = 0;
    if (ai != null && realAi) {
      adjustment = ((ai.riskEstimate - base) * 0.2).round().clamp(-maxAiAdjustment, maxAiAdjustment);
    }

    final ids = signals.keys.toSet();
    ComboRule? topCombo;
    for (final c in kComboRules) {
      if (c.matches(ids) && (topCombo == null || c.floor > topCombo.floor)) topCombo = c;
    }
    final floor = topCombo?.floor ?? 0;

    final adjusted = (base + adjustment).clamp(0, 100);
    final finalScore = math.max(adjusted, floor);
    final level = RiskLevelX.fromScore(finalScore);

    // ── Breakdown by group ──
    final groupPoints = <SignalGroup, int>{};
    for (final s in signals.values) {
      groupPoints.update(s.definition.group, (v) => v + effectiveWeight(s), ifAbsent: () => effectiveWeight(s));
    }
    final breakdown = SignalGroup.values.map((g) {
      final pts = groupPoints[g] ?? 0;
      final lvl = pts == 0
          ? GroupLevel.none
          : pts < 15
              ? GroupLevel.low
              : pts < 30
                  ? GroupLevel.moderate
                  : GroupLevel.high;
      return GroupBreakdown(group: g, level: lvl, points: pts);
    }).toList()
      ..sort((a, b) => b.points.compareTo(a.points));

    // ── Reasons (3-5, strongest first) ──
    final ordered = signals.values.toList()
      ..sort((a, b) => effectiveWeight(b).compareTo(effectiveWeight(a)));
    final top = ordered.take(5).toList();
    final reasons = top
        .map((s) => s.source == SignalSource.ai ? '${s.definition.reason} (identified by AI analysis)' : s.definition.reason)
        .toList();
    final simpleReasons = top.map((s) => s.definition.simpleReason).toList();

    // ── Actions (3-5) ──
    final actions = <String>[];
    final simpleActions = <String>[];
    void addAction(String a, String simple) {
      if (actions.length >= 5 || actions.contains(a)) return;
      actions.add(a);
      simpleActions.add(simple);
    }

    if (category.id == 'youth') {
      // Youth safety: trusted-adult guidance always comes first.
      for (final a in category.recommendedActions) {
        addAction(a, a);
      }
    } else if (level == RiskLevel.low) {
      for (final a in category.recommendedActions) {
        addAction(a, a);
      }
      addAction('Still verify anything important through an independently obtained official source',
          'Still double-check anything important using the real website or phone number');
    } else {
      for (final s in ordered) {
        final a = s.definition.action;
        if (a != null) addAction(a, s.definition.simpleAction ?? a);
      }
      addAction('Verify through an independently obtained official source — not the contact info in the message',
          'Check using the real website or a phone number you already have');
      if (level == RiskLevel.elevated || level == RiskLevel.high) {
        addAction('Talk with a trusted person before proceeding', 'Talk to someone you trust before doing anything');
      }
      for (final a in category.recommendedActions) {
        addAction(a, a);
      }
    }

    // ── Confidence (separate from risk level) ──
    final confidence = _confidence(
      textLength: textLength,
      answeredCount: answeredCount,
      aiUsed: realAi,
      aiAgrees: ai == null || !realAi ? null : (ai.riskEstimate - base).abs() < 25 || (ai.riskEstimate >= 50) == (finalScore >= 50),
      strongSignals: signals.values.where((s) => s.definition.weight >= 30).length,
      signalCount: signals.length,
    );

    // ── Summary text ──
    final ruleCount = signals.length - aiOnly.length;
    final summary = (ai != null && ai.summary.isNotEmpty)
        ? ai.summary
        : signals.isEmpty
            ? 'TruthArmor\'s built-in safety rules did not find common warning signs in what you shared.'
            : 'TruthArmor\'s built-in safety rules found $ruleCount warning sign${ruleCount == 1 ? '' : 's'} in what you shared.';

    final steps = <ScoreStep>[
      ScoreStep('Built-in safety rules (${signals.length - aiOnly.length} signals)', '+$rulePoints'),
      if (ai != null) ScoreStep('AI-identified patterns (${aiOnly.length}, counted at 70%)', '+$aiPoints'),
      if (base < rulePoints + aiPoints) const ScoreStep('Capped at maximum', '100'),
      if (realAi) ScoreStep('AI context adjustment (limited to ±$maxAiAdjustment)', adjustment >= 0 ? '+$adjustment' : '$adjustment'),
      if (topCombo != null && floor > adjusted) ScoreStep('Minimum for: ${topCombo.label}', '$floor'),
      ScoreStep('Final score', '$finalScore / 100'),
    ];

    return Assessment(
      id: id,
      createdAt: now ?? DateTime.now(),
      categoryId: category.id,
      title: '${category.shortTitle} check',
      score: finalScore,
      level: level,
      confidence: confidence,
      headline: category.headlines[level.name] ?? level.defaultHeadline,
      summary: summary,
      reasons: reasons,
      simpleReasons: simpleReasons,
      actions: actions,
      simpleActions: simpleActions,
      breakdown: breakdown,
      signals: ordered,
      scoreSteps: steps,
      aiUsed: ai != null,
      isDemoAi: ai?.isDemo ?? false,
      aiUnavailableReason: aiUnavailableReason,
      additionalConcerns: ai?.additionalConcerns ?? const [],
      reassuringFactors: ai?.reassuringFactors ?? const [],
      redactionCount: redactionCount,
      isDemoExample: isDemoExample,
    );
  }

  ConfidenceLevel _confidence({
    required int textLength,
    required int answeredCount,
    required bool aiUsed,
    required bool? aiAgrees,
    required int strongSignals,
    required int signalCount,
  }) {
    var points = 0;
    if (textLength > 200) {
      points += 2;
    } else if (textLength > 40) {
      points += 1;
    }
    if (answeredCount >= 5) {
      points += 2;
    } else if (answeredCount >= 2) {
      points += 1;
    }
    if (aiUsed) points += 1;
    if (aiAgrees == true) points += 1;
    if (strongSignals >= 2) points += 1;
    if (signalCount == 0 && textLength < 40 && answeredCount < 2) points = 0;

    if (points >= 5) return ConfidenceLevel.high;
    if (points >= 3) return ConfidenceLevel.moderate;
    return ConfidenceLevel.low;
  }
}
