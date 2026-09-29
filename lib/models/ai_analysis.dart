/// Structured output returned by the AI analysis service (live or demo).
///
/// The backend validates the AI's JSON against a strict schema before it
/// ever reaches the app; [AiAnalysis.fromJson] is defensive anyway.
class AiSignal {
  const AiSignal(this.id, this.evidence);
  final String id;
  final String evidence;
}

class UrlReputation {
  const UrlReputation({required this.url, required this.flagged, this.threatTypes = const []});
  final String url;
  final bool flagged;
  final List<String> threatTypes;
}

class AiAnalysis {
  const AiAnalysis({
    required this.summary,
    required this.simpleSummary,
    required this.signals,
    required this.riskEstimate,
    required this.isDemo,
    this.likelyCategory,
    this.additionalConcerns = const [],
    this.reassuringFactors = const [],
    this.verificationTips = const [],
    this.reputation = const [],
  });

  final String summary;
  final String simpleSummary;
  final List<AiSignal> signals;

  /// The AI's own 0-100 estimate. Used ONLY as a small, capped adjustment.
  final int riskEstimate;
  final bool isDemo;
  final String? likelyCategory;
  final List<String> additionalConcerns;
  final List<String> reassuringFactors;
  final List<String> verificationTips;
  final List<UrlReputation> reputation;

  static List<String> _strings(dynamic v, {int max = 5}) {
    if (v is! List) return const [];
    return v.whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).take(max).toList();
  }

  factory AiAnalysis.fromJson(Map<String, dynamic> json, {bool isDemo = false}) {
    final rawSignals = json['detected_signals'];
    final signals = <AiSignal>[];
    if (rawSignals is List) {
      for (final s in rawSignals) {
        if (s is Map && s['id'] is String) {
          signals.add(AiSignal(s['id'] as String, (s['evidence'] as String?) ?? ''));
        }
      }
    }
    final rep = <UrlReputation>[];
    final rawRep = json['url_reputation'];
    if (rawRep is List) {
      for (final r in rawRep) {
        if (r is Map && r['url'] is String) {
          rep.add(UrlReputation(
            url: r['url'] as String,
            flagged: r['flagged'] == true,
            threatTypes: _strings(r['threat_types']),
          ));
        }
      }
    }
    final estimate = json['ai_risk_estimate'];
    return AiAnalysis(
      summary: (json['summary'] as String?)?.trim() ?? '',
      simpleSummary: (json['simple_summary'] as String?)?.trim() ?? '',
      signals: signals,
      riskEstimate: (estimate is num ? estimate.round() : 0).clamp(0, 100),
      isDemo: isDemo,
      likelyCategory: json['likely_category'] as String?,
      additionalConcerns: _strings(json['additional_concerns'], max: 3),
      reassuringFactors: _strings(json['reassuring_factors'], max: 3),
      verificationTips: _strings(json['verification_tips'], max: 4),
      reputation: rep,
    );
  }
}
