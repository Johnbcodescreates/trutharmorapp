/**
 * Server-side redaction — defense in depth. The app already redacts before
 * sending; this runs again so sensitive data never reaches the AI provider
 * even if an older or modified client skips it. Mirrors
 * lib/services/privacy/redactor.dart.
 */
export function luhnValid(digits: string): boolean {
  let sum = 0;
  let alt = false;
  for (let i = digits.length - 1; i >= 0; i--) {
    let n = digits.charCodeAt(i) - 48;
    if (n < 0 || n > 9) return false;
    if (alt) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alt = !alt;
  }
  return sum % 10 === 0;
}

export function redact(input: string): { text: string; count: number } {
  let count = 0;
  let text = input;

  text = text.replace(/\b(ssn|social security( number)?|ss#)\s*[:#]?\s*\d{9}\b/gi, (_m, label: string) => {
    count++;
    return `${label} [REDACTED-SSN]`;
  });
  text = text.replace(/\b(?!000|666|9\d\d)\d{3}[- ]\d{2}[- ]\d{4}\b/g, () => {
    count++;
    return "[REDACTED-SSN]";
  });
  text = text.replace(/\b(?:\d[ -]?){13,19}\b/g, (m) => {
    const digits = m.replace(/[ -]/g, "");
    if (digits.length >= 13 && digits.length <= 19 && luhnValid(digits)) {
      count++;
      return "[REDACTED-CARD]";
    }
    return m;
  });
  text = text.replace(/\b(password|passcode|pin)\s*(is|:|=)\s*\S+/gi, (_m, a: string, b: string) => {
    count++;
    return `${a} ${b} [REDACTED]`;
  });
  text = text.replace(
    /\b((verification|security|one[- ]time|confirmation|access|login|otp)\s+code|code)\s*(is|:)?\s*(\d{4,8})\b/gi,
    (_m, label: string) => {
      count++;
      return `${label} [REDACTED-CODE]`;
    },
  );
  text = text.replace(/\b(account|acct|routing)\s*(number|no\.?|#)?\s*(is|:)?\s*(\d[\d -]{6,20}\d)\b/gi, (_m, label: string) => {
    count++;
    return `${label} number [REDACTED-ACCOUNT]`;
  });

  return { text, count };
}
