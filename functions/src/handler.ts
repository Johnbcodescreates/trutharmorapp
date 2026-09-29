import { callOpenAI, UpstreamError } from "./openai";
import { redact } from "./redact";
import { checkUrls, UrlReputation } from "./reputation";
import { AI_SIGNAL_IDS, CATEGORY_IDS, isYouthSignal } from "./signals";
import { ValidationError, ValidRequest, validateRequest } from "./validate";

type FetchLike = typeof fetch;

export interface HandlerDeps {
  openAiKey: string;
  model: string;
  safeBrowsingKey?: string;
  fetchImpl?: FetchLike;
}

export interface HandlerResult {
  status: number;
  body: Record<string, unknown>;
}

const clip = (s: unknown, max: number): string =>
  typeof s === "string" ? s.replace(/\s+/g, " ").trim().slice(0, max) : "";

const clipList = (v: unknown, maxItems: number, maxLen: number): string[] =>
  Array.isArray(v) ? v.map((x) => clip(x, maxLen)).filter((x) => x.length > 0).slice(0, maxItems) : [];

/** Wording TruthArmor never shows, even if the model produces it. */
const FORBIDDEN = [/\b(is|looks|seems) (completely |totally |100% )?safe\b/i, /\bdefinitely (a )?(scam|legit|legitimate|fraud)\b/i, /\bis a (predator|scammer|criminal)\b/i];

function soften(s: string): string {
  let out = s;
  if (FORBIDDEN.some((re) => re.test(out))) {
    out = out
      .replace(/\b(is|looks|seems) (completely |totally |100% )?safe\b/gi, "shows no obvious high-risk indicators")
      .replace(/\bdefinitely (a )?(scam|fraud)\b/gi, "contains patterns commonly associated with scams")
      .replace(/\bdefinitely (legit|legitimate)\b/gi, "shows no obvious high-risk indicators")
      .replace(/\bis a (predator|scammer|criminal)\b/gi, "shows concerning behavior patterns");
  }
  return out;
}

/**
 * Validates and normalizes the model output. The app is defensive too, but
 * the server guarantees: known signal ids only, category-appropriate signals,
 * bounded lengths, an integer estimate in 0-100, and careful wording.
 */
export function normalizeAiOutput(raw: unknown, categoryId: string): Record<string, unknown> {
  const o = (typeof raw === "object" && raw !== null ? raw : {}) as Record<string, unknown>;
  const allowed = new Set(AI_SIGNAL_IDS);
  const seen = new Set<string>();
  const signals: { id: string; evidence: string }[] = [];

  if (Array.isArray(o.detected_signals)) {
    for (const s of o.detected_signals) {
      if (typeof s !== "object" || s === null) continue;
      const id = (s as Record<string, unknown>).id;
      if (typeof id !== "string" || !allowed.has(id) || seen.has(id)) continue;
      // Youth signals only make sense in the youth category.
      if (isYouthSignal(id) && categoryId !== "youth") continue;
      seen.add(id);
      signals.push({ id, evidence: redact(clip((s as Record<string, unknown>).evidence, 160)).text });
    }
  }

  const est = typeof o.ai_risk_estimate === "number" && Number.isFinite(o.ai_risk_estimate) ? Math.round(o.ai_risk_estimate) : 0;
  const likely = typeof o.likely_category === "string" && (CATEGORY_IDS as readonly string[]).includes(o.likely_category)
    ? o.likely_category
    : categoryId;

  return {
    likely_category: likely,
    summary: soften(clip(o.summary, 420)),
    simple_summary: soften(clip(o.simple_summary, 300)),
    detected_signals: signals.slice(0, 15),
    additional_concerns: clipList(o.additional_concerns, 3, 200).map(soften),
    reassuring_factors: clipList(o.reassuring_factors, 3, 200).map(soften),
    verification_tips: clipList(o.verification_tips, 3, 220),
    ai_risk_estimate: Math.min(100, Math.max(0, est)),
  };
}

/** Pure request handler (no Firebase types) so it is easy to unit test. */
export async function handleAnalyze(body: unknown, deps: HandlerDeps): Promise<HandlerResult> {
  let req: ValidRequest;
  try {
    req = validateRequest(body);
  } catch (e) {
    if (e instanceof ValidationError) return { status: 400, body: { error: e.message } };
    return { status: 400, body: { error: "Invalid request." } };
  }

  // Defense in depth: redact again on the server.
  req = {
    ...req,
    text: redact(req.text).text,
    answers: Object.fromEntries(
      Object.entries(req.answers).map(([k, v]) => [k, typeof v === "string" ? redact(v).text : v]),
    ),
  };

  const [ai, reputation] = await Promise.all([
    callOpenAI(req, { apiKey: deps.openAiKey, model: deps.model, fetchImpl: deps.fetchImpl })
      .then((raw) => ({ ok: true as const, raw }))
      .catch((e: unknown) => ({ ok: false as const, error: e })),
    checkUrls(req.urls, deps.safeBrowsingKey, deps.fetchImpl),
  ]);

  if (!ai.ok) {
    const status = ai.error instanceof UpstreamError && ai.error.status === 429 ? 429 : 502;
    return { status, body: { error: "AI analysis is unavailable right now." } };
  }

  const out = normalizeAiOutput(ai.raw, req.category_id);
  out.url_reputation = reputation satisfies UrlReputation[];
  return { status: 200, body: out };
}
