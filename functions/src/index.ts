/**
 * TruthArmor secure backend — Firebase Cloud Functions (2nd gen).
 *
 *   Flutter app ──HTTPS──► analyze ──► OpenAI (key stored as a Firebase secret)
 *                                  └─► Google Safe Browsing (optional)
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
import { RateLimiter } from "./rateLimit";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");
const SAFE_BROWSING_API_KEY = defineSecret("SAFE_BROWSING_API_KEY");
const OPENAI_MODEL = defineString("OPENAI_MODEL", { default: "gpt-4o-mini" });
const REQUIRE_APP_CHECK = defineBoolean("REQUIRE_APP_CHECK", { default: false });

const limiter = new RateLimiter(20, 60_000); // 20 checks per minute per IP, per instance

export const analyze = onRequest(
  {
    region: "us-central1",
    secrets: [OPENAI_API_KEY, SAFE_BROWSING_API_KEY],
    timeoutSeconds: 60,
    memory: "256MiB",
    maxInstances: 10,
    cors: false, // Mobile apps don't need CORS; keeps browsers from calling it cross-site.
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
