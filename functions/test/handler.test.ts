import { test } from "node:test";
import assert from "node:assert/strict";

import { handleAnalyze, normalizeAiOutput } from "../src/handler";
import { redact } from "../src/redact";
import { validateRequest } from "../src/validate";
import { RateLimiter } from "../src/rateLimit";

function fakeFetch(aiContent: object, opts: { status?: number; safeBrowsing?: object } = {}) {
  const calls: { url: string; body: any }[] = [];
  const impl = (async (url: string, init?: { body?: string }) => {
    const body = init?.body ? JSON.parse(init.body) : undefined;
    calls.push({ url, body });
    if (url.includes("safebrowsing")) {
      return new Response(JSON.stringify(opts.safeBrowsing ?? {}), { status: 200 });
    }
    if ((opts.status ?? 200) !== 200) return new Response("{}", { status: opts.status });
    return new Response(
      JSON.stringify({ choices: [{ message: { content: JSON.stringify(aiContent) } }] }),
      { status: 200 },
    );
  }) as unknown as typeof fetch;
  return { impl, calls };
}

const goodAi = {
  likely_category: "government",
  summary: "This message contains patterns commonly associated with government impersonation scams.",
  simple_summary: "This looks like a common trick. Do not pay.",
  detected_signals: [
    { id: "gift_cards", evidence: "pay using Target gift cards" },
    { id: "made_up_signal", evidence: "x" },
    { id: "known_malicious_url", evidence: "AI may not decide this" },
    { id: "youth_secrecy", evidence: "not allowed outside youth" },
    { id: "gift_cards", evidence: "duplicate" },
  ],
  additional_concerns: [],
  reassuring_factors: [],
  verification_tips: ["Call the IRS using the number on irs.gov"],
  ai_risk_estimate: 140,
};

test("rejects unknown categories and empty requests", async () => {
  const { impl } = fakeFetch(goodAi);
  const bad = await handleAnalyze({ category_id: "nope", text: "hi" }, { openAiKey: "k", model: "m", fetchImpl: impl });
  assert.equal(bad.status, 400);
  const empty = await handleAnalyze({ category_id: "job", text: "  " }, { openAiKey: "k", model: "m", fetchImpl: impl });
  assert.equal(empty.status, 400);
});

test("normalizes AI output: known ids only, no code-only or cross-category signals, clamped estimate", async () => {
  const { impl, calls } = fakeFetch(goodAi);
  const res = await handleAnalyze(
    { category_id: "government", text: "Pay with gift cards now. My SSN is 123-45-6789", answers: { agency: "IRS" } },
    { openAiKey: "secret-key", model: "test-model", fetchImpl: impl },
  );
  assert.equal(res.status, 200);
  const ids = (res.body.detected_signals as { id: string }[]).map((s) => s.id);
  assert.deepEqual(ids, ["gift_cards"]);
  assert.equal(res.body.ai_risk_estimate, 100);

  // The prompt must never contain the raw SSN; the key goes only in the header.
  const sent = JSON.stringify(calls[0].body);
  assert.ok(!sent.includes("123-45-6789"), "SSN must be redacted before reaching the AI");
  assert.ok(sent.includes("[REDACTED-SSN]"));
  assert.ok(!sent.includes("secret-key"));
  assert.ok(sent.includes("<untrusted_content>"));
});

test("upstream failure returns 502 and rate limit maps to 429", async () => {
  const f1 = fakeFetch(goodAi, { status: 500 });
  const r1 = await handleAnalyze({ category_id: "job", text: "hello" }, { openAiKey: "k", model: "m", fetchImpl: f1.impl });
  assert.equal(r1.status, 502);
  const f2 = fakeFetch(goodAi, { status: 429 });
  const r2 = await handleAnalyze({ category_id: "job", text: "hello" }, { openAiKey: "k", model: "m", fetchImpl: f2.impl });
  assert.equal(r2.status, 429);
});

test("safe browsing matches are returned as url_reputation", async () => {
  const { impl } = fakeFetch(goodAi, {
    safeBrowsing: { matches: [{ threat: { url: "http://bad.example.xyz/login" }, threatType: "SOCIAL_ENGINEERING" }] },
  });
  const res = await handleAnalyze(
    { category_id: "website", text: "bad.example.xyz/login", urls: ["bad.example.xyz/login", "https://ok.example.com"] },
    { openAiKey: "k", model: "m", safeBrowsingKey: "sb", fetchImpl: impl },
  );
  assert.equal(res.status, 200);
  const rep = res.body.url_reputation as { url: string; flagged: boolean; threat_types: string[] }[];
  assert.equal(rep.length, 2);
  assert.equal(rep[0].flagged, true);
  assert.deepEqual(rep[0].threat_types, ["SOCIAL_ENGINEERING"]);
  assert.equal(rep[1].flagged, false);
});

test("careful wording is enforced", () => {
  const out = normalizeAiOutput(
    { summary: "This website is safe. The sender is a scammer? No: he is a predator.", detected_signals: [] },
    "message",
  );
  assert.ok(!/is safe/i.test(out.summary as string));
  assert.ok(!/is a predator/i.test(out.summary as string));
});

test("redaction covers SSN, cards (Luhn), codes, passwords, accounts", () => {
  const r = redact(
    "ssn 123-45-6789, card 4111 1111 1111 1111, code is 482913, password: hunter2, account number 12345678901",
  );
  assert.ok(!r.text.includes("123-45-6789"));
  assert.ok(!r.text.includes("4111 1111 1111 1111"));
  assert.ok(!r.text.includes("482913"));
  assert.ok(!r.text.includes("hunter2"));
  assert.ok(!r.text.includes("12345678901"));
  assert.equal(r.count, 5);
  // Phone numbers and non-Luhn numbers stay.
  assert.ok(redact("Call 555-123-4567").text.includes("555-123-4567"));
});

test("validation strips unknown rule ids and bad answer keys", () => {
  const v = validateRequest({
    category_id: "job",
    text: "x",
    answers: { good_key: "yes", "BAD KEY": "no", list: ["a", 1, "b"] },
    rule_signal_ids: ["urgency", "not_real"],
  });
  assert.deepEqual(v.rule_signal_ids, ["urgency"]);
  assert.deepEqual(Object.keys(v.answers).sort(), ["good_key", "list"]);
  assert.deepEqual(v.answers.list, ["a", "b"]);
});

test("rate limiter", () => {
  const rl = new RateLimiter(2, 1000);
  assert.ok(rl.allow("a", 0));
  assert.ok(rl.allow("a", 1));
  assert.ok(!rl.allow("a", 2));
  assert.ok(rl.allow("a", 1500));
});
