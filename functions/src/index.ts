/**
 * TruthArmor secure backend — Firebase Cloud Functions (2nd gen).
 *
 *   Flutter app ──HTTPS──► analyze ──► OpenAI (key stored as a Firebase secret)
 *                                  └─► Google Safe Browsing (optional)
 *
 * The same endpoint also transcribes voice messages when the request body has
 * "action": "transcribe" (one URL keeps app configuration simple).
 *
 * Secrets (never in source code):
 *   firebase functions:secrets:set OPENAI_API_KEY
 *   firebase functions:secrets:set SAFE_BROWSING_API_KEY   (enter "none" to disable link reputation)
 */
import { defineSecret, defineString, defineBoolean } from "firebase-functions/params";
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getApps, initializeApp } from "firebase-admin/app";
import { getAppCheck } from "firebase-admin/app-check";

import { handleAnalyze } from "./handler";
import { handleTranscribe } from "./transcribe";
import { RateLimiter } from "./rateLimit";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");
const SAFE_BROWSING_API_KEY = defineSecret("SAFE_BROWSING_API_KEY");
const OPENAI_MODEL = defineString("OPENAI_MODEL", { default: "gpt-4o-mini" });
const TRANSCRIBE_MODEL = defineString("TRANSCRIBE_MODEL", { default: "gpt-transcribe" });
const REQUIRE_APP_CHECK = defineBoolean("REQUIRE_APP_CHECK", { default: false });

const limiter = new RateLimiter(20, 60_000); // 20 checks per minute per IP, per instance
const audioLimiter = new RateLimiter(5, 60_000); // 5 voice messages per minute per IP

export const analyze = onRequest(
  {
    region: "us-central1",
    secrets: [OPENAI_API_KEY, SAFE_BROWSING_API_KEY],
    timeoutSeconds: 120,
    memory: "512MiB",
    maxInstances: 10,
    // Browsers may call this only from the local dev server (localhost) and
    // Firebase Hosting sites. Mobile apps don't use CORS at all.
    cors: [/^https?:\/\/localhost(:\d+)?$/, /^https:\/\/[a-z0-9-]+\.web\.app$/, /^https:\/\/[a-z0-9-]+\.firebaseapp\.com$/],
  },
  async (req, res) => {
    res.set("Cache-Control", "no-store");

    if (req.method !== "POST") {
      res.status(405).json({ error: "Use POST." });
      return;
    }

    const ip = (req.headers["x-forwarded-for"] as string | undefined)?.split(",")[0]?.trim() || req.ip || "unknown";
    if (!limiter.allow(ip)) {
      res.status(429).json({ error: "Too many requests. Please wait a minute." });
      return;
    }

    if (REQUIRE_APP_CHECK.value()) {
      const token = req.header("X-Firebase-AppCheck");
      try {
        if (!token) throw new Error("missing");
        if (getApps().length === 0) initializeApp();
        await getAppCheck().verifyToken(token);
      } catch {
        res.status(401).json({ error: "Unauthorized." });
        return;
      }
    }

    // ── Voice message → text ──
    if ((req.body as { action?: unknown })?.action === "transcribe") {
      if (!audioLimiter.allow(ip)) {
        res.status(429).json({ error: "Too many voice messages. Please wait a minute." });
        return;
      }
      try {
        const result = await handleTranscribe(req.body, {
          openAiKey: OPENAI_API_KEY.value(),
          model: TRANSCRIBE_MODEL.value(),
        });
        logger.info("transcribe", { status: result.status }); // metadata only
        res.status(result.status).json(result.body);
      } catch (e) {
        logger.error("transcribe failed", { message: e instanceof Error ? e.message : "unknown" });
        res.status(500).json({ error: "Something went wrong." });
      }
      return;
    }

    let safeBrowsingKey: string | undefined;
    try {
      const v = SAFE_BROWSING_API_KEY.value().trim();
      safeBrowsingKey = v && v.toLowerCase() !== "none" ? v : undefined;
    } catch {
      safeBrowsingKey = undefined;
    }

    try {
      const result = await handleAnalyze(req.body, {
        openAiKey: OPENAI_API_KEY.value(),
        model: OPENAI_MODEL.value(),
        safeBrowsingKey,
      });
      // Log only metadata — NEVER user content.
      logger.info("analyze", { status: result.status, category: (req.body as { category_id?: string })?.category_id });
      res.status(result.status).json(result.body);
    } catch (e) {
      logger.error("analyze failed", { message: e instanceof Error ? e.message : "unknown" });
      res.status(500).json({ error: "Something went wrong." });
    }
  },
);
