# MemoCare — Google Play Store Listing

> Use this document to fill in your Play Console listing fields.  
> Copy-paste each section into the corresponding Play Console field.

**Repository:** [https://github.com/moyeenhaider3/memo-care](https://github.com/moyeenhaider3/memo-care)  
**GitHub Pages base (policies):** `https://moyeenhaider3.github.io/memo-care/`  
**No App Links / `.well-known` required** — MemoCare does not use HTTPS share links or verified deep links for content sharing.

---

## App Identity

| Field | Value |
| ----- | ----- |
| **Package name** | `io.github.moyeenhaider3.memocare` |
| **App name** | MemoCare |
| **Developer / support email** | _Replace with your public support address_ |
| **Category** | Health & Fitness _(or Medical — choose best fit in Play Console)_ |
| **Default language** | English (United States) or English (India) |

---

## Store Listing Details

### App title (max 30 characters)

```
MemoCare: Meds & Reminders
```

_(Shorten if needed to fit 30 characters.)_

### Short description (max 80 characters)

```
Never miss medication: smart chains, loud alarms, caregiver alerts — offline-first.
```

### Full description (max 4000 characters)

```
MemoCare — Smart Reminders for Medication & Daily Care

MemoCare helps you and your family stay on schedule with medication and linked daily tasks. Built with elderly users in mind: large controls, full-screen alarms, and clear confirmation — while staying powerful enough for busy professionals and parents managing a child’s routine.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT MAKES IT DIFFERENT

Linked reminder chains
Some doses only make sense after another step (e.g., after a meal). MemoCare connects related reminders so confirming one step unlocks the next — fewer missed doses and less confusion than a pile of unrelated alarms.

Escalating alerts
If you don’t respond, reminders can escalate from a gentle notification to sound, vibration, and a full-screen alarm you can’t miss — so important doses get attention.

Caregiver awareness
Optional caregiver contact: get alerted when a dose is missed (e.g., WhatsApp where configured), so family can check in.

Hydration & schedule at a glance
Track water intake and see today’s schedule on a simple home dashboard.

Offline-first core
Your reminders and history stay on your device. No account required for the core experience.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IDEAL FOR

• Anyone on multiple medications with before/after-meal timing
• Families supporting parents or grandparents at home
• Anyone who needs loud, unmistakable alarms until they tap Done, Snooze, or Skip

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IMPORTANT

MemoCare is a support tool, not a medical device. It does not replace professional medical advice. Always follow your doctor or pharmacist’s instructions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Download MemoCare and take control of your daily care routine.
```

---

## Tags / keywords (Play Console — use where applicable)

```
medication reminder
pill alarm
elderly care
medicine schedule
caregiver alert
```

---

## Graphics requirements

### App icon

- **Size:** 512 × 512 px (PNG, 32-bit; Play requirement for store listing asset)
- **In project:** `android/app/src/main/res/mipmap-*` / `flutter_launcher_icons`
- **Tool:** [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html) or [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

### Feature graphic

- **Size:** 1024 × 500 px (JPG or PNG)
- **Suggestion:** App name + tagline + screenshot of home or fullscreen alarm

### Screenshots (minimum 2; recommended 4–8)

Suggested captures:

1. Home — today’s schedule / hero card  
2. Fullscreen medication alarm (large buttons)  
3. Add reminder or chain context  
4. Settings / caregiver phone  
5. Missed reminders sheet (if applicable)  
6. History or confirmation / undo bar  

---

## Content rating questionnaire (guidance)

Answer honestly in Play Console. Typical answers for MemoCare:

| Topic | Likely answer |
| ----- | ------------- |
| Violence | No |
| Sexual content | No |
| User-generated content / social feeds | No |
| Location shared with others | No _(if you only use local scheduling)_ |
| Personal info | Disclose if you store name/phone locally or send caregiver messages |

**Expected rating:** Everyone or Teen — depends on your exact Data safety answers.

---

## Privacy policy

**URL for Play Console:**

```
https://moyeenhaider3.github.io/memo-care/privacy.html
```

Host the HTML in your **`moyeenhaider3/memo-care`** GitHub repo (e.g. `docs/privacy.html` on **GitHub Pages**).  
Describe: local storage (Drift/SQLite), notifications, optional caregiver messaging (e.g. WhatsApp intent), permissions (alarms, full-screen intent, phone for calls if used), and that you do **not** operate a social feed or shared link domain for this app.

---

## Terms of service (optional but recommended)

**URL:**

```
https://moyeenhaider3.github.io/memo-care/terms.html
```

Include disclaimer: app is not medical advice; limit liability; contact email.

---

## Data safety (Play Console)

Declare at minimum:

- Data collected (if any): e.g. “App functionality” — reminders stored on device.  
- Data shared: usually **none** to your servers if you have no backend.  
- Encryption: data at rest on device (optional note).  
- Deletion: user can clear app data / uninstall.

Adjust to match your actual implementation and caregiver features.

---

## Release checklist

### Before first upload

- [ ] Create release keystore **`memocare.jks`** (see `PRE_PUBLISH_TODO.md` and `android/key.properties.example`)
- [ ] Add **`android/key.properties`** (never commit)
- [ ] Confirm **`applicationId`** is `io.github.moyeenhaider3.memocare` in `android/app/build.gradle.kts`
- [ ] Replace launcher icons if still placeholder
- [ ] Feature graphic + screenshots
- [ ] Publish **privacy** (and **terms**) HTML under `moyeenhaider3.github.io/memo-care/`
- [ ] Build AAB: `flutter build appbundle --release`

### Play Console

1. Create the app in [Google Play Console](https://play.google.com/console)
2. Store listing: title, short/full description, graphics
3. App content: privacy policy URL, ads declaration (if no ads: declare **no ads**)
4. Content rating questionnaire
5. Target audience & news apps declarations as applicable
6. Upload signed **AAB** from `build/app/outputs/bundle/release/app-release.aab`
7. Internal testing → production when ready

---

## Signing configuration

See **`PRE_PUBLISH_TODO.md`** and **`android/key.properties.example`**.

- Keystore filename: **`memocare.jks`** (store outside git or under `android/` with `.gitignore` entry — already ignored)
- **`build.gradle.kts`** reads `key.properties` when present

---

## Build commands

```bash
cd memo_care
flutter clean && flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`
