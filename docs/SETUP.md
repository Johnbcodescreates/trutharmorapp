# TruthArmor Setup Guide

## Part 1 — Run the app (Demo mode)

**You need:** Flutter 3.22 or newer (`flutter --version`), Android Studio and/or Xcode.

```bash
cd truth_armor
flutter create . --project-name truth_armor --org org.trutharmor --platforms android,ios
flutter pub get
dart run flutter_launcher_icons
flutter run
```

`flutter create .` only adds the missing `android/` and `ios/` folders — it does not overwrite `lib/` or `test/`.

### Android permissions & settings

In `android/app/build.gradle` (or `build.gradle.kts`), make sure `minSdk` is at least **21**.

In `android/app/src/main/AndroidManifest.xml`, inside `<manifest>` (outside `<application>`), add so
"Website" and "Call" buttons work on Android 11+:

```xml
<queries>
  <intent><action android:name="android.intent.action.VIEW" /><data android:scheme="https" /></intent>
  <intent><action android:name="android.intent.action.DIAL" /><data android:scheme="tel" /></intent>
</queries>
```

### iOS permissions & settings

In `ios/Podfile`, set `platform :ios, '15.5'` (required by Google ML Kit).
In `ios/Runner/Info.plist` add:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>TruthArmor reads text from screenshots you choose. The image stays on your device.</string>
<key>NSCameraUsageDescription</key>
<string>Take a photo of a letter or screen so TruthArmor can read the text. The image stays on your device.</string>
```

> ML Kit OCR runs on real iPhones and Android devices. Some Apple-silicon iOS *simulators* aren't supported by
> ML Kit — test screenshot reading on a real device if the simulator build fails.

---

## Part 2 — Deploy the secure backend (Production mode)

The backend is a Firebase Cloud Function. It holds the OpenAI key as a **secret**; the app never sees it.

1. Create a Firebase project at <https://console.firebase.google.com> and upgrade it to the **Blaze** plan
   (required for Cloud Functions that call external APIs). **Set a budget alert** in Google Cloud Billing, and a
   **monthly usage limit** in your OpenAI account.
2. Install tools and log in:
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase use --add          # pick your project
   ```
3. Store secrets (you'll be prompted to paste each value — it is never written to the repo):
   ```bash
   firebase functions:secrets:set OPENAI_API_KEY
   firebase functions:secrets:set SAFE_BROWSING_API_KEY    # type "none" to skip link reputation
   ```
   Optional: choose the model (default `gpt-4o-mini`) by creating `functions/.env` with `OPENAI_MODEL=...`.
4. Test and deploy:
   ```bash
   cd functions && npm install && npm test && cd ..
   firebase deploy --only functions
   ```
   Copy the function URL it prints (ends in `/analyze`).
5. Run the app in production mode:
   ```bash
   flutter run --dart-define=TA_BACKEND_URL=https://us-central1-YOUR-PROJECT.cloudfunctions.net/analyze
   ```
   The **DEMO MODE** badge disappears from Home, and Settings → Analysis engine says "Connected".

### Local testing with the emulator (optional)

```bash
cp functions/.secret.local.example functions/.secret.local    # then put your key in it (gitignored)
cd functions && npm run serve
# Android emulator:
flutter run --dart-define=TA_BACKEND_URL=http://10.0.2.2:5001/YOUR-PROJECT/us-central1/analyze
```

(For plain `http` on Android, add `android:usesCleartextTraffic="true"` to the **debug** manifest only.)

### Link reputation (optional)

Create an API key for the **Safe Browsing API** in Google Cloud and store it as `SAFE_BROWSING_API_KEY`.
The Safe Browsing Lookup API is for non-commercial use; for a commercial launch switch to the **Web Risk API**
(`functions/src/reputation.ts` has one function to change).

### Hardening before a public launch (Phase 4)

- **Firebase App Check:** add `firebase_core` + `firebase_app_check` to the app, send the token in the
  `X-Firebase-AppCheck` header from `BackendAnalysisService`, then set `REQUIRE_APP_CHECK=true` in
  `functions/.env`. This stops other apps from using your endpoint.
- Replace the in-memory rate limiter with a shared store if you scale beyond one instance.
- Review OpenAI's data-usage settings for your organization.

---

## Never commit secrets

`.gitignore` already excludes `.env`, `functions/.secret.local`, `google-services.json`,
`GoogleService-Info.plist`, and `lib/firebase_options.dart`. The app contains **no** API keys — only the public
backend URL, passed at build time.
