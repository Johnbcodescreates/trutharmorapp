import '../models/ai_analysis.dart';
import '../models/assessment_draft.dart';
import '../models/risk.dart';
import '../models/scan_category.dart';

/// Builds the honest "What we can see / What we can't confirm" lists.
///
/// TruthArmor separates what is directly observable in what the user shared
/// from what cannot be established from text alone — a core principle of the
/// app: an assessment, never a verdict.
class EvidenceSummary {
  const EvidenceSummary._();

  static ({List<String> known, List<String> unknown}) build({
    required ScanCategory category,
    required Assessment assessment,
    required List<String> urls,
    required AiAnalysis? ai,
    required InputSource source,
    required int textLength,
    required int answeredCount,
  }) {
    final known = <String>[];
    final unknown = <String>[];

    // ── What we can see ──
    final strongest = [...assessment.signals]..sort((a, b) => b.definition.weight.compareTo(a.definition.weight));
    for (final s in strongest.take(4)) {
      final where = switch (s.source) {
        SignalSource.text => 'In the message',
        SignalSource.link => 'In the link',
        SignalSource.answers => 'From your answers',
        SignalSource.ai => 'Noticed by AI analysis',
        SignalSource.reputation => 'From a security service',
      };
      known.add('$where: ${_lowerFirst(s.definition.reason)}.');
    }
    if (assessment.signals.isEmpty) {
      known.add('No common warning signs appear in what you shared.');
    }
    final reputation = ai?.reputation ?? const [];
    if (reputation.isNotEmpty && reputation.every((r) => !r.flagged)) {
      known.add('A security reputation service had no reports about the link${reputation.length == 1 ? '' : 's'}.');
    }

    // ── What we can't confirm ──
    final claimsIdentity = assessment.signals.any((s) =>
            s.definition.group == SignalGroup.impersonation || s.id == 'account_alert' || s.id == 'family_impersonation') ||
        const {'bank', 'government', 'job', 'message', 'property'}.contains(category.id);
    if (claimsIdentity) {
      unknown.add(category.id == 'ai_message' || assessment.signals.any((s) => s.id == 'family_impersonation')
          ? 'Whether the person is really who they say they are.'
          : 'Whether the sender is really the organization it claims to be.');
    }

    if (urls.isNotEmpty) {
      if (reputation.isEmpty) {
        unknown.add('Whether the link is safe — it was checked for warning signs, but not against a security database.');
      } else if (reputation.every((r) => !r.flagged)) {
        unknown.add('Whether the link is safe — brand-new scam sites often are not listed in security databases yet.');
      }
    }

    final specific = switch (category.id) {
      'government' => 'Whether any warrant, debt, or legal case exists — only the real agency can confirm that.',
      'bank' => 'Whether there is really a problem with your account — your bank\'s official app can tell you.',
      'job' => 'Whether the company and this job really exist — check the company\'s official careers page.',
      'property' => 'Who legally owns the property — only official county records can confirm that.',
      'romance' => 'Who this person really is.',
      'youth' => 'The other person\'s real identity, age, or intentions.',
      'ai_message' => 'Whether a message or voice was created by AI — no tool can tell this reliably.',
      'website' => 'Who really runs this website.',
      _ => null,
    };
    if (specific != null) unknown.add(specific);

    if (source == InputSource.screenshot || source == InputSource.photo) {
      unknown.add('Whether the screenshot text was read perfectly — reading errors are possible.');
    } else if (source == InputSource.voice) {
      unknown.add('Whether every word was transcribed correctly — automatic transcription can mishear.');
    }
    if (!assessment.aiUsed) {
      unknown.add(assessment.isDemoAi || ai == null
          ? 'How the full context reads to AI analysis — only the built-in safety rules were used.'
          : 'How the full context reads to AI analysis.');
    }
    if (textLength < 40 && answeredCount < 2) {
      unknown.add('Much about the situation — only a small amount of information was shared.');
    }

    return (known: known, unknown: unknown.take(5).toList());
  }

  static String _lowerFirst(String s) {
    if (s.isEmpty) return s;
    // Keep acronyms like "SSN" or "IRS" as written.
    if (s.length > 1 && s[1] == s[1].toUpperCase() && s[1] != s[1].toLowerCase()) return s;
    return s[0].toLowerCase() + s.substring(1);
  }
}
