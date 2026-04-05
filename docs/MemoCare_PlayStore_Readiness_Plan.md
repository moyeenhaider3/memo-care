# MemoCare — Play Store Readiness Plan
**Flutter App · Android · Step-by-Step Verification & Execution Guide**
*Version 2.0 — March 2026*

---

## How to Use This Document

Work through each Phase in order. Every section gives you:
- **What to check** — the exact file, setting, or screen to inspect
- **What correct looks like** — the pass condition
- **What to do if it fails** — the corrective action

**Symbol key:**
- ✅ = Gate check — must pass before moving to the next phase
- ⚠️ = Should be resolved but will not crash the app
- 🗑️ = Remove entirely from the codebase
- 🔒 = Feature intentionally locked as "Coming Soon" for this release
- 🔄 = Self-correction trigger — see protocol below

---

## Self-Correcting Protocol (Read First)

The project is described as "almost complete but buggy." This means features exist in some form but do not fully meet expectations. This plan is the source of truth. Follow this loop whenever anything fails:

**Step 1 — Identify the gap.**
Run the check described in this plan. If it fails, note exactly what the actual behaviour is versus what this plan says it should be.

**Step 2 — Read this plan for context.**
Before touching code, re-read the full section for that feature. Confirm the expected behaviour described here still makes sense given the current state of the app. If the feature as described is overcomplicated, out of scope, or contradicts something already built that is working well, go to Step 3. Otherwise go to Step 4.

**Step 3 — Update the plan first, then implement.**
If the expected behaviour in this document needs to change (scope reduction, simplified flow, discovered edge case), write the corrected expectation here in the plan before touching the implementation. This keeps the plan and the codebase in sync. Do not implement something that contradicts this document without updating the document first.

**Step 4 — Fix the implementation to match the plan.**
With a clear, updated expectation in writing, fix the code. Then re-run the check from Step 1. The check must now pass before moving forward.

**Step 5 — Mark the check as resolved.**
Put a ✅ next to the check in your working copy of this document so you always know the current state.

This loop prevents the common failure mode of fixing one bug and introducing two others because the expected state was never clearly defined.

---

## Scope Decisions for This Release

These are firm decisions — not open questions. They must be reflected throughout the codebase before any other work begins.

### 🗑️ REMOVED: Ramadan / Fasting Mode
Remove every trace. See Pre-Work section for the full checklist.

### 🗑️ REMOVED: Complex Caregiver System
The caregiver portal (P9), caregiver SMS gateway, WorkManager caregiver sync, push-to-caregiver, remote reminder add, and end-of-day report features are all removed. The replacement is a single WhatsApp message sent from the user's device when a reminder is escalated to MISSED state and no response is received. No extra service, no extra plugin, no backend.

**What replaces it:**
- In Settings: one field — "Caregiver WhatsApp Number" (phone number with country code)
- When a reminder reaches MISSED state: the app opens WhatsApp via deep link with a pre-filled message. The message reads: "Hi, [PatientFirstName] missed their [MedicineName] reminder at [Time]. Please check on them."
- The `url_launcher` plugin (already needed for the call feature) handles this. No new dependency required.
- The user can tap "Send WhatsApp Alert" from the MISSED notification or from within the app — or it auto-opens depending on settings.
- If WhatsApp is not installed on the device, the URL fallback opens a browser to `wa.me` which works on any device.

**What this means for the codebase — remove:**
- P9 Caregiver Portal screen and its route
- WorkManager tasks related to caregiver sync or end-of-day report
- Any SMS plugin (`telephony`, `sms_advanced`) and its Manifest permissions (`SEND_SMS`)
- Caregiver-specific push notification channels
- "Caregiver link" onboarding slide (Slide 4) — replace with a simpler "Add caregiver number" input that just stores a phone number in SharedPreferences
- "Send Nudge" feature from caregiver side (caregiver has no app view at all now)
- End-of-day summary dispatch

**What remains:**
- Settings field: caregiver WhatsApp number
- MISSED state triggers a WhatsApp deep-link message
- Onboarding Slide 4 retains the caregiver number input field but no longer references linking accounts or app installation

### 🔒 SAY IT MODE — Coming Soon
The "Say It" tab on the Add Reminder screen (P4) is retained in the UI. It must be visible and clearly labelled. However, tapping the tab shows a "Coming Soon" state — not a functional voice/NLP input. The "Build It" tab is the default and fully functional.

**What this means in the codebase:**
- The "Say It" tab renders with a distinct locked state: a centred illustration, the label "Voice Setup — Coming Soon", and a subtext: "For now, use Build It to add your reminders."
- The mic icon is greyed out and non-interactive
- No speech-to-text plugin initialisation, no NLP parser call
- Remove `speech_to_text` from `pubspec.yaml` if it is only used for this feature
- Remove `RECORD_AUDIO` permission from the Manifest if no other feature uses it
- The example chips row ("Before meal medicine", "After meal", etc.) is also hidden in this tab since it implied NLP functionality

---

## Pre-Work: Full Scope Cleanup Checklist

Complete every row in this table before running Phase 1. Run `flutter analyze` after each major removal, not just at the end.

### 🗑️ Ramadan / Fasting Mode Removal

| Location | What to Remove |
|---|---|
| **P7 Screen** | Delete the entire screen file and remove its route from the route table |
| **P6 Template Library** | Remove the "Ramadan Medicine Pack" template card and the "Fasting" filter chip from the category chip strip |
| **P4 Add Reminder — Build It** | Remove "Sehri" and "Iftar" from the anchor event dropdown |
| **P10 Settings** | Remove the entire "Fasting Mode" settings group (toggle + location picker for prayer times) |
| **P5 Today's Schedule** | Remove the gold Sehri/Iftar horizontal divider line and its rendering logic |
| **Route table** | Remove any named route for the Fasting/Ramadan screen |
| **Bottom Nav / Drawer** | Remove any Ramadan tab, icon, or menu item |
| **Reminder Chain Engine** | Remove anchor event types `sehri` and `iftar`; remove all `isFastingMode` conditional branches |
| **Notification channels** | Remove channels named for Sehri/Iftar alerts |
| **pubspec.yaml / assets** | Remove prayer-time calculation package; remove Ramadan-specific images, animations, audio |
| **Strings / l10n files** | Search for and delete all keys containing "ramadan", "sehri", "iftar", "fasting" |

### 🗑️ Caregiver Complex System Removal

| Location | What to Remove |
|---|---|
| **P9 Screen** | Delete the Caregiver Portal screen file and its route |
| **Onboarding Slide 4** | Keep the screen but remove all language about "account linking", "they will receive alerts via the app", "Caregiver icon: two overlapping silhouettes in teal". Replace with plain language: "Add their WhatsApp number so we can alert them if you miss a reminder." |
| **WorkManager tasks** | Remove any task registered for caregiver sync, end-of-day report, or missed-dose push dispatch |
| **SMS plugin** | Remove `telephony` or `sms_advanced` from `pubspec.yaml` if present |
| **Manifest** | Remove `SEND_SMS` permission; remove any SMS receiver/service declarations |
| **Caregiver push channels** | Remove notification channels used to push alerts to a caregiver device |
| **P10 Settings — Caregivers group** | Remove "linked caregiver card row", remove ability to view/remove a linked caregiver account. Replace the group with a single row: "Caregiver WhatsApp Number" — shows the stored number with an edit pencil icon |
| **P2 Home Dashboard** | Remove any "emergency contact call shortcut" that required account linking |
| **P8 History** | Remove "share to caregiver" option if it sent to an app account. Keep "Export PDF" for sharing to any app including WhatsApp |
| **P5 / P8** | Remove any caregiver bell icon logic that referenced the old push system. The bell icon can remain but now means "WhatsApp alert was sent" |

### 🔒 Say It Mode — Convert to Coming Soon

| Location | What to Change |
|---|---|
| **P4 Screen — Say It tab** | Replace the functional input area with the Coming Soon state (illustration + label + subtext) |
| **Mic button** | Set to non-interactive / greyed out |
| **Example chips row** | Hide entirely in the Say It tab |
| **speech_to_text plugin** | Remove from `pubspec.yaml` if only used here |
| **RECORD_AUDIO permission** | Remove from Manifest if no other feature uses it |
| **NLP parser / intent parser** | Remove or disable — do not call it from any active code path |
| **Default tab on open** | Must be "Build It", not "Say It" |

After completing all three removal checklists: run `flutter analyze`. Fix every error before proceeding. Zero errors is the gate to Phase 1.

---

## PHASE 1 — Plugin & Dependency Verification

*Goal: Every package in `pubspec.yaml` is correctly installed, correctly configured in Android, and actually serves an active feature. No orphan dependencies.*

---

### 1.1 `pubspec.yaml` Full Audit

**Step 1 — Dependency hygiene check.**
Open `pubspec.yaml`. For each package listed, ask: "Which screen or feature in this app uses this?" If you cannot name a specific feature, the package is an orphan — remove it.

**Step 2 — Version currency check.**
For each remaining package, visit `pub.dev`. Confirm the version is within one major version of the current stable release. Note any package requiring migration.

**Step 3 — Conflict resolution.**
Run `flutter pub deps` in terminal. If any package shows a version conflict in the dependency tree, resolve it before continuing.

**Step 4 — Clean install.**
Run `flutter pub get`. Must complete with zero errors. If it fails, the constraint causing the failure must be resolved before proceeding.

---

### 1.2 Plugin-by-Plugin Verification

Work through each plugin category below. For each: check pubspec, check Android config, check Dart-side initialisation, run the runtime test.

---

#### ✅ Plugin 1: Local Notifications — `flutter_local_notifications`

**What it does in MemoCare:** Delivers all three notification layers (soft banner, audio alert, full-screen takeover), and provides DONE / SNOOZE / SKIP action buttons directly on the notification.

**pubspec:** Package is listed. Version is `^17.x` or later.

**Dart-side:**
- `FlutterLocalNotificationsPlugin` is initialised in `main.dart` before `runApp()`.
- `AndroidInitializationSettings` references an icon name (e.g., `'@mipmap/ic_launcher'` or a custom drawable). Open `android/app/src/main/res/drawable/` and confirm that exact file exists. If the filename in code does not match an actual file, notifications fire silently with no icon — or fail entirely on some devices.
- Three notification channels are created at initialisation: `soft_reminders` (default importance), `audio_reminders` (high importance), `critical_alerts` (max importance). Confirm each channel ID is a unique string that does not change between app versions (changing a channel ID after release means old notifications on user devices lose their settings).

**Manifest checks:**
- `android.permission.POST_NOTIFICATIONS` — required for Android 13+
- `android.permission.VIBRATE`
- `<receiver>` for `ScheduledNotificationReceiver` inside `<application>` tag
- `<receiver>` for `BootReceiver` with `android.intent.action.BOOT_COMPLETED` intent filter — plus `RECEIVE_BOOT_COMPLETED` uses-permission. Also add `android.intent.action.QUICKBOOT_POWERON` as a second intent filter on the same receiver (covers Huawei and some OnePlus variants that use a non-standard boot action).

**build.gradle:** `compileSdkVersion` is 34 or above.

**End-to-end sense check — what the user actually experiences:**
Set a test reminder 2 minutes in the future. Lock the phone. When the reminder fires:
- A banner notification appears with the medicine name, dose, and instruction visible without opening the app.
- Three action buttons are visible: DONE, SNOOZE, SKIP.
- Tapping DONE from the notification shade (without opening the app) marks the reminder as done and advances the chain.
- Tapping SNOOZE re-fires after the configured snooze duration.
- Tapping SKIP marks as skipped and suspends any downstream chain reminders for that slot.

If any of these three actions does not work from the notification shade, the `PendingIntent` for that action is broken — each action button needs its own valid PendingIntent pointing to a BroadcastReceiver that handles the action and updates the database.

---

#### ✅ Plugin 2: Exact Alarm Scheduling

**Expected package:** `flutter_local_notifications` with `AndroidScheduleMode.exactAllowWhileIdle`, OR `android_alarm_manager_plus`.

**Why it matters:** Without exact alarms, Android Doze mode delays reminders by up to 15 minutes. For medication timing this is clinically unacceptable.

**Manifest checks:**
- `android.permission.SCHEDULE_EXACT_ALARM`
- For API 33+: `android.permission.USE_EXACT_ALARM`
- At runtime: code must call `canScheduleExactAlarms()` before scheduling. If it returns false, redirect the user to `ACTION_REQUEST_SCHEDULE_EXACT_ALARM` system settings screen. This must be a user-facing prompt with a clear explanation — not a silent failure.

**If using `android_alarm_manager_plus`:** `<service>` for `AlarmService` must be declared in the Manifest.

**End-to-end sense check:**
Schedule a reminder for exactly 90 seconds ahead. Enable Battery Saver on the test device. The notification must fire within 5 seconds of the target time. If it arrives late, the alarm mode is not exact — this is a release blocker.

---

#### ✅ Plugin 3: Background Task Execution — `workmanager`

**What it does in MemoCare (revised scope):** Handles chain re-scheduling after a user confirms a step (the next step in the chain must be scheduled from a background context). Also handles MISSED state detection — if no confirmation is received within the escalation window, WorkManager fires the WhatsApp alert trigger.

**Note:** WorkManager is no longer used for caregiver sync or end-of-day reports. If any registered task name references those, remove the registration and its callback.

**Manifest checks:**
- `WorkManagerInitializer` declared as `<provider>` inside `<application>`
- `android.permission.FOREGROUND_SERVICE` if any task runs as foreground

**build.gradle:** `minSdkVersion` 21 or above.

**Dart-side:**
- `Workmanager().initialize()` called before `runApp()`.
- Every registered task name maps to a handler in `callbackDispatcher`. Orphan task names (registered but no handler) will cause a crash in background.
- Confirm `callbackDispatcher` is a top-level function (not a class method) — WorkManager requires this.

**End-to-end sense check:**
Kill the app completely (swipe away from recents). Confirm that a pending reminder still fires at the correct time. Confirm that the MISSED detection still triggers (WhatsApp alert opens or queues) even when the app is not in the foreground.

---

#### ✅ Plugin 4: Full-Screen Lock-Screen Alert (Layer 3 Escalation)

**What it does:** When a user has not responded to Layers 1 and 2, the P3 full-screen takeover fires — even on the lock screen.

**This is the most important UX moment in the app for elderly users.** If this screen does not appear reliably on the lock screen, the core safety value proposition fails.

**Manifest checks:**
- `android.permission.USE_FULL_SCREEN_INTENT` — without this, the notification silently downgrades to a heads-up banner
- `android.permission.WAKE_LOCK` — required to light up the screen when the alert fires
- Main `<activity>` must have `android:showWhenLocked="true"` and `android:turnScreenOn="true"`
- For Android 14+: `USE_FULL_SCREEN_INTENT` is a restricted permission requiring user approval. Confirm your onboarding flow or first-launch sequence directs the user to grant this. Handle the denial gracefully: fall back to Layer 2 (loud audio + vibration) instead of crashing.

**End-to-end sense check:**
1. Set a reminder 2 minutes ahead. Do not respond to the soft banner (Layer 1) or audio alert (Layer 2).
2. Lock the phone screen.
3. After the escalation delay, the P3 full-screen alert must appear ON the lock screen.
4. All three buttons (DONE / SNOOZE / SKIP) must be tappable WITHOUT unlocking the device first.
5. The pulsing background animation must be playing.
6. The medicine name and instruction must be readable at normal reading distance from a flat surface (i.e., when the phone is sitting on a table and an elderly person leans over to read it).

Test this on at least two real devices. Emulators do not reliably reproduce lock-screen behaviour.

---

#### ✅ Plugin 5: Local Database / Offline Storage

**Expected package:** `hive` + `hive_flutter`, OR `sqflite`, OR `isar`.

**Core requirement:** 100% of reminder data lives on device. The app must work with no internet, indefinitely.

**pubspec checks:**
- Storage package present.
- Code-generation packages (`hive_generator`, `build_runner` for Hive; `isar_generator` for Isar) are under `dev_dependencies` not `dependencies`.
- `path_provider` is present (Hive and Isar need it for file paths).

**Dart-side checks:**
- Database initialised before `runApp()`.
- All model adapters registered before first use (for Hive: `Hive.registerAdapter()`).
- Schema version is tracked. If the app is updated and the data model changes, a migration path exists. Unhandled schema changes silently wipe user data on update — a catastrophic outcome for a medication reminder app.

**Data that must persist across app restarts:**
- All reminder definitions (name, type, anchor, offset, repeat pattern)
- All chain relationships (which reminder triggers which)
- All confirmation history (DONE/SNOOZE/SKIP/MISSED with timestamps)
- User settings (text size, contrast, snooze duration, caregiver WhatsApp number, elderly mode toggle)
- Template activation records

**End-to-end sense check:**
1. Create 3 reminders with a chain relationship.
2. Confirm DONE on one.
3. Force-close the app via Android recents.
4. Reopen the app.
5. All 3 reminders must still be present. The confirmed one must show as done. The chain must reflect the correct state.
6. The next pending reminder must still be scheduled and fire at the correct time.

---

#### ✅ Plugin 6: Permission Handling — `permission_handler`

**Permissions MemoCare requires at runtime for this release:**

| Permission | When Requested | Fallback if Denied |
|---|---|---|
| `notification` | First launch / onboarding | App warns that reminders will not fire; cannot function without this |
| `scheduleExactAlarm` | First launch | Redirect to system settings; explain why exact timing is required |
| `phone` (CALL_PHONE) | When user adds a "Call relative" reminder type | Show manual dial instruction instead |
| `fullScreenIntent` (Android 14+) | First launch | Downgrade to Layer 2 alert; warn user |

**Permissions that must NOT be requested (removed with Ramadan and old caregiver):**
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `SEND_SMS`
- `RECORD_AUDIO` (removed with Say It mode — remove from Manifest if present)

**Manifest audit:** Every permission your code calls `Permission.request()` on must also appear as a `<uses-permission>` in the Manifest, and vice versa. Mismatch in either direction causes silent failures or Play Store rejections.

**End-to-end sense check — permission denial flows:**
- Deny notification permission on first launch. The app must show a persistent in-app warning and an easy path to re-grant, not crash.
- Deny exact alarm permission. The app must redirect to system settings with a clear explanation.
- For each denied permission, the specific feature that needs it must degrade gracefully, and all other features must continue working.

---

#### ✅ Plugin 7: WhatsApp Alert — `url_launcher` (replaces all caregiver plugins)

**What it does:** When a reminder reaches MISSED state, the app constructs a WhatsApp deep link and opens it. No backend, no SMS, no extra plugin.

**Plugin:** `url_launcher` — already needed for the phone call feature. No new dependency.

**How the link is constructed:**
The URL format is: `https://wa.me/[E164PhoneNumber]?text=[URLEncodedMessage]`
- Phone number: stored in Settings as caregiver WhatsApp number, must be stored in E.164 format (e.g., `+919876543210` becomes `919876543210` in the URL — strip the `+` sign).
- Message: `"Hi, [PatientName] missed their [MedicineName] reminder at [Time]. Please check on them."`
- The message must be URL-encoded before embedding in the link.

**Manifest checks:**
- `INTERNET` permission is present (needed for WhatsApp to open correctly)
- For Android 11+ (API 30+): add a `<queries>` block with `<package android:name="com.whatsapp"/>` and `<package android:name="com.whatsapp.w4b"/>` (WhatsApp Business). This allows the app to detect if WhatsApp is installed.

**Dart-side checks:**
- `canLaunchUrl()` is checked before `launchUrl()`.
- If WhatsApp is not installed: fall back to opening `https://wa.me/...` in the browser (this still works — the recipient gets a web WhatsApp message or WhatsApp app prompt).
- The caregiver number field in Settings must validate E.164 format on input.
- If no caregiver number is set, the MISSED state still logs correctly — but no WhatsApp message is sent. The user is shown an in-app notice: "No caregiver number set. Go to Settings to add one."

**End-to-end sense check:**
1. Set a caregiver number in Settings.
2. Trigger a MISSED event (set reminder 1 min ahead, do not respond, wait for escalation).
3. The app opens WhatsApp with the pre-filled message. The message is correctly formatted with the medicine name, time, and patient name.
4. The caregiver number is correct in the WhatsApp "To" field.
5. The send action is left to the user — the app does not auto-send (WhatsApp's API does not allow auto-send; the user must tap Send).
6. After WhatsApp opens, the app resumes correctly when the user returns to it.

---

#### ✅ Plugin 8: Text-to-Speech — `flutter_tts`

**What it does:** Reads reminders aloud for elderly users. Fires when a notification appears and when the full-screen alert (P3) is active.

**Manifest checks:** For API 30+, add a `<queries>` block with the TTS intent so the engine can be detected. No permission required.

**Dart-side checks:**
- `FlutterTts` is initialised once (in a service or provider), not on every notification.
- `setLanguage()` is called with a fallback language code.
- The spoken message format: "Time to take [MedicineName], [Dose], [Instruction]." — all three parts must be present.
- `stop()` is called when the alert is dismissed (to prevent speech continuing in the background).
- TTS is disabled when the device is on silent/DND — confirm it does not override system volume.

**End-to-end sense check:**
1. Enable text-to-speech in Settings (or confirm it is on by default).
2. Set a reminder 1 minute ahead.
3. When the reminder fires, the phone should speak the reminder aloud.
4. Tap DONE. Speech stops immediately.
5. Tap SNOOZE. Speech stops. When re-fired, it speaks again.

---

#### ✅ Plugin 9: URL Launcher — `url_launcher`

**What it does:** (a) WhatsApp caregiver alert (described above), (b) One-tap call for "Call a relative" reminder type.

**Manifest checks:**
- `android.permission.CALL_PHONE`
- `<queries>` block with `<intent><action android:name="android.intent.action.DIAL"/>` for Android 11+

**Dart-side:**
- For calls: `launchUrl(Uri(scheme: 'tel', path: phoneNumber))` — not a raw string.
- `canLaunchUrl()` checked before every launch.
- Handle the case where no dialler app is installed gracefully.

**End-to-end sense check:**
1. Create a "Call Son" reminder for Sunday 11 AM.
2. When it fires, the notification shows a "Call Now" action button.
3. Tapping it opens the phone dialler with the number pre-filled.
4. The user taps the green call button — call connects.
5. After the call, returning to the app works correctly.

---

#### ✅ Plugin 10: PDF Generation — `pdf` + `printing` or `open_filex`

**What it does:** "Export PDF" on the History screen (P8). Generates a compliance report that can be shared (to WhatsApp, email, or any share target).

**Manifest checks:** Do NOT request `WRITE_EXTERNAL_STORAGE` (deprecated for API 29+). Save to `getApplicationDocumentsDirectory()` or use the `share_plus` plugin to share without saving permanently.

**Dart-side:**
- PDF contains: patient name, date range, list of reminders with their state (done/snoozed/missed/skipped) and actual confirmation time.
- PDF is readable — minimum 11pt text, logical structure (header, date, table of entries).
- After generation, a share sheet opens automatically (not just a save confirmation).

**End-to-end sense check:**
1. Have at least one day of mixed reminder history (done, missed, skipped).
2. Open History → tap "Export PDF."
3. A share sheet appears. Share to WhatsApp as a file attachment — confirm the file arrives correctly.
4. Open the PDF. Confirm all data is accurate and readable.
5. Confirm the PDF contains no Ramadan references.

---

#### ✅ Plugin 11: Charts — `fl_chart` or equivalent

**What it does:** Donut/ring chart on the History screen (P8) showing compliance breakdown.

**Dart-side:**
- Chart reads live data from the local database — not hardcoded or mocked.
- Handles edge cases: 100% done (all green), 0% done (all red/grey), no data for the period (show empty state, not an empty/broken chart).
- If using Syncfusion: licence key is initialised at app start — missing it puts a watermark on the chart in release builds.

**End-to-end sense check:**
1. Check History with no data for the selected week. Confirm the empty state illustration appears, not a broken chart.
2. Add a day's worth of mixed data. Confirm the ring chart updates correctly.
3. Tap the week selector for different days. Confirm the chart and log both update.

---

#### ⚠️ Plugin 12: Shared Preferences — `shared_preferences`

**What it does:** Persists all Settings values between launches.

**Dart-side:** Every setting in P10 — text size preference, high contrast toggle, dark mode toggle, snooze duration, escalation delay, elderly mode toggle, caregiver WhatsApp number — must be both written on change and read on launch. Confirm default values are set for first launch (no setting should be `null` on a fresh install).

---

#### ⚠️ Plugin 13: Connectivity — `connectivity_plus`

**What it does:** Detects network state so WhatsApp deep links and any optional cloud backup only attempt when connected.

**Dart-side:** All core features (local notifications, chain logic, confirmation states, local database) work with zero network. Network-dependent actions (WhatsApp message open, cloud backup if implemented) are wrapped in a connectivity check and show a clear message if offline rather than failing silently.

---

## PHASE 2 — Android Configuration Deep-Dive

*Goal: Every Android-level setting is correct for a production release.*

---

### 2.1 `android/app/build.gradle` — Value-by-Value Table

| Setting | Required Value | What Breaks if Wrong |
|---|---|---|
| `compileSdkVersion` | 34 or 35 | Support library conflicts |
| `targetSdkVersion` | 34 or 35 | Play Store rejects SDK < 33 as of 2024 |
| `minSdkVersion` | 21 | WorkManager minimum; most plugins fail below this |
| `applicationId` | Unique reverse-domain, NOT `com.example.*` | Play Store rejects example IDs |
| `versionCode` | Integer starting at 1 | Must increment for every Play Store upload |
| `versionName` | `"1.0.0"` | Shown to users on Play Store |
| `multiDexEnabled` | `true` | Method count overflow crash on API < 21 without this |

---

### 2.2 `AndroidManifest.xml` — Full Permissions Audit

**Must be present:**
- `android.permission.INTERNET`
- `android.permission.VIBRATE`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.SCHEDULE_EXACT_ALARM`
- `android.permission.USE_EXACT_ALARM` (API 33+)
- `android.permission.USE_FULL_SCREEN_INTENT`
- `android.permission.FOREGROUND_SERVICE`
- `android.permission.CALL_PHONE`
- `android.permission.WAKE_LOCK`
- `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`

**Must NOT be present (remove if found):**
- `ACCESS_FINE_LOCATION` — removed with Ramadan
- `ACCESS_COARSE_LOCATION` — removed with Ramadan
- `SEND_SMS` — removed with complex caregiver
- `RECORD_AUDIO` — removed with Say It mode (unless another feature needs it)
- `READ_EXTERNAL_STORAGE` (deprecated for API 29+)
- `WRITE_EXTERNAL_STORAGE` (deprecated for API 29+)

**Application attributes:**
- `android:label` = `"MemoCare"` — not `"flutter_app"`, not `"demo"`
- `android:icon` = app-specific icon, not the default Flutter icon
- `android:roundIcon` = round icon variant

**Activity:**
- Main activity: `android:exported="true"`
- Main activity: `android:launchMode="singleTop"` (prevents duplicate instances on notification tap)
- Main activity: `android:showWhenLocked="true"` and `android:turnScreenOn="true"`

**Receiver declarations (inside `<application>`):**
- `BootReceiver` with `BOOT_COMPLETED` + `QUICKBOOT_POWERON` intent filters
- `ScheduledNotificationReceiver` (from `flutter_local_notifications`)

**Provider declarations:**
- `WorkManagerInitializer` as `<provider>`

**Queries block (API 30+):**
- WhatsApp package queries: `com.whatsapp` and `com.whatsapp.w4b`
- Dial intent query: `android.intent.action.DIAL`
- TTS intent query if needed

---

### 2.3 Notification Channels

Three channels must exist. Verify in code AND on device (Settings → Apps → MemoCare → Notifications).

| Channel ID | Display Name | Importance | Used For |
|---|---|---|---|
| `soft_reminders` | "Reminders" | DEFAULT | Layer 1: silent banner |
| `audio_reminders` | "Urgent Reminders" | HIGH | Layer 2: sound + vibration |
| `critical_alerts` | "Critical Alerts" | MAX | Layer 3: full-screen takeover |

**Confirm:** No channel ID or name references "ramadan", "sehri", "iftar", "caregiver_push", or "fasting".

**Important:** Channel importance cannot be changed after the channel is created on a user's device. If a channel was created with wrong importance in a previous build, you must use a new channel ID and delete the old one. Document the channel IDs — they are permanent.

---

### 2.4 Battery Optimisation

OEM battery killers (Xiaomi, Samsung, Huawei, Oppo) will terminate background processes and block scheduled alarms. This breaks the core function of a reminder app.

**What must happen:**
1. On first launch (within onboarding or immediately after), the app shows a system dialog or redirects the user to battery settings to whitelist MemoCare.
2. The `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission is in the Manifest.
3. There is a clear in-app explanation: "To ensure you never miss a reminder, please allow MemoCare to run in the background."
4. The app handles the case where the user denies this — it should show a persistent warning on the Home screen, not crash.

**Test:** On a Xiaomi or Samsung device, set a reminder for 10 minutes ahead, force-close the app, and lock the device. The reminder must fire. If it does not, the battery optimisation exemption is not working.

---

### 2.5 ProGuard / R8 Rules (`android/app/proguard-rules.pro`)

Keep rules must exist for:
- All local database model classes (Hive boxes/adapters, Isar schemas, or SQLite-mapped classes)
- WorkManager task class names (fully qualified — reflection-based, so R8 will strip them without a keep rule)
- Any serialisation library models (Gson, Moshi, etc.)

**Verification method:** Build a release APK (`flutter build apk --release`). Install and run through each Phase 4 scenario. If something works in debug but crashes in release, a missing keep rule is the first thing to check.

---

### 2.6 Gradle Wrapper Compatibility

Open `android/gradle/wrapper/gradle-wrapper.properties`. Confirm `distributionUrl` points to a stable Gradle version compatible with your AGP (Android Gradle Plugin) version. As of 2026, AGP 8.x requires Gradle 8.x. A mismatch produces build errors that look unrelated to the actual problem.

---

## PHASE 3 — UI Audit: Screen-by-Screen Verification

*Goal: Every screen matches the design spec. Work through each screen on a real Android device at standard resolution.*

**Global design tokens — apply to every screen:**

| Token | Value |
|---|---|
| Background | `#F7F9FC` |
| Card background | `#FFFFFF` with `0px 2px 12px rgba(0,0,0,0.07)` shadow |
| Primary / Deep Navy | `#1A3A5C` |
| Accent / Sky Blue | `#4A90D9` |
| Success / Calm Green | `#27AE60` |
| Warning / Amber | `#F39C12` |
| Danger / Soft Red | `#E74C3C` |
| Font | Roboto (Android). H1: 28pt Bold. H2: 22pt SemiBold. Body: 17pt Regular. Caption: 14pt. |
| Minimum body text | **17pt** — hard floor, elderly mode bumps to 21pt |
| Minimum tap target | **44×44pt** — elderly mode bumps to 64pt height |
| Card radius | 16px |
| Button radius | 14px |
| Chip/pill radius | 999px |
| Screen padding | 20px edges |
| Card internal padding | 20px |
| Section gap | 24px |
| Between related items | 12px |
| Bottom Nav | 5 tabs: Home \| Today \| Add \| History \| Profile |

**Before checking any screen:** Enable Elderly Mode in Settings. Verify text increases by +4pt across all screens and tap targets expand. Then disable Elderly Mode and continue the screen-by-screen audit at standard size.

---

### P1 — Onboarding (5 Slides)

**Slide 1 — Welcome:**
- Full-screen illustration, navy-to-sky-blue gradient background
- "Never miss what matters." text ≥22pt, centred
- "Get Started" CTA: full-width pill, 52pt height, white text on `#1A3A5C`
- No back arrow, no skip button on this slide

**Slide 2 — Who Are You:**
- Three stacked cards, each 80pt tall
- Icons: walking cane / briefcase / family
- Selected card: `#4A90D9` border + soft blue fill
- Selecting one card deselects the others (single selection only)

**Slide 3 — Accessibility Check:**
- Two toggle rows: Large Text Mode (Aa icon) + High Contrast Mode (eye icon)
- A sample paragraph below that updates live as toggles change — verify this actually updates on toggle
- Note: "You can change these anytime in Settings."

**Slide 4 — Caregiver Number (revised):**
- Title: "Connect a family member"
- Subtitle: "Add their WhatsApp number so we can alert them if you miss a reminder."
- Phone number input field with country code picker
- "Skip for now" text link (lower priority than the CTA)
- ⚠️ Confirm all language about "linking accounts", "they will receive alerts via the app", or "install MemoCare" has been removed
- ⚠️ Confirm the caregiver icon is a simple WhatsApp icon or phone icon — not the old "two overlapping silhouettes" implying an app-to-app connection

**Slide 5 — All Set:**
- Gentle confetti animation (5–6 soft dots — not overwhelming)
- `#27AE60` checkmark circle
- "You are all set!"
- "Go to Dashboard" CTA
- No back or skip button

**Across all slides:**
- Progress dots at top
- Back arrow on slides 2–4
- Skip button on slides 2–4 only
- Transition: horizontal 280ms slide

**End-to-end sense check for Onboarding:**
After slide 5 and tapping "Go to Dashboard":
- The home screen must NOT be an empty, unexplained blank screen. It must show a clear CTA or empty state guiding the user to add their first reminder.
- If the user entered a caregiver number on slide 4, it must be pre-saved and visible in Settings → Caregiver WhatsApp Number.
- If the user chose a profile type on slide 2, the home screen should reflect a relevant suggestion for their type.

---

### P2 — Home Dashboard

**Header:**
- "Good Morning, [Name]" — 22pt SemiBold `#1A3A5C`
- Today's date — 14pt `#888888`
- Circular avatar top-right with initials or photo
- 40×40pt circular progress ring — `#4A90D9` stroke, showing completion ratio (e.g., "3/8")

**Hero Card (Next Reminder):**
- Full width minus 20px edges, ~220pt tall
- Background: `#1A3A5C` deep navy
- "UP NEXT" pill label in `#4A90D9`
- Medicine name: 28pt Bold white
- Instruction: 18pt white
- Time: 40pt Bold white
- DONE button: green pill `#27AE60`
- SNOOZE button: outlined white pill
- Medicine/task icon on the right
- Card radius 20px, deep shadow
- ⚠️ No Sehri/Iftar countdown or reference anywhere on this card

**Empty State (when no reminders exist):**
This state is critical and must work correctly. If no reminders are set:
- Do not show a blank or broken hero card area
- Show a friendly empty state illustration with text: "No reminders yet. Tap + to add your first one."
- The FAB must be visually obvious in this state

**Today's Chain Timeline:**
- "Today's Schedule" heading: 16pt SemiBold `#1A3A5C`
- Each card: 72pt tall, white, 12px radius, soft shadow
- Left dot colors: green (done), amber (upcoming), grey (chain-locked pending a prior step), red (missed)
- Right chip: "Done" / "In 30m" / "Waiting" / "Missed"
- Chain-linked reminders connected by a vertical dotted line on the left edge
- ⚠️ No fasting-mode separator lines

**FAB:** Circular 56×56pt, `#4A90D9`, white plus icon, floats above bottom nav

**End-to-end sense check:**
Open the app at 7am with a full day's reminders set. The hero card must show the next upcoming reminder. Scrolling the timeline shows all remaining reminders grouped by chain. The progress ring updates in real time as the user confirms reminders. The user understands their entire day within 2–3 seconds of opening the app.

---

### P3 — Full-Screen Alert & Reminder Takeover

This is the highest-stakes screen in the app. Test it thoroughly.

**Trigger:** User does not respond to Layer 1 (banner) or Layer 2 (audio). After the escalation delay, Layer 3 fires.

**Background:** `#1A3A5C` with slow pulsing glow (2-second breathing cycle). Must be playing — verify the animation is not frozen or missing on device.

**Top section:**
- "REMINDER" pill label, centred
- Animated bell icon (gentle ring loop)
- Time: 48pt Bold white
- Date: 16pt `#AACCFF`

**Centre card:**
- White card, 24px radius, 80% screen width, 24px internal padding
- Medicine icon: 64×64pt
- Medicine name: 28pt Bold `#1A3A5C`
- Instruction: 18pt `#444444`
- Amber context note: 16pt `#F39C12` ("closes in X minutes" — this must show a live countdown, not a static string)
- Chain step indicator: "Step 1 of 3" with dot row

**Bottom buttons — all three stacked vertically:**
- DONE: 72pt height, `#27AE60`, "I've Done It" 22pt Bold white, 14px radius
- SNOOZE: 72pt height, outlined white, 22pt white, 14px radius
- SKIP THIS TIME: 48pt height, no border, `#AAAAAA`, 18pt

**Caregiver note (bottom of screen):**
"No response in [X] min will send a WhatsApp alert to your caregiver."
- ⚠️ Must say "WhatsApp alert" not "SMS" or "caregiver notification via app" — update this string everywhere it appears

**Critical checks:**
- No X button. No back gesture. Only 3 exits.
- Accessible from the lock screen without unlocking
- All text minimum 24pt on this screen
- No Ramadan/Iftar countdown anywhere

**End-to-end sense check:**
This screen must function correctly even when triggered at 3am with the phone on silent. The pulsing background, loud audio (Layer 2 fires first), and screen wake must all work together. The user must be able to tap DONE with a half-awake, imprecise tap and have it register correctly.

---

### P4 — Add Reminder (Build It + Say It Coming Soon)

**Header:**
- Back arrow top-left
- "New Reminder" 22pt Bold centred
- "Templates" text button top-right in `#4A90D9`

**Mode Toggle:**
- Two-tab segmented control: "Say It" (mic icon) | "Build It" (sliders icon)
- **Default tab on open: "Build It"** (not Say It)

**Say It Tab — Coming Soon State:**
- Centred illustration (e.g., microphone with a lock or clock overlay)
- Label: "Voice Setup — Coming Soon" — 18pt SemiBold `#1A3A5C`
- Subtext: "For now, use Build It to set up your reminders." — 15pt grey
- Mic icon is greyed out and non-interactive
- No example chips visible
- No waveform or input area
- ⚠️ Confirm tapping the mic does absolutely nothing — no crash, no error, just nothing

**Build It Tab — Fully Functional:**

*Reminder Name:*
- Large text input, 56pt height
- Placeholder: "e.g., Paracetamol 500mg"

*Reminder Type:*
- 4 icon chips in 2×2 grid: Medicine (pill icon) / Meal (fork icon) / Activity (running icon) / Call (phone icon)
- Selected chip fills `#4A90D9`

*Anchor Time:*
- Two sub-options: "Fixed Time" (shows a time picker) or "Linked to Event" (shows dropdown)
- Linked to Event dropdown options: Breakfast / Lunch / Dinner / Wakeup / Sleep
- ⚠️ Confirm "Sehri" and "Iftar" are not present in this list

*Offset (appears only when Linked to Event is selected):*
- Two pills: "Before" / "After"
- Minute input field
- Example: "30 min After Lunch"

*Notes:*
- Optional, 80pt tall textarea
- Placeholder: "e.g., 1 tablet with water"

*Repeat:*
- Toggle. When on: M T W T F S S pill day selectors appear

**Save Button:**
- "Add to My Day" sticky bottom bar
- `#1A3A5C` fill, 56pt height, 14px radius
- Disabled (grey) until Reminder Name and at least one time option are filled

**End-to-end sense check:**
1. Open Add Reminder. Confirm "Build It" tab is active.
2. Fill in: Medicine type, name "Metformin 500mg", linked to Lunch anchor, 10 min before, repeat Mon–Fri.
3. Tap "Add to My Day."
4. Open Home Dashboard. Confirm the reminder appears in Today's Schedule at the correct calculated time.
5. Open Today's view (P5). Confirm the chain grouping shows "Lunch Chain" with the reminder inside it.
6. Open the reminder again (tap to edit). Confirm all fields are pre-populated correctly.

---

### P5 — Today's Full Schedule View

**Header:**
- "Today" 28pt Bold `#1A3A5C`
- Date chip (pill `#EAF2FB`, `#1A3A5C` text)
- 3 summary stat chips: "X Done" (green) / "X Upcoming" (blue) / "X Missed" (red), each 36pt pill with icon

**Timeline:**
- Continuous vertical line `#E0E0E0` on left edge
- Time labels 13pt grey anchored to the line
- Reminder cards float to the right

**Reminder Card:**
- 16px radius, white, soft shadow
- 8px-wide left colour bar (state colour)
- Name: 18pt SemiBold; time: 14pt grey; instruction: 14pt
- Right: state icon — green tick (done), amber clock (upcoming), red X (missed), grey lock (chain-locked)

**Chain Grouping:**
- Light blue `#EAF2FB` background spanning all chain members
- "Lunch Chain" (or relevant name) 13pt SemiBold `#4A90D9` header at top
- Dotted vertical line connecting members inside the group

**Empty State (after all reminders for the day are done):**
- Tea cup illustration
- "Rest of the day is free" — 17pt italic grey

**FAB:** Same circular `+` as Home Dashboard

**Checks:**
- ⚠️ No Sehri/Iftar gold divider lines
- Tapping a reminder card opens a detail view or the edit screen — confirm this works
- The "Waiting" (grey lock) state must visually communicate that the reminder is blocked — add a tooltip or label if it is not obvious

---

### P6 — Template Library

**Header:**
- "Quick Start Templates" 22pt Bold
- "Pick a pack and we'll build your chain." 15pt grey

**Search bar:** 48pt, `#F0F4F8`, search icon inside

**Filter chips (horizontal scroll):**
- All | Medical | Meals | Kids | Fitness
- ⚠️ "Fasting" chip must be gone

**Template cards (vertical scroll, 1 column at 390pt):**
- White, 20px radius, shadow, ~120pt tall
- Icon in coloured circle (40×40pt)
- Name 17pt SemiBold, description 13pt grey
- Reminder count chips at bottom ("3 medicines · 2 meals")
- Arrow chevron `#4A90D9`

**Templates — exactly 7 cards:**
1. Diabetic Daily Pack — blue circle, syringe icon
2. Blood Pressure Pack — red circle, heart icon
3. School Morning Routine — purple backpack icon
4. Hydration Booster — cyan water drop icon
5. Heart Patient Pack — warm red ECG icon
6. Elderly Wellness Daily — navy senior icon
7. Eye Care Routine — light blue eye icon
- ⚠️ "Ramadan Medicine Pack" must be gone

**Template detail sheet (slides up on tap):**
- 80% screen height, drag handle at top
- Template name large at top
- Expandable list of all reminders in the pack (name, time, type)
- "Use This Template" sticky button, full width, `#1A3A5C`

**End-to-end sense check:**
1. Tap "Diabetic Daily Pack."
2. Sheet slides up. Tap "Use This Template."
3. A wizard opens asking for customisation (meal times, medicine names).
4. Complete the wizard. Tap Save.
5. Open Today's schedule — all template reminders appear correctly, grouped into chains.
6. Tap "Hydration Booster." Activate it. Confirm 8 water reminders appear spread across waking hours.

---

### P7 — REMOVED ✅

Confirm: no route exists, no navigation link points to it, no bottom nav tab opens it.

---

### P8 — History & Compliance Log

**Header:**
- "History" 28pt Bold
- "Export PDF" outlined pill, `#4A90D9`, 36pt height

**Week Selector:**
- 7-day horizontal strip
- Today: `#1A3A5C` filled circle, white text
- Past days with data: coloured dot below (green / amber / red)
- Tap a day → log scrolls/filters to that day's entries

**Compliance Ring:**
- Donut chart 160×160pt, centred
- Inner label: "X% this week" 22pt Bold `#1A3A5C`
- Segments: green (taken on time), amber (snoozed/late), red (missed), grey (skipped)
- Legend below: coloured squares + label + count

**Daily Log:**
- Day header 15pt SemiBold with horizontal extending line
- Each row 48pt: colour dot + name + scheduled time (centre) + actual action ("Taken at 1:02 PM" in green / "Missed" in red / "Skipped" in grey)
- If a WhatsApp alert was sent: small WhatsApp icon on the row (not the old bell/caregiver icon)

**Medicine filter chips:** Horizontal scroll, one per medicine; tapping filters the log

**Empty state:** Calendar illustration + "No data yet for this week."

**End-to-end sense check:**
1. Navigate to a week with data. Confirm ring chart matches the actual log entries below.
2. Tap a medicine filter chip. Confirm only that medicine's entries show.
3. Tap "Export PDF." Share to WhatsApp. Confirm the PDF file arrives and opens correctly.
4. Navigate to a week with no data. Confirm empty state shows (not a broken ring chart).

---

### P9 — REMOVED (Caregiver Portal) ✅

Confirm: route deleted, no navigation points to it, no bottom nav tab opens it.

The caregiver interaction is now handled entirely by:
- Settings: "Caregiver WhatsApp Number" field
- MISSED state: auto-opens WhatsApp with pre-filled message

---

### P10 — Settings & Profile

**Profile section:**
- 80×80pt circular avatar, `#1A3A5C` fill if no photo, white initials 32pt
- Name 22pt Bold below
- Mode chip: "Elderly Mode Active" (green) or "Standard Mode" (grey)
- Edit profile button: outlined pill, small, to the right of name

**Group 1 — Display:**
- Text Size → opens slider sheet
- High Contrast Mode → toggle
- Dark Mode → toggle

**Group 2 — Notifications:**
- Alert Volume → inline mini-slider
- Snooze Duration → value pill + chevron → options: 5 / 10 / 15 / 30 min
- Escalation Delay → value + chevron → label must read "Alert caregiver after" not "Send SMS after"

**Group 3 — Caregiver (revised — single row only):**
- Row label: "Caregiver WhatsApp Number"
- Right side: the stored number (e.g., "+91 98765 43210") with an edit pencil icon
- Tapping the row opens a bottom sheet with a phone input field and "Save" button
- ⚠️ Remove the old caregiver group that had linked account cards, "Remove" danger links, and "Add Caregiver" for multiple caregivers. One number only.

**Group 4 — Data:**
- Export My Data (PDF/CSV)
- Backup to Cloud → toggle + last backup timestamp (optional)
- Delete All Reminders → danger red text, no icon, requires confirmation dialog

**Row design:**
- 56pt height standard, 64pt elderly mode
- Left: icon in coloured soft square, 8px radius
- Centre: label 17pt
- Right: value / toggle / chevron
- 0.5pt `#EEEEEE` dividers within a group
- 16pt grey gap between groups with 13pt uppercase section label

**End-to-end sense check:**
1. Change Text Size to Large. All screens must reflect the change immediately or after a hot restart.
2. Change Snooze Duration to 5 min. Set a reminder, snooze it — confirm it re-fires in 5 min.
3. Set Escalation Delay to 15 min. Trigger a MISSED event — confirm the WhatsApp alert opens after 15 min.
4. Enter a caregiver WhatsApp number. Save. Return to Settings — confirm the number is displayed correctly.
5. Tap Delete All Reminders. Confirm a "Are you sure?" dialog appears. Confirm deletion clears all reminders and resets today's schedule.

---

### P11 — Visual Chain Builder

**Access:** Accessible from the Add Reminder screen via an "Advanced" or "Chain Builder" link, or from a reminder detail view. Entry point is discoverable but not prominent.

**Header:**
- "Chain Builder" 22pt Bold
- Subtitle shows the chain being edited (e.g., "Lunch Medicine Chain")
- Back arrow top-left
- "Save Chain" teal text button + "Test Run" outlined button, top-right

**Anchor Node:** Pill-shaped, top centre, clock icon + editable time, `#F0A500` amber

**Chain nodes:** Rectangular cards 160×80pt, 12px radius. Left colour bar: blue (medicine) / green (meal) / grey (activity). Connected by directional arrows.

**Interactions:**
- Tap node → detail edit sheet slides up
- Long-press → drag to reorder
- Solid arrow = fires after DONE; dashed arrow = fires regardless
- Tap arrow → condition picker

**Add node button:** Dashed border `#4A90D9` node at bottom

**Zoom/pan:** Canvas zoomable and pannable; mini-map bottom-right

**Test Run Panel:** Slides up to simulate the notification sequence

**End-to-end sense check (critical — this is often a UI-only prototype):**
1. Open Chain Builder for an existing chain.
2. Add a new step: "Dolo 650mg, 1 hour after anchor."
3. Tap "Save Chain."
4. Open Today's Schedule. Confirm the new step appears in the correct chain group at the correct calculated time.
5. Wait for the new reminder to fire. Confirm it fires at the right time with the correct content.

If steps 4 or 5 fail, the Chain Builder is UI-only and not connected to the reminder engine — this is a functional gap that must be fixed before shipping.

---

### P12 — Kids Mode Dashboard

**Access:** Via Profile page or a mode switcher. Requires PIN to switch back to adult mode.

**Palette (entirely different from main app — verify this explicitly):**
- Primary purple: `#7C3AED`
- Playful green: `#22C55E`
- Warm yellow: `#FBBF24`
- Coral: `#F87171`
- Bubbly rounded shapes throughout

**Header:**
- "Good Morning, [Name]! 🌟" — 26pt Bold purple
- Mascot illustration top-right (owl or robot — consistent)
- Animated stars / earned points

**Daily Checklist:**
- "Your Morning Quest 🎯" — 20pt SemiBold
- Horizontal progress bar (purple-to-green gradient)
- "[Name] has done X out of Y tasks" — 15pt below bar

**Task cards:**
- Full width, 72pt tall
- Unchecked: white card, grey circle left
- Checked: green fill card, white checkmark, strikethrough text
- Spring animation on check — must play on real device, not just emulator

**5 default tasks:**
1. Wake up and stretch — 7:00 AM
2. Brush your teeth — 7:10 AM
3. Have breakfast — 7:25 AM
4. Take your vitamin — 7:30 AM (chain-linked: only fires after breakfast confirmed)
5. Pack your school bag — 7:45 AM

**Reward banner (at 100% completion):**
- Confetti + star animation
- "Amazing! You did everything! ⭐⭐⭐" on gold card

**Parent View toggle:**
- "Parent View" button top-left
- Requires PIN entry — verify the PIN prompt appears and cannot be bypassed
- Switches to standard adult dashboard

**End-to-end sense check:**
1. Switch to Kids Mode. Confirm palette is entirely different from adult mode.
2. Check off tasks in order. Confirm spring animation plays each time.
3. At task 4 (Take vitamin): confirm it is locked until "Have breakfast" is checked.
4. Complete all 5 tasks. Confirm the reward banner animation fires.
5. Tap "Parent View." Confirm PIN prompt appears. Enter correct PIN. Confirm switch to adult dashboard.
6. In adult mode, change the child's wake-up time. Switch back to Kids Mode. Confirm the task time updated.

---

## PHASE 4 — End-to-End Functional Testing

*Test on a real Android device. Emulators do not reliably reproduce alarm, lock-screen, or battery optimisation behaviour.*

For each scenario: if the behaviour does not match what is described, invoke the Self-Correcting Protocol at the top of this document before moving to the next scenario.

---

### 4.1 Chain Engine — Core Scenarios

**Scenario A — Before Meal Chain:**
1. Add: "Paracetamol 500mg, 5 min before Lunch, Lunch at 1:00 PM."
2. At 12:55 PM: soft notification fires. Tap DONE.
3. Chain waits for lunch anchor confirmation.
4. Confirm Lunch. No after-meal reminder exists — verify nothing unexpected fires.

**Scenario B — Full Before + After Chain:**
1. Add: Paracetamol 5 min before Lunch, Dolo 650 30 min after Lunch. Lunch at 1:00 PM.
2. 12:55 PM: Paracetamol fires. Tap DONE.
3. 1:00 PM: Confirm Lunch done.
4. 1:30 PM: Dolo fires. Tap DONE.
5. Check History: both DONE with correct timestamps.

**Scenario C — SNOOZE within a chain:**
1. Same chain as B.
2. 12:55 PM: tap SNOOZE (10 min).
3. 1:05 PM: Paracetamol re-fires. Tap DONE.
4. Confirm Lunch at 1:00 PM (lunch anchor fires at its set time regardless of the medicine snooze).
5. 1:30 PM: Dolo fires. Confirm.

**Scenario D — SKIP suspends downstream:**
1. Same chain.
2. 12:55 PM: tap SKIP.
3. Verify: Dolo does NOT fire. Chain downstream is suspended for this slot.
4. Check History: Paracetamol = "Skipped"; Dolo = suspended / not triggered (not "Missed").

**Scenario E — MISSED triggers WhatsApp alert:**
1. Add a reminder for 2 minutes ahead.
2. Temporarily reduce escalation delay to 2 min in Settings.
3. Do not respond to Layer 1, Layer 2, or Layer 3.
4. After 2 min past Layer 3: WhatsApp opens with pre-filled message — correct caregiver number, correct medicine name and time.
5. History shows MISSED.
6. Restore escalation delay to default.

**Scenario F — Reboot persistence:**
1. Create two future reminders: one 10 min ahead, one 30 min ahead.
2. Reboot the device fully.
3. Both reminders must fire at their correct times after reboot.
4. If either fails: BootReceiver is not functioning — release blocker.

**Scenario G — Full escalation stack:**
Verify all 3 layers fire in order for a single reminder:
- Layer 1: Soft banner with action buttons. No response.
- Layer 2: Audio + vibration. No response.
- Layer 3: Full-screen takeover on lock screen.
Each layer must be visually and functionally distinct.

---

### 4.2 Confirmation State Verification

After each action, open History and confirm the entry:

| State | Expected History Entry |
|---|---|
| DONE | Green dot, "Taken at [actual time]" |
| SNOOZE | Amber dot, "Snoozed, re-fired at [time]" |
| SKIP | Grey dot, "Skipped" |
| MISSED | Red dot, "Missed", WhatsApp icon if alert was sent |

---

### 4.3 Template Activation (all 7 templates)

For each of the 7 templates:
1. Open Template Library → tap template → sheet slides up.
2. Tap "Use This Template."
3. Customisation wizard appears — fill in names and times.
4. Tap Save.
5. Open Today's schedule — all template reminders present, correctly timed, correctly chain-grouped.
6. At least one reminder from the template fires at the correct time.

---

### 4.4 WhatsApp Caregiver Alert (full flow)

1. Set caregiver number in Settings (use your own number for testing).
2. Temporarily reduce escalation delay to 2 minutes.
3. Create a reminder for 1 minute ahead. Do not respond to any alert.
4. After 2 min: WhatsApp opens with pre-filled message.
5. Verify: correct number in "To" field, medicine name in message, time is correct, patient name in message.
6. Confirm the WhatsApp compose screen appears — user must tap Send manually.
7. Restore escalation delay to default.

---

### 4.5 Say It — Coming Soon Lockout

1. Open Add Reminder. Verify "Build It" tab is active by default.
2. Tap the "Say It" tab.
3. Verify: Coming Soon illustration, "Voice Setup — Coming Soon" label, and subtext appear.
4. Tap the greyed-out mic icon. Verify: nothing happens — no crash, no error, no recording.
5. Switch to "Build It." Verify it works normally.

---

### 4.6 Kids Mode (full flow)

1. Activate Kids Mode from Profile.
2. Verify palette change and mascot.
3. Complete tasks in order — verify chain lock on vitamin task (must wait for breakfast check).
4. Complete all 5 tasks — verify reward animation fires.
5. Tap Parent View — verify PIN prompt appears.
6. Edit child's schedule from adult mode — verify change appears in Kids Mode.

---

### 4.7 Accessibility

**Large Text / Elderly Mode:**
- Enable. Open Home, P3 Alert, Add Reminder, History.
- All text ≥21pt, no overflow, no cut-off, no overlapping elements.
- Tap targets ≥64pt height on all major interactive elements.

**High Contrast:**
- Enable. Open each screen.
- Text readable on all backgrounds (WCAG AA: 4.5:1 minimum for body text).

**Text-to-Speech:**
- Set a reminder for 1 min.
- When it fires, device speaks the reminder aloud.
- Spoken text matches the reminder content — not a generic "reminder" message.
- Speech stops when any button is tapped.

---

### 4.8 Offline Operation

1. Enable Airplane Mode.
2. Create a new reminder. Confirm it saves.
3. Confirm it fires at the scheduled time.
4. Confirm DONE / SNOOZE / SKIP all work.
5. Confirm History logs the action correctly.
6. Re-enable connectivity. Confirm any pending queued actions are handled gracefully.

---

### 4.9 History & PDF Export

1. After mixed-activity day, open History.
2. Confirm donut chart segments match the log entries.
3. Tap each day in week selector — chart and log both update.
4. Tap a medicine filter chip — log shows only that medicine.
5. Tap "Export PDF."
   - PDF generates without error.
   - Share sheet opens.
   - Share to WhatsApp — file arrives as attachment.
   - Open PDF — data is accurate, readable, no Ramadan references.

---

## PHASE 5 — Play Store Release Preparation

*Gate: All Phase 4 scenarios must pass on a release build before beginning Phase 5.*

---

### 5.1 App Signing

1. Confirm a keystore file (`.jks` or `.keystore`) exists.
2. Confirm it is referenced in `android/app/build.gradle` under `signingConfigs.release`.
3. Confirm keystore password and alias are in a `key.properties` file listed in `.gitignore` — NOT hardcoded in the Gradle file.
4. Run `flutter build apk --release`. Must build without error.
5. Install the release APK on a real device. Re-run all Phase 4 scenarios on the release build — release builds behave differently from debug builds, and crashes that only appear in release almost always mean a missing ProGuard keep rule.

---

### 5.2 App Bundle

Submit an App Bundle (`flutter build appbundle`) to the Play Store, not an APK.

Confirm: bundle builds cleanly. File size is under 150MB.

---

### 5.3 App Icon & Splash Screen

**Icon:**
- Not the default Flutter logo.
- Present at all required densities: `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`.
- Round icon variant (`ic_launcher_round`) present.
- Manifest reference matches the actual file name exactly.
- Install release APK and verify icon on home screen and in app drawer.

**Splash Screen:**
- MemoCare branding, not the Flutter default.
- Does not linger after the app has loaded — test on a slow device.
- If using `flutter_native_splash`: confirm the generate command was run after config changes.

---

### 5.4 Play Store Listing Assets

| Asset | Specification |
|---|---|
| App Title | "MemoCare" or "MemoCare — Smart Reminder" (max 30 characters) |
| Short Description | Max 80 characters. Example: "Smart medicine & task reminders for seniors, professionals, and kids." |
| Full Description | Max 4000 characters. Mention: medication reminders, chain logic, elderly accessibility, caregiver WhatsApp alerts. Do NOT say "cures", "treats", or make clinical efficacy claims. |
| App Icon | 512×512px PNG, no alpha channel |
| Feature Graphic | 1024×500px PNG or JPEG |
| Screenshots | Min 2, max 8 phone screenshots — real app screens. Recommended: Home Dashboard, Full-Screen Alert, Add Reminder (Build It tab), History, Kids Mode. |
| Privacy Policy URL | A live, publicly accessible URL — required before submission |
| Content Rating | Complete IARC questionnaire. Expected rating: Everyone. |
| Target Audience | "18 and over" for safety. If Kids Mode is prominent, consult Play Store child-directed content policy before selecting "All ages." |

---

### 5.5 Privacy Policy — Must Cover

- All reminder data is stored locally on the user's device
- The caregiver WhatsApp number is stored locally and is only used to open WhatsApp with a pre-filled message when a reminder is missed — no data is sent to any server for this feature
- No health data is transmitted to any third party
- Optional cloud backup: if implemented, describe what is backed up and where
- How to delete all data: Settings → Delete All Reminders
- Contact address for data-related requests
- The app does not display advertisements
- No third-party analytics SDKs transmit personal data (confirm this before writing it — audit the dependency tree)

---

### 5.6 Sensitive Permissions Declaration

Complete in Play Console under "App Content" → "Sensitive Permissions":

| Permission | Declaration Text |
|---|---|
| `SCHEDULE_EXACT_ALARM` | MemoCare is a medication reminder app for elderly users. Exact alarm timing is required to ensure medicines are taken at clinically correct intervals — delays of even a few minutes can be medically significant. |
| `USE_FULL_SCREEN_INTENT` | Critical medication alerts must appear on the lock screen for elderly users who may not actively check their phone. Without lock-screen alerts, the core safety feature of the app cannot function. |
| `CALL_PHONE` | The app includes a "Call a relative" reminder type that allows users to initiate a phone call directly from a notification. This is a direct user-initiated action, not background dialling. |
| `FOREGROUND_SERVICE` | A scheduling service must persist in the background to ensure medication reminders are delivered reliably, even when the app is not in the foreground. |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Background reminder delivery is blocked by OEM battery optimisers on many Android devices. This permission allows users to exempt MemoCare so that reminders fire reliably. |

---

### 5.7 Final Pre-Submission Checklist

**Code quality:**
- [ ] `flutter analyze` returns zero errors and zero warnings
- [ ] `flutter test` passes all unit tests
- [ ] No hardcoded API keys, passwords, or personal test data remain in the source

**Feature completeness:**
- [ ] All Ramadan / Fasting references are absent from all screens, routes, strings, assets, and channels
- [ ] Caregiver Portal (P9) is deleted; WhatsApp alert works correctly end-to-end
- [ ] Say It tab shows Coming Soon state; no crash on tap; Build It is the default tab
- [ ] All 7 templates activate correctly end-to-end
- [ ] Chain engine works for all 7 scenarios (A through G)
- [ ] Full-screen lock-screen alert (P3) appears on lock screen on a real device
- [ ] WhatsApp alert opens with correct pre-filled message after MISSED state
- [ ] PDF export generates, opens, and shares correctly
- [ ] Kids Mode completes full flow including chain lock on vitamin task, reward animation, and PIN gating
- [ ] Offline operation verified — all core features work on Airplane Mode
- [ ] Chain Builder (P11) saves chains to the engine and new steps fire correctly

**Android build:**
- [ ] Release APK installs from `adb install` with no error
- [ ] App does not crash on cold start on API 21 device (min SDK)
- [ ] App does not crash on cold start on API 34 device (target SDK)
- [ ] All Phase 4 scenarios pass on the release APK (not just debug)
- [ ] App Bundle (`flutter build appbundle`) builds cleanly

**Play Store assets:**
- [ ] App icon is MemoCare-branded, all densities present
- [ ] Splash screen is MemoCare-branded
- [ ] App title in task switcher reads "MemoCare"
- [ ] `versionCode` = 1, `versionName` = "1.0.0"
- [ ] Privacy policy URL is live and complete
- [ ] All 5 sensitive permissions declarations are written
- [ ] Screenshots prepared (real device, not mockups)
- [ ] Feature graphic prepared (1024×500px)

**Testing track:**
- [ ] Bundle uploaded to Internal Testing track on Play Console
- [ ] At least 2 testers installed from Internal Testing track and ran through Phase 4
- [ ] No crashes reported in Play Console Android Vitals
- [ ] Promoted to Closed Testing before Open / Production

---

## Summary: Phase Execution Order

| Phase | What Happens | Gate to Proceed |
|---|---|---|
| **Pre-Work** | Remove Ramadan. Remove complex caregiver. Lock Say It as Coming Soon. | `flutter analyze` — zero errors |
| **Phase 1** | Verify every plugin: pubspec, Manifest, Dart-side init, runtime test | All 13 plugin checks pass on device |
| **Phase 2** | Audit build.gradle, Manifest, channels, battery handling, ProGuard | Release APK builds and installs cleanly |
| **Phase 3** | UI screen-by-screen vs design spec on real device | Every screen passes visual and interaction check |
| **Phase 4** | End-to-end functional testing (9 scenarios) on release build | All 9 scenarios pass with no workarounds |
| **Phase 5** | Signing, bundle, store listing, permissions declaration, internal testing | Internal Testing track approved, no crashes in Vitals |

---

*MemoCare — Never Miss What Matters*
