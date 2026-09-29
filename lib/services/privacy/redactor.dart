/// Removes sensitive data BEFORE anything is sent to an external AI service.
///
/// TruthArmor never needs your real SSN, card number, password, or codes
/// to recognize a scam — only the fact that someone asked for them.
class RedactionResult {
  const RedactionResult(this.text, this.count, this.kinds);
  final String text;
  final int count;
  final Set<String> kinds;
  bool get changed => count > 0;
}

class Redactor {
  const Redactor();

  static final RegExp _ssn = RegExp(r'\b(?!000|666|9\d\d)\d{3}[- ]\d{2}[- ]\d{4}\b');
  static final RegExp _ssnLabeled = RegExp(r'\b(ssn|social security( number)?|ss#)\s*[:#]?\s*\d{9}\b', caseSensitive: false);
  static final RegExp _cardCandidate = RegExp(r'\b(?:\d[ -]?){13,19}\b');
  static final RegExp _password = RegExp(r'\b(password|passcode|pin)\s*(is|:|=)\s*\S+', caseSensitive: false);
  static final RegExp _code = RegExp(
    r'\b((verification|security|one[- ]time|confirmation|access|login|otp)\s+code|code)\s*(is|:)?\s*(\d{4,8})\b',
    caseSensitive: false,
  );
  static final RegExp _account = RegExp(
    r'\b(account|acct|routing)\s*(number|no\.?|#)?\s*(is|:)?\s*(\d[\d -]{6,20}\d)\b',
    caseSensitive: false,
  );

  RedactionResult redact(String input) {
    var text = input;
    var count = 0;
    final kinds = <String>{};

    text = text.replaceAllMapped(_ssnLabeled, (m) {
      count++;
      kinds.add('Social Security number');
      return '${m.group(1)} [REDACTED-SSN]';
    });
    text = text.replaceAllMapped(_ssn, (m) {
      count++;
      kinds.add('Social Security number');
      return '[REDACTED-SSN]';
    });
    text = text.replaceAllMapped(_cardCandidate, (m) {
      final digits = m.group(0)!.replaceAll(RegExp(r'[ -]'), '');
      if (digits.length >= 13 && digits.length <= 19 && luhnValid(digits)) {
        count++;
        kinds.add('card number');
        return '[REDACTED-CARD]';
      }
      return m.group(0)!;
    });
    text = text.replaceAllMapped(_password, (m) {
      count++;
      kinds.add('password');
      return '${m.group(1)} ${m.group(2)} [REDACTED]';
    });
    text = text.replaceAllMapped(_code, (m) {
      count++;
      kinds.add('verification code');
      return '${m.group(1)} [REDACTED-CODE]';
    });
    text = text.replaceAllMapped(_account, (m) {
      count++;
      kinds.add('account number');
      return '${m.group(1)} number [REDACTED-ACCOUNT]';
    });

    return RedactionResult(text, count, kinds);
  }

  /// Quick check used to warn users while they type.
  bool containsSensitiveData(String input) => redact(input).changed;

  static bool luhnValid(String digits) {
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.tryParse(digits[i]);
      if (n == null) return false;
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}
