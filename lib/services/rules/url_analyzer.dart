/// On-device link checks. These catch common *structural* warning signs.
///
/// IMPORTANT: passing these checks does NOT mean a site is safe. The result
/// wording is always "No obvious high-risk indicators detected" — never
/// "safe". In production, the backend additionally checks links against a
/// reputation service (see functions/src/reputation.ts).
class UrlFinding {
  const UrlFinding(this.signalId, this.evidence);
  final String signalId;
  final String evidence;
}

class UrlAnalyzer {
  const UrlAnalyzer();

  static const Set<String> shorteners = {
    'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'ow.ly', 'is.gd', 'buff.ly', 'rebrand.ly', 'cutt.ly',
    'shorturl.at', 'rb.gy', 'tiny.cc', 's.id', 't.ly', 'bl.ink', 'lnkd.in', 'shorte.st', 'v.gd', 'qrco.de',
  };

  static const Set<String> unusualTlds = {
    'zip', 'mov', 'xyz', 'top', 'click', 'country', 'gq', 'tk', 'ml', 'cf', 'ga', 'work', 'support', 'rest',
    'icu', 'cam', 'buzz', 'monster', 'cyou', 'sbs', 'cfd', 'lol', 'quest', 'bond', 'loan', 'win', 'review',
  };

  static const Set<String> freeEmailDomains = {
    'gmail.com', 'googlemail.com', 'yahoo.com', 'ymail.com', 'outlook.com', 'hotmail.com', 'live.com', 'msn.com',
    'aol.com', 'icloud.com', 'me.com', 'protonmail.com', 'proton.me', 'gmx.com', 'gmx.us', 'mail.com',
    'yandex.com', 'zoho.com', 'tutanota.com',
  };

  /// Brand keyword -> the brand's real registrable domains.
  /// Short keywords (< 5 letters) must match a whole host "word".
  static const Map<String, List<String>> brands = {
    'paypal': ['paypal.com'],
    'chase': ['chase.com'],
    'wellsfargo': ['wellsfargo.com', 'wf.com'],
    'bankofamerica': ['bankofamerica.com', 'bofa.com'],
    'capitalone': ['capitalone.com'],
    'navyfederal': ['navyfederal.org'],
    'amazon': ['amazon.com', 'amazon.co.uk', 'amazon.ca', 'amazon.in'],
    'apple': ['apple.com', 'icloud.com'],
    'icloud': ['icloud.com', 'apple.com'],
    'microsoft': ['microsoft.com', 'live.com', 'office.com', 'microsoftonline.com'],
    'netflix': ['netflix.com'],
    'usps': ['usps.com'],
    'fedex': ['fedex.com'],
    'venmo': ['venmo.com'],
    'zelle': ['zellepay.com', 'zelle.com'],
    'cashapp': ['cash.app', 'cashapp.com'],
    'coinbase': ['coinbase.com'],
    'google': ['google.com', 'goo.gl', 'youtube.com', 'gmail.com'],
    'facebook': ['facebook.com', 'fb.com', 'meta.com'],
    'instagram': ['instagram.com'],
    'linkedin': ['linkedin.com', 'lnkd.in'],
    'indeed': ['indeed.com'],
    'walmart': ['walmart.com'],
    'costco': ['costco.com'],
    'ebay': ['ebay.com'],
    'verizon': ['verizon.com'],
    'tmobile': ['t-mobile.com'],
    'irs': ['irs.gov'],
    'ssa': ['ssa.gov'],
    'socialsecurity': ['ssa.gov'],
    'medicare': ['medicare.gov'],
    'treasury': ['treasury.gov'],
  };

  static final RegExp _urlInText = RegExp(
    r'''(?<![@\w.-])((?:https?://)?(?:[a-z0-9-]+\.)+[a-z]{2,}(?::\d+)?(?:/[^\s<>"')\]]*)?)''',
    caseSensitive: false,
  );

  static final RegExp _ipHost = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');
  static final RegExp _emailInText = RegExp(r'[\w.+-]+@([\w-]+\.)+[a-z]{2,}', caseSensitive: false);

  /// Finds link-like strings in free text (with or without http://).
  List<String> extractUrls(String text) {
    final results = <String>{};
    for (final m in _urlInText.allMatches(text)) {
      var candidate = m.group(1)!;
      candidate = candidate.replaceAll(RegExp(r'[.,;:!?]+$'), '');
      final host = hostOf(candidate);
      if (host == null) continue;
      final tld = host.split('.').last;
      final hasScheme = candidate.toLowerCase().startsWith('http');
      // Skip "e.g", "U.S", file names like "invoice.pdf", and OCR run-ons
      // like "today.Please" (bare text must end in a real website ending).
      if (tld.length < 2 || _fileExtensions.contains(tld)) continue;
      if (!hasScheme && !_commonTlds.contains(tld) && !unusualTlds.contains(tld)) continue;
      results.add(candidate);
    }
    return results.toList();
  }

  static const Set<String> _commonTlds = {
    'com', 'org', 'net', 'gov', 'edu', 'mil', 'us', 'io', 'co', 'info', 'biz', 'app', 'me', 'ly', 'gl', 'gd', 'at',
    'ca', 'uk', 'in', 'au', 'de', 'ru', 'cn', 'online', 'site', 'store', 'shop', 'live', 'link', 'page',
    'ai', 'tv', 'cc', 'ws', 'id', 'to', 'vip', 'pro', 'club', 'fun', 'space', 'website', 'tech', 'pw',
  };

  static const Set<String> _fileExtensions = {'pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif', 'txt', 'exe', 'zip', 'apk'};

  List<String> extractEmails(String text) =>
      _emailInText.allMatches(text).map((m) => m.group(0)!).toSet().toList();

  /// Lower-case host for a URL (adds http:// if the user left it off).
  String? hostOf(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;
    if (!RegExp(r'^[a-z][a-z0-9+.-]*://', caseSensitive: false).hasMatch(s)) {
      s = 'http://$s';
    }
    final uri = Uri.tryParse(s);
    if (uri == null || uri.host.isEmpty) return null;
    return uri.host.toLowerCase();
  }

  /// "login.paypal.com.secure-verify.xyz" -> "secure-verify.xyz".
  /// (Simplified public-suffix handling; good enough for warning signs.)
  String registrableDomain(String host) {
    final labels = host.toLowerCase().split('.').where((l) => l.isNotEmpty).toList();
    if (labels.length <= 2) return labels.join('.');
    final lastTwo = '${labels[labels.length - 2]}.${labels.last}';
    const twoPartSuffixes = {
      'co.uk', 'org.uk', 'gov.uk', 'ac.uk', 'com.au', 'net.au', 'co.nz', 'co.in', 'com.br', 'co.jp', 'com.mx', 'co.za',
    };
    if (twoPartSuffixes.contains(lastTwo)) {
      return labels.sublist(labels.length - 3).join('.');
    }
    return lastTwo;
  }

  String? domainFromEmail(String email) {
    final at = email.lastIndexOf('@');
    if (at < 0 || at == email.length - 1) return null;
    return email.substring(at + 1).trim().toLowerCase();
  }

  bool isFreeEmailDomain(String domain) => freeEmailDomains.contains(domain.toLowerCase());

  /// Returns the brand a host appears to imitate, if the host is NOT one of
  /// that brand's official domains. Null = no impersonation pattern found.
  String? impersonatedBrand(String host) {
    final h = host.toLowerCase();
    final reg = registrableDomain(h);
    final normalized = _deLeet(h);
    final words = normalized.split(RegExp(r'[.\-_]')).where((w) => w.isNotEmpty).toList();

    for (final entry in brands.entries) {
      final brand = entry.key;
      final official = entry.value;
      final isOfficial = official.any((d) => reg == d || h == d || h.endsWith('.$d'));
      if (isOfficial) continue;
      if (words.any((w) => _wordImitates(w, brand))) return brand;
    }
    return null;
  }

  /// Words scammers commonly glue onto a brand ("paypal-secure", "chaselogin").
  static const Set<String> _scamAffixes = {
    'secure', 'security', 'login', 'signin', 'verify', 'verification', 'support', 'help', 'helpdesk', 'account',
    'accounts', 'service', 'services', 'alert', 'alerts', 'online', 'update', 'center', 'team', 'us', 'usa', 'pay',
    'bank', 'banking', 'app', 'official', 'refund', 'refunds', 'claim', 'billing', 'customer', 'care', 'id', 'auth',
    'web', 'mail', 'delivery', 'track', 'tracking', 'careers', 'jobs', 'hr', 'gov', 'portal', 'my', 'fraud',
  };

  /// True if [word] is the brand itself, or the brand plus a scam-style affix.
  /// ("applebees" is NOT flagged for "apple"; "applesupport" is.)
  static bool _wordImitates(String word, String brand) {
    if (word == brand) return true;
    if (word.startsWith(brand) && _scamAffixes.contains(word.substring(brand.length))) return true;
    if (word.endsWith(brand) && _scamAffixes.contains(word.substring(0, word.length - brand.length))) return true;
    return false;
  }

  static String _deLeet(String s) => s
      .replaceAll('0', 'o')
      .replaceAll('1', 'l')
      .replaceAll('3', 'e')
      .replaceAll('5', 's')
      .replaceAll('rn', 'm')
      .replaceAll('vv', 'w');

  /// Analyzes a single link and returns any structural warning signs.
  List<UrlFinding> analyze(String rawUrl) {
    final findings = <UrlFinding>[];
    final raw = rawUrl.trim();
    final host = hostOf(raw);
    if (host == null) return findings;

    final reg = registrableDomain(host);
    final hasScheme = raw.toLowerCase().startsWith('http');

    if (_ipHost.hasMatch(host) || host.contains(':')) {
      findings.add(UrlFinding('ip_address_url', 'Link points to a numeric address ($host)'));
    }
    if (host.contains('xn--') || RegExp(r'[^\x00-\x7F]').hasMatch(host)) {
      findings.add(UrlFinding('punycode_domain', 'Website name contains look-alike characters ($host)'));
    }
    if (shorteners.contains(reg) || shorteners.contains(host)) {
      findings.add(UrlFinding('shortened_url', 'Shortened link ($host) hides the real destination'));
    }
    final tld = host.split('.').last;
    if (unusualTlds.contains(tld)) {
      findings.add(UrlFinding('unusual_tld', 'Uncommon website ending ".$tld"'));
    }
    final brand = impersonatedBrand(host);
    if (brand != null) {
      findings.add(UrlFinding('lookalike_domain', 'Mentions "$brand" but the site actually belongs to "$reg"'));
    }
    if (hasScheme && raw.toLowerCase().startsWith('http://')) {
      findings.add(UrlFinding('insecure_http', 'Link uses http:// instead of https://'));
    }

    final structure = <String>[];
    final authority = raw.replaceFirst(RegExp(r'^[a-z]+://', caseSensitive: false), '').split('/').first;
    if (authority.contains('@')) structure.add('contains an "@" that can disguise the real site');
    if (host.split('.').length >= 5) structure.add('has many sub-parts');
    if ('-'.allMatches(reg).length >= 2) structure.add('has many hyphens');
    if (brand == null &&
        !_isWellKnown(reg) &&
        RegExp(r'(login|signin|verify|secure|account|update|wallet|webscr|confirm|unlock)').hasMatch(raw.toLowerCase())) {
      structure.add('uses login/verify wording on an unfamiliar site');
    }
    if (structure.isNotEmpty) {
      findings.add(UrlFinding('suspicious_url_structure', 'Link ${structure.join(', ')}'));
    }
    return findings;
  }

  bool _isWellKnown(String reg) =>
      brands.values.any((domains) => domains.contains(reg)) || reg.endsWith('.gov') || reg.endsWith('.edu');
}
