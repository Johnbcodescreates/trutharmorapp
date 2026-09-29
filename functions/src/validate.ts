import { ALL_SIGNAL_IDS, CATEGORY_IDS } from "./signals";

export interface ValidRequest {
  category_id: string;
  text: string;
  answers: Record<string, string | string[]>;
  rule_signal_ids: string[];
  urls: string[];
  simple_mode: boolean;
}

export class ValidationError extends Error {}

const MAX_TEXT = 8000;
const MAX_ANSWERS = 60;
const MAX_ANSWER_LEN = 500;
const MAX_URLS = 10;
const MAX_URL_LEN = 2048;

/** Removes control characters (keeps newlines and tabs). */
export function sanitize(s: string): string {
  // eslint-disable-next-line no-control-regex
  return s.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "").trim();
}

/** Strict input validation — never trust the client. */
export function validateRequest(body: unknown): ValidRequest {
  if (typeof body !== "object" || body === null || Array.isArray(body)) {
    throw new ValidationError("Request body must be a JSON object.");
  }
  const b = body as Record<string, unknown>;

  const category = b.category_id;
  if (typeof category !== "string" || !(CATEGORY_IDS as readonly string[]).includes(category)) {
    throw new ValidationError("Unknown category.");
  }

  const rawText = typeof b.text === "string" ? b.text : "";
  if (rawText.length > MAX_TEXT) throw new ValidationError("Text is too long.");

  const answers: Record<string, string | string[]> = {};
  if (b.answers !== undefined) {
    if (typeof b.answers !== "object" || b.answers === null || Array.isArray(b.answers)) {
      throw new ValidationError("Answers must be an object.");
    }
    const entries = Object.entries(b.answers as Record<string, unknown>);
    if (entries.length > MAX_ANSWERS) throw new ValidationError("Too many answers.");
    for (const [key, value] of entries) {
      if (!/^[a-z0-9_]{1,40}$/.test(key)) continue;
      if (typeof value === "string") {
        answers[key] = sanitize(value).slice(0, MAX_ANSWER_LEN);
      } else if (Array.isArray(value)) {
        answers[key] = value
          .filter((v): v is string => typeof v === "string")
          .slice(0, 12)
          .map((v) => sanitize(v).slice(0, 100));
      }
    }
  }

  const known = new Set<string>(ALL_SIGNAL_IDS);
  const ruleIds = Array.isArray(b.rule_signal_ids)
    ? b.rule_signal_ids.filter((x): x is string => typeof x === "string" && known.has(x)).slice(0, 60)
    : [];

  const urls = Array.isArray(b.urls)
    ? b.urls
        .filter((x): x is string => typeof x === "string" && x.length <= MAX_URL_LEN)
        .slice(0, MAX_URLS)
        .map(sanitize)
    : [];

  if (rawText.trim().length === 0 && Object.keys(answers).length === 0 && urls.length === 0) {
    throw new ValidationError("Nothing to analyze.");
  }

  return {
    category_id: category,
    text: sanitize(rawText),
    answers,
    rule_signal_ids: ruleIds,
    urls,
    simple_mode: b.simple_mode === true,
  };
}
