<p align="center"><img src="assets/brand/logo_full.png" alt="TruthArmor" width="420"></p>

# TruthArmor

**AI-powered personal, family & community digital safety.**
*Pause. Verify. Protect.*

TruthArmor helps people recognize scams, fraud, manipulation, identity-theft attempts, and unsafe online
interactions **before** they cause harm. It protects seniors, children and teens, families, job seekers, and
vulnerable adults — with a calm, respectful assistant, not a scary cybersecurity tool.

TruthArmor gives a **risk assessment**, never a guarantee. Every result explains *why* it was flagged, *what to
do next*, and *how to verify safely* through independent, official sources.

---

## What's in this repository

| Part | Folder | Status |
|---|---|---|
| Flutter mobile app (Android + iOS) | `lib/` | Phase 1–3 built, Phase 4 partly built |
| Secure AI backend (Firebase Cloud Functions, TypeScript) | `functions/` | Built + 8 passing tests |
| Brand assets (logo, app icon) | `assets/brand/` | Built |
| Unit + widget tests | `test/` | Written |
| Documentation | `docs/` | Architecture, setup, responsible AI, demo script |

### Features

- **9 categories** driven by one reusable *category engine*: Job, Bank/Payment, Tax/Government, Email/Text,
  Website/Link, Online Relationship, **Child & Teen Online Safety**, Property/Home, AI/Suspicious Message.
- **Quick Scan** — screenshot, photo, pasted text, or link → TruthArmor suggests a category → you confirm.
- **On-device OCR** (Google ML Kit) with a mandatory *review and edit* step. Screenshots never leave the phone.
- **Hybrid analysis engine** — fixed-weight rules + your answers + AI context + link reputation.
  A single AI number can never decide the result.
- **Transparent results** — risk level, 3–5 reasons, 3–5 actions, a breakdown by risk area, a separate
  *analysis confidence*, "How was this calculated?", and the standard disclaimer.
- **How to Verify Safely** — category-specific steps plus official help and reporting resources.
- **Simple Mode** for seniors — larger text and buttons, plainer words.
- **Safety Center** — 10 plain-language guides.
- **Privacy-first history** — only date, category, and risk level, on the device. Delete any scan.
- **Automatic redaction** of SSNs, card numbers, codes, passwords, and account numbers before any AI call
  (in the app *and* again on the server).
- **8 labeled DEMO EXAMPLES** (fictional) for presentations.

## DEMO vs PRODUCTION

| | Demo mode (default) | Production mode |
|---|---|---|
| How to run | `flutter run` | `flutter run --dart-define=TA_BACKEND_URL=https://…/analyze` |
| Rule engine, link checks, redaction, OCR, scoring | ✅ Real | ✅ Real |
| AI contextual analysis | ⚠️ **Demo service** — writes a summary from the rule findings, adds no signals, never changes the score. Results are labeled **"DEMO AI — NOT LIVE AI"**. | ✅ OpenAI via the secure backend |
| Link reputation (Google Safe Browsing) | ❌ | ✅ if `SAFE_BROWSING_API_KEY` is set |

> **Security:** the OpenAI API key lives **only** on the server as a Firebase secret. It is never in the app,
> never in this repository, and never sent to the phone.

## Quick start

```bash
# 1. Generate the Android/iOS platform folders (won't overwrite lib/ or test/)
flutter create . --project-name truth_armor --org org.trutharmor --platforms android,ios

# 2. Install packages and generate app icons
flutter pub get
dart run flutter_launcher_icons

# 3. Run in DEMO mode
flutter run

# 4. Run the tests
flutter test
cd functions && npm install && npm test
```

Then follow **[docs/SETUP.md](docs/SETUP.md)** for permissions (camera/photos), deploying the backend, and
switching to production mode.

## Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — folder structure, data flow, and how scoring works
- [docs/SETUP.md](docs/SETUP.md) — step-by-step setup for the app and the secure backend
- [docs/RESPONSIBLE_AI.md](docs/RESPONSIBLE_AI.md) — limits, wording rules, privacy, and safety design
- [docs/DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md) — a 3-minute judges' demo centered on senior + youth protection

## The core principle

**TruthArmor does not make decisions for the user. It helps the user make a better-informed decision.**

- **PAUSE** — don't react immediately.
- **VERIFY** — check through an independent, trusted source.
- **PROTECT** — don't give away money, credentials, or sensitive information until you are confident.
