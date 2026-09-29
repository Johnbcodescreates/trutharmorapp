# TruthArmor Architecture

## Big picture

```
┌──────────────────────── Flutter app (on the phone) ────────────────────────┐
│                                                                             │
│  Screenshot ─► ML Kit OCR ─► User reviews/edits text                        │
│  Paste text / link ───────────────────────┐                                 │
│  Answer questions ────────────────────────┤                                 │
│                                           ▼                                 │
│                                 AssessmentDraft (memory only)               │
│                                           │                                 │
│                  ┌────────────────────────┼─────────────────────┐           │
│                  ▼                        ▼                     │           │
│           RuleEngine (offline)       Redactor (hide SSN,        │           │
│           • answers → signals        cards, codes, passwords)   │           │
│           • text patterns                 │                     │           │
│           • email/domain checks           ▼                     │           │
│           • UrlAnalyzer           AnalysisService ──HTTPS──┐    │           │
│                  │                (demo or backend)        │    │           │
│                  ▼                        │                │    │           │
│              RiskScorer ◄─────────────────┘                │    │           │
│      fixed weights + capped AI + combination floors        │    │           │
│                  │                                         │    │           │
│                  ▼                                         │    │           │
│     Assessment ─► Results screen ─► History (metadata)     │    │           │
└────────────────────────────────────────────────────────────┼────┘
                                                             ▼
                        ┌──────── Firebase Cloud Function `analyze` ────────┐
                        │ validate → rate-limit → redact again →             │
                        │ OpenAI (Structured Outputs, key = secret) ─┐       │
                        │ Google Safe Browsing (optional) ───────────┤       │
                        │ normalize + enforce careful wording ◄──────┘       │
                        └────────────────────────────────────────────────────┘
```

## Folder structure

```
lib/
  main.dart                 Starts the app, wires providers
  app/                      App-level wiring
    app.dart                MaterialApp, theme, Simple Mode text scaling
    app_shell.dart          Bottom navigation (Home · Check · History · Safety · Settings)
    app_state.dart          Settings + privacy-first history (ChangeNotifier)
    app_config.dart         DEMO vs PRODUCTION switch (TA_BACKEND_URL)
    navigation.dart         Navigation helpers
  theme/                    Design system: colors, spacing, typography, components
  models/                   Pure-Dart data classes (easy to test)
    question.dart           Question types + roles
    scan_category.dart      Category configuration model
    risk.dart               RiskLevel, signals, groups, Assessment, disclaimer
    ai_analysis.dart        Structured AI output
    assessment_draft.dart   User input before analysis
    history_entry.dart      Metadata-only history record
  data/                     Configuration & content (no logic)
    categories.dart         ★ The 9 category configs (the category engine)
    signal_catalog.dart     ★ Every warning sign with its FIXED weight
    help_resources.dart     Official reporting/help resources
    safety_articles.dart    Safety Center content
    demo_examples.dart      Fictional DEMO EXAMPLES
  services/                 Business logic — no UI code
    rules/                  Rule engine, text patterns, URL analyzer
    risk/risk_scorer.dart   Transparent scoring
    ai/                     AnalysisService interface + backend + demo
    privacy/redactor.dart   Sensitive-data redaction
    ocr/ocr_service.dart    ML Kit text recognition
    history/                On-device storage (metadata only)
    category_detector.dart  Quick Scan category suggestion
    assessment_pipeline.dart  Orchestrates one check
  screens/                  One file per screen (+ input/ flows)
  widgets/                  Reusable UI components
functions/                  Secure backend (TypeScript, Firebase Functions v2)
  src/index.ts              HTTPS endpoint, secrets, rate limit, App Check option
  src/handler.ts            Pure handler (testable): validate → redact → AI + reputation → normalize
  src/prompt.ts             System prompt + JSON schema (Structured Outputs)
  src/categoryPrompts.ts    Per-category AI instructions
  src/signals.ts            Signal ids (kept in sync with signal_catalog.dart)
  src/validate.ts / redact.ts / reputation.ts / openai.ts / rateLimit.ts
  test/handler.test.ts      Backend tests (node --test)
```

Business logic is separate from UI, and AI calls are separate from both: screens call
`AssessmentPipeline`, which calls the `RuleEngine`, the `Redactor`, an `AnalysisService`, and the `RiskScorer`.

## The category engine

Each category is one `ScanCategory` object in `lib/data/categories.dart`:

| Field | Purpose |
|---|---|
| `title`, `description`, `simpleDescription`, `icon` | What the user sees |
| `questions` | The guided questionnaire. Each `Question` can declare `signalIfYes`, `signalIfNo`, `optionSignals`, and a `role` (sender email, official website, link…) — so answers become signals **with no new code** |
| `recommendedActions`, `verifySteps`, `resources` | "What to do next" and "How to verify safely" |
| `detectionKeywords` | Quick Scan category suggestion |
| `headlines`, `specialNotice` | Careful, category-specific wording (e.g. romance, youth, government) |
| `articleId` | Linked Safety Center guide |
| AI instructions | Server-side in `functions/src/categoryPrompts.ts`, keyed by category id |

**To add a category:** add a `ScanCategory` to `categories.dart`, add its id and prompt to
`functions/src/signals.ts` + `categoryPrompts.ts`, and (optionally) a Safety Center article.

## How scoring works (transparent by design)

1. **Signals** come from four sources: your answers, text patterns, link checks, and (in production) the AI
   and link reputation. Every signal is defined in `signal_catalog.dart` with a **fixed weight**.
2. **Rule-detected** signals add their full weight. **AI-only** signals (validated against the catalog) add 70%.
3. The AI's overall estimate can nudge the score by **at most ±12** points. Demo AI never adjusts it.
4. **Combination floors** (`kComboRules`) guarantee a minimum score for patterns that are strongly associated
   with scams — e.g. *SSN + bank info* (75), *gift cards + a claimed agency* (85),
   *secrecy + pressure to meet a young person* (85). The AI cannot lower these.
5. Score → level: 0–24 **Low Risk** · 25–49 **Caution** · 50–74 **Elevated Risk** · 75–100 **High Risk**.
6. **Analysis confidence** (Low/Moderate/High) is computed separately from how much information was provided,
   whether AI was available, whether AI and rules agree, and how many strong signals were found.

The results screen shows all of this under "How was this calculated?".

## Error handling

| Situation | What the user sees |
|---|---|
| No internet / timeout / server error | A rule-based result, plus a friendly note that AI analysis was unavailable |
| Rate limited | "TruthArmor is busy right now. Please wait a minute and try again." |
| OCR finds no text / unreadable image | Friendly message suggesting a clearer screenshot or pasting the text |
| Camera/photos permission denied | Friendly message pointing to Settings |
| Invalid/odd URL | URL checks skip it; the rest of the analysis continues |
| Unexpected crash in analysis | "We couldn't analyze this right now…" with Try again / Go back |
