import '../../data/signal_catalog.dart';
import '../../models/question.dart';
import '../../models/risk.dart';
import '../../models/scan_category.dart';
import 'text_patterns.dart';
import 'url_analyzer.dart';

/// Output of the deterministic, on-device rule engine.
class RuleResult {
  const RuleResult({required this.signals, required this.urls});

  /// Unique signals found (one per signal id).
  final List<DetectedSignal> signals;

  /// Links found in the text and answers (analyzed on-device, and sent to
  /// the backend for reputation checks in production).
  final List<String> urls;

  Set<String> get ids => signals.map((s) => s.id).toSet();
}

/// Rule-based detection: the stable backbone of TruthArmor's analysis.
///
/// Whatever the AI says, if a job asks for SSN + bank info + a payment, the
/// rule engine WILL flag it. Runs fully on-device, instantly, offline.
class RuleEngine {
  const RuleEngine({this.urlAnalyzer = const UrlAnalyzer()});

  final UrlAnalyzer urlAnalyzer;

  RuleResult evaluate({
    required ScanCategory category,
    required String text,
    required Map<String, dynamic> answers,
  }) {
    final found = <String, DetectedSignal>{};

    void add(String id, SignalSource source, String? evidence) {
      final def = signalById(id);
      if (def == null || !def.appliesTo(category.id)) return;
      found.putIfAbsent(id, () => DetectedSignal(definition: def, source: source, evidence: evidence));
    }

    // 1) Structured answers (most reliable — the user told us directly).
    String? claimedOrg;
    String? senderEmail;
    String? officialWebsite;
    final urls = <String>{};

    for (final q in category.questions) {
      final value = answers[q.id];
      if (value == null) continue;

      switch (q.type) {
        case QuestionType.yesNo:
          if (value == YesNo.yes && q.signalIfYes != null) {
            add(q.signalIfYes!, SignalSource.answers, 'You answered "Yes": ${q.label}');
          } else if (value == YesNo.no && q.signalIfNo != null) {
            add(q.signalIfNo!, SignalSource.answers, 'You answered "No": ${q.label}');
          }
          break;
        case QuestionType.singleChoice:
          final sig = q.optionSignals[value];
          if (sig != null) add(sig, SignalSource.answers, '${q.label} — "$value"');
          break;
        case QuestionType.multiChoice:
          if (value is List) {
            for (final option in value.whereType<String>()) {
              final sig = q.optionSignals[option];
              if (sig != null) add(sig, SignalSource.answers, '${q.label} — "$option"');
            }
          }
          break;
        default:
          break;
      }

      final str = value is String ? value.trim() : '';
      if (str.isEmpty) continue;
      switch (q.role) {
        case FieldRole.claimedOrganization:
          claimedOrg = str;
          break;
        case FieldRole.senderEmail:
          senderEmail = str;
          break;
        case FieldRole.officialWebsite:
          officialWebsite = str;
          urls.add(str);
          break;
        case FieldRole.suspiciousUrl:
          urls.add(str);
          break;
        case FieldRole.messageText:
          text = '$text\n$str';
          break;
        default:
          break;
      }
    }

    // A claimed agency/bank is itself worth noting in those categories.
    if (claimedOrg != null && claimedOrg.toLowerCase() != 'other') {
      if (category.id == 'government') {
        add('government_impersonation', SignalSource.answers, 'Claims to be: $claimedOrg');
      } else if (category.id == 'bank') {
        add('bank_impersonation', SignalSource.answers, 'Claims to be: $claimedOrg');
      }
    }

    // 2) Text patterns (pasted text or reviewed OCR text).
    if (text.trim().isNotEmpty) {
      kTextPatterns.forEach((id, patterns) {
        for (final p in patterns) {
          final m = p.firstMatch(text);
          if (m != null) {
            add(id, SignalSource.text, _snippet(text, m.start, m.end));
            break;
          }
        }
      });
      urls.addAll(urlAnalyzer.extractUrls(text));

      // Many personal/financial details requested at once (identity theft kit).
      final items = requestedPersonalItems(text);
      if (items.length >= 4) {
        add('bulk_personal_info', SignalSource.text, 'Asks for: ${items.join(', ')}');
      }

      // Pay far above normal for the work.
      final pay = highestHourlyPay(text);
      if (pay != null) {
        final noExperience = RegExp(r'\b(no experience|high school|no degree|entry[- ]level|work from home|remote)\b',
                caseSensitive: false)
            .hasMatch(text);
        if (pay >= 100 || (pay >= 45 && noExperience)) {
          add('unrealistic_pay', SignalSource.text,
              'Offers about \$${pay.round()}/hour${noExperience ? ' with no experience required' : ''}');
        }
      }
    }

    // 3) Sender email checks.
    if (senderEmail != null) {
      final domain = urlAnalyzer.domainFromEmail(senderEmail);
      if (domain != null) {
        if (urlAnalyzer.isFreeEmailDomain(domain) && claimedOrg != null) {
          add('nonofficial_email', SignalSource.answers, '"$claimedOrg" is using a $domain address');
        }
        final imitated = urlAnalyzer.impersonatedBrand(domain);
        if (imitated != null) {
          add('domain_mismatch', SignalSource.answers, 'Email domain "$domain" imitates "$imitated"');
        } else if (officialWebsite != null && !urlAnalyzer.isFreeEmailDomain(domain)) {
          final siteHost = urlAnalyzer.hostOf(officialWebsite);
          if (siteHost != null &&
              urlAnalyzer.registrableDomain(siteHost) != urlAnalyzer.registrableDomain(domain)) {
            add('domain_mismatch', SignalSource.answers,
                'Email is from "$domain" but the website is "${urlAnalyzer.registrableDomain(siteHost)}"');
          }
        }
      }
    }

    // Email addresses inside the text: unusual endings or look-alike brands.
    for (final email in urlAnalyzer.extractEmails(text)) {
      final d = urlAnalyzer.domainFromEmail(email);
      if (d == null) continue;
      final tld = d.split('.').last;
      if (UrlAnalyzer.unusualTlds.contains(tld)) {
        add('unusual_tld', SignalSource.text, 'Sender address uses an uncommon ending ($email)');
      }
      final imitated = urlAnalyzer.impersonatedBrand(d);
      if (imitated != null) {
        add('domain_mismatch', SignalSource.text, 'Email domain "$d" imitates "$imitated"');
      }
    }

    // Free-mail addresses inside the text that claim to be a business.
    if (text.isNotEmpty &&
        RegExp(r'\b(recruit\w*|hiring|hr|human resources|department|support team|bank|agency|company|office)\b',
                caseSensitive: false)
            .hasMatch(text)) {
      for (final email in urlAnalyzer.extractEmails(text)) {
        final d = urlAnalyzer.domainFromEmail(email);
        if (d != null && urlAnalyzer.isFreeEmailDomain(d)) {
          add('nonofficial_email', SignalSource.text, 'Business contact uses a personal email ($email)');
          break;
        }
      }
    }

    // 4) Link analysis.
    for (final url in urls) {
      for (final f in urlAnalyzer.analyze(url)) {
        add(f.signalId, SignalSource.link, f.evidence);
      }
    }

    return RuleResult(signals: found.values.toList(), urls: urls.toList());
  }

  static final RegExp _requestVerb = RegExp(
    r'\b(send|provide|submit|share|give|enter|fill out|fill in|include|reply with|text us|email us|need|required?|must)\b',
    caseSensitive: false,
  );

  static final Map<String, RegExp> _personalItems = {
    'full name': RegExp(r'\b(full |legal |first and last )?name\b', caseSensitive: false),
    'date of birth': RegExp(r'\b(date of birth|dob|birth ?date|birthday)\b', caseSensitive: false),
    'home address': RegExp(r'(?<!e-?mail )\b(home |mailing |street )?address\b', caseSensitive: false),
    'phone number': RegExp(r'\b(phone|cell|mobile)( ?number)?\b', caseSensitive: false),
    'email': RegExp(r'\be-?mail( address)?\b', caseSensitive: false),
    'Social Security number': RegExp(r'\b(ssn|social security)\b', caseSensitive: false),
    'credit/debit card': RegExp(r'\b(credit|debit|atm) ?card\b|\bcard (number|info|details)\b|\bcvv\b', caseSensitive: false),
    'bank information': RegExp(r'\bbank(ing)?\b|\b(routing|account) number\b', caseSensitive: false),
    'ID or license': RegExp(r"\b(driver'?s? licen[cs]e|passport|photo id|state id)\b", caseSensitive: false),
    'password': RegExp(r'\b(password|passcode|pin)\b', caseSensitive: false),
  };

  /// Personal details a message asks for (only counted if it is asking).
  static List<String> requestedPersonalItems(String text) {
    if (!_requestVerb.hasMatch(text)) return const [];
    return [
      for (final e in _personalItems.entries)
        if (e.value.hasMatch(text)) e.key,
    ];
  }

  static final RegExp _hourly = RegExp(
    r'\$\s?(\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?\s*(?:/|per|an|a)\s*(?:hr|hour)\b',
    caseSensitive: false,
  );

  /// Highest hourly pay mentioned, e.g. "\$1,000/hr" -> 1000.
  static double? highestHourlyPay(String text) {
    double? best;
    for (final m in _hourly.allMatches(text)) {
      final v = double.tryParse(m.group(1)!.replaceAll(',', ''));
      if (v != null && (best == null || v > best)) best = v;
    }
    return best;
  }

  static String _snippet(String text, int start, int end) {
    final s = (start - 30).clamp(0, text.length);
    final e = (end + 30).clamp(0, text.length);
    var out = text.substring(s, e).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s > 0) out = '…$out';
    if (e < text.length) out = '$out…';
    return out;
  }
}
