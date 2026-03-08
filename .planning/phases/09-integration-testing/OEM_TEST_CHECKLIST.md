# OEM Manual Testing Checklist — MemoCare v1.0

> **Purpose:** Step-by-step manual test procedures for validating
> alarm reliability, battery optimization, escalation, and
> permission flows on OEM devices.
>
> **Device Requirements:** Minimum 3 physical devices:
>
> - 1 × Xiaomi (MIUI 14/15)
> - 1 × Samsung (OneUI 5/6)
> - 1 × Huawei (EMUI 13/14 or HarmonyOS 3/4)
>
> Android versions across devices must cover at least
> API 31 (Android 12) and API 34 (Android 14).
>
> **Notation:** Each test has a unique ID: `{Category}-{Number}`.
> Record results in `OEM_TEST_RESULTS.md`.

---

## Category A: Alarm Reliability

### A-01: Alarm fires after 5 min with device locked

**Pre-conditions:** App installed, onboarding complete,
at least 1 reminder scheduled.

**Steps:**

1. Schedule a reminder 5 min from now.
2. Lock the device (press power button).
3. Wait 5 min without interacting.
4. Observe whether the alarm notification fires.

**Expected Result:** Alarm notification fires at the
scheduled time, even with device locked.

**Pass Criteria:** Notification arrives within ±30 s of
scheduled time.

---

### A-02: Alarm fires after 30 min with device locked

**Pre-conditions:** Same as A-01.

**Steps:**

1. Schedule a reminder 30 min from now.
2. Lock the device.
3. Wait 30 min without interacting.
4. Observe whether the alarm notification fires.

**Expected Result:** Alarm fires at scheduled time.

**Pass Criteria:** Notification arrives within ±60 s of
scheduled time. Device screen may not wake — check
notification shade.

---

### A-03: Alarm fires after app closed from recents

**Pre-conditions:** App installed, onboarding complete.

**Steps:**

1. Schedule a reminder 5 min from now.
2. Open recents / app switcher.
3. Swipe the app away (close from recents).
4. Lock device and wait 5 min.
5. Observe whether the alarm fires.

**Expected Result:** Alarm fires even though user
swiped app away. AlarmManager schedules persist
independent of app process.

**Pass Criteria:** Notification arrives within ±30 s.

---

### A-04: Alarm after force stop (expected failure)

**Pre-conditions:** App installed, onboarding complete.

**Steps:**

1. Schedule a reminder 5 min from now.
2. Go to Settings → Apps → MemoCare → Force Stop.
3. Confirm force stop.
4. Wait 5 min.
5. Document whether the alarm fires.

**Expected Result:** Alarm likely DOES NOT fire after
force stop. This is expected Android behavior — force
stop cancels all AlarmManager alarms.

**Pass Criteria:** Document behavior. If alarm does
NOT fire, record as expected. If it DOES fire (some
OEMs re-register), record as bonus.

---

### A-05: Multiple alarms in 10-min window

**Pre-conditions:** App installed, onboarding complete.

**Steps:**

1. Schedule 5 reminders at 2-min intervals (e.g.,
   +2, +4, +6, +8, +10 min from now).
2. Lock device and wait.
3. Count how many of the 5 alarms fire.

**Expected Result:** All 5 alarms fire. Android Doze
allows `setExactAndAllowWhileIdle()` minimum every
9 min, but short intervals may batch alarms.

**Pass Criteria:** All 5 fire. Acceptable: 4/5 fire
with the 5th delayed ≤2 min (Doze batching). Failure:
≤3 fire.

---

## Category B: Boot Rescheduling

### B-01: Alarms survive device reboot

**Pre-conditions:** App installed, onboarding complete,
BOOT_COMPLETED receiver registered in manifest.

**Steps:**

1. Schedule 3 reminders:
   - Reminder 1: 5 min from now
   - Reminder 2: 15 min from now
   - Reminder 3: 30 min from now
2. Reboot the device (Settings → Restart or hold
   power → Restart).
3. After boot completes, wait for each reminder time.
4. Record which alarms fire.

**Expected Result:** All 3 alarms fire at their
scheduled times after reboot. The BOOT_COMPLETED
receiver re-registers them with AlarmManager.

**Pass Criteria:** All 3 fire within ±60 s of
scheduled time.

---

### B-02: Alarms survive app update

**Pre-conditions:** App installed with scheduled
reminders.

**Steps:**

1. Schedule 2 reminders 10 min apart.
2. Install an updated version of the app (via
   `adb install -r` or Play Store update).
3. Wait for reminder times.
4. Record which alarms fire.

**Expected Result:** MY_PACKAGE_REPLACED receiver
re-registers alarms after update.

**Pass Criteria:** Both alarms fire after update.

---

## Category C: OEM Battery Optimization

### C-01 (Xiaomi): AutoStart enabled

**Device:** Xiaomi with MIUI 14/15

**Pre-conditions:** Fresh install of MemoCare.

**Steps:**

1. Launch MemoCare.
2. Verify that onboarding shows Xiaomi-specific
   AutoStart guidance screen.
3. Follow the instructions:
   - Go to Settings → Apps → Manage Apps → MemoCare
     → AutoStart (or Security → Manage Apps →
     MemoCare → Permissions → AutoStart).
   - Enable AutoStart toggle.
4. Return to MemoCare and continue onboarding.

**Expected Result:** AutoStart guidance appears during
onboarding. AutoStart can be enabled at the
indicated settings path.

**Pass Criteria:** AutoStart toggle is ON for MemoCare
after following guidance.

---

### C-02 (Xiaomi): Not in Battery Saver restricted list

**Device:** Xiaomi with MIUI 14/15

**Steps:**

1. Go to Settings → Battery & Performance →
   Battery Saver → App Battery Saver.
2. Find MemoCare in the list.
3. Set to "No restrictions" (not "Battery Saver"
   or "Background restricted").

**Expected Result:** MemoCare is set to unrestricted.

**Pass Criteria:** After setting, schedule a reminder
15 min from now → lock device → verify alarm fires.

---

### C-03 (Xiaomi): Alarm fires after 15 min locked

**Device:** Xiaomi with MIUI 14/15

**Pre-conditions:** AutoStart enabled (C-01),
not battery restricted (C-02).

**Steps:**

1. Schedule reminder 15 min from now.
2. Lock device and do not interact.
3. Wait 15 min.

**Expected Result:** Alarm fires. MIUI's battery
saver kills background processes after ~10 min,
but with AutoStart and unrestricted battery,
AlarmManager should survive.

**Pass Criteria:** Notification arrives within ±60 s.

---

### C-04 (Xiaomi): Lock app in recents

**Device:** Xiaomi with MIUI 14/15

**Steps:**

1. Open MemoCare.
2. Open recents / app switcher.
3. Long-press or swipe down on the MemoCare card.
4. Tap "Lock" (lock icon). The app should show a
   lock indicator.
5. Schedule a reminder 10 min from now.
6. Lock device and wait.

**Expected Result:** Locked apps are exempt from
MIUI's aggressive recents clearing.

**Pass Criteria:** Alarm fires. Locking the app in
recents prevents MIUI from killing it.

---

### C-05 (Samsung): Unmonitored apps list

**Device:** Samsung with OneUI 5/6

**Pre-conditions:** Fresh install.

**Steps:**

1. Launch MemoCare → verify Samsung-specific battery
   optimization guidance in onboarding.
2. Follow instructions:
   - Go to Settings → Battery and Device Care →
     Battery → Background Usage Limits.
   - Tap "Never sleeping apps" (or "Unmonitored
     apps" on OneUI 5).
   - Add MemoCare to this list.
3. Verify MemoCare is NOT in "Sleeping apps" or
   "Deep sleeping apps" lists.

**Expected Result:** MemoCare is in never-sleeping
list and excluded from sleeping/deep sleeping.

**Pass Criteria:** After whitelisting, schedule a
reminder 15 min from now → lock → verify fires.

---

### C-06 (Samsung): Adaptive Battery exclusion

**Device:** Samsung with OneUI 5/6

**Steps:**

1. Go to Settings → Battery and Device Care →
   Battery → More Battery Settings.
2. Verify "Adaptive Battery" state (ON or OFF).
3. If ON, verify MemoCare is excluded from adaptive
   restrictions (should be, after C-05).
4. Schedule a reminder 30 min out → lock → verify.

**Expected Result:** Adaptive Battery does not
interfere with MemoCare alarms.

**Pass Criteria:** Alarm fires within ±60 s.

---

### C-07 (Samsung): Sleeping apps after 3 days

**Device:** Samsung with OneUI 5/6

**Steps:**

1. Complete onboarding with battery whitelisting.
2. Do NOT open the app for 3 days (or simulate by
   adding MemoCare to "Sleeping apps" manually,
   then removing it, to verify the detection).
3. After 3 days, check if Samsung auto-added
   MemoCare to "Sleeping apps."
4. If yes, remove it and verify alarms resume.

**Expected Result:** If MemoCare was added to
"Never sleeping apps" (C-05), Samsung should NOT
auto-add it to sleeping apps.

**Pass Criteria:** MemoCare remains in never-sleeping
list after 3 days of non-use.

---

### C-08 (Huawei): App Launch Manager

**Device:** Huawei with EMUI 13/14 or HarmonyOS 3/4

**Pre-conditions:** Fresh install.

**Steps:**

1. Launch MemoCare → verify Huawei-specific guidance
   during onboarding.
2. Follow instructions:
   - Go to Settings → Battery → App Launch (or
     Settings → Apps → App Launch).
   - Find MemoCare → toggle OFF "Manage automatically."
   - Enable all 3 toggles: Auto-launch, Secondary
     launch, Run in background.
3. Return to MemoCare.

**Expected Result:** Manual management is enabled for
MemoCare with all 3 toggles ON.

**Pass Criteria:** Settings match. Schedule a reminder
15 min out → lock → verify fires.

---

### C-09 (Huawei): Battery Optimization exclusion

**Device:** Huawei with EMUI 13/14

**Steps:**

1. Go to Settings → Battery → Battery Optimization
   (or Settings → Apps → Special Access → Battery
   Optimization).
2. Find MemoCare.
3. Set to "Don't optimize."

**Expected Result:** MemoCare excluded from Huawei's
battery optimization.

**Pass Criteria:** After setting, alarms fire
reliably (verify with 15 min test).

---

### C-10 (Huawei): Not flagged as power-intensive

**Device:** Huawei with EMUI 13/14

**Steps:**

1. Use the app normally for 1 day.
2. Go to Settings → Battery → Power-Intensive Apps.
3. Verify MemoCare is NOT in the power-intensive
   list.

**Expected Result:** MemoCare is not flagged.

**Pass Criteria:** App not listed as power-intensive.
If listed, record as issue and verify alarms still
fire.

---

## Category D: Escalation Behavior

### D-01: Escalation to AUDIBLE tier

**Pre-conditions:** App installed, onboarding complete,
notification and alarm permissions granted.

**Steps:**

1. Schedule a reminder to fire in 1 min.
2. When the silent notification appears, do NOT tap
   it.
3. Wait 2 min (default silent tier timeout).
4. Observe whether the notification upgrades with
   sound and vibration.

**Expected Result:** After 2 min of inaction, the
notification escalates to the AUDIBLE tier with
sound and vibration.

**Pass Criteria:** Sound plays and device vibrates
at the 2-min mark.

---

### D-02: Escalation to FULLSCREEN tier

**Pre-conditions:** Same as D-01. Full-screen intent
permission granted (Android 14+).

**Steps:**

1. Continue ignoring from D-01 (or start fresh with
   a new reminder).
2. Wait 3 additional min after AUDIBLE tier starts
   (5 min total from initial fire).
3. Observe whether the full-screen alarm appears.

**Expected Result:** Full-screen alarm intent launches,
taking over the screen with the alarm UI.

**Pass Criteria:** Full-screen alarm UI appears. On
Android 14+ without permission, a high-priority
heads-up notification appears instead (record which).

---

### D-03: Wakelock during fullscreen

**Pre-conditions:** Full-screen alarm active (from D-02).

**Steps:**

1. Trigger full-screen alarm (wait through escalation).
2. Verify the screen stays ON while the alarm is
   active.
3. Wait 2 min without interacting.
4. Verify screen remains on.

**Expected Result:** Wakelock keeps screen on during
full-screen alarm.

**Pass Criteria:** Screen does not turn off while
alarm is active.

---

### D-04: Alarm sound loops until user acts

**Pre-conditions:** Full-screen or audible alarm active.

**Steps:**

1. Trigger escalation to AUDIBLE or FULLSCREEN.
2. Do NOT interact.
3. Listen for 2 min.
4. Verify the alarm sound repeats/loops (doesn't
   play once and stop).

**Expected Result:** Sound loops continuously until
user taps DONE, SNOOZE, or SKIP.

**Pass Criteria:** Sound continues looping for 2+ min.

---

## Category E: Permission Flows

### E-01: All permissions granted on fresh install

**Pre-conditions:** Fresh install, never launched.

**Steps:**

1. Launch app for the first time.
2. Complete onboarding.
3. At permission step, grant all requested
   permissions.
4. Verify no permission errors on home screen.
5. Schedule a reminder → verify it fires.

**Expected Result:** All permissions granted
smoothly, alarms work.

**Pass Criteria:** Reminder notification fires
successfully.

---

### E-02: Deny notification permission

**Pre-conditions:** Fresh install.

**Steps:**

1. Launch app and proceed to permission step.
2. When notification permission dialog appears,
   tap "Don't Allow" / "Deny."
3. Observe app behavior.
4. Verify app shows degradation message explaining
   notifications won't work.
5. Verify core functionality (adding medicines,
   viewing schedule) still works.

**Expected Result:** App continues without crash.
Clear messaging about disabled notifications.

**Pass Criteria:** No crash. Degradation message
visible. Schedule screen still functional.

---

### E-03: Re-grant notification permission

**Pre-conditions:** Notification permission previously
denied (E-02 completed).

**Steps:**

1. From the app, tap the degradation banner
   (if present) to open Settings.
2. Or manually: Settings → Apps → MemoCare →
   Permissions (or Notifications) → Enable.
3. Return to the app.
4. Verify app detects the re-granted permission.
5. Schedule a reminder → verify it fires.

**Expected Result:** App detects permission change
on resume and re-enables notification features.

**Pass Criteria:** Alarm fires after re-granting.

---

### E-04: Full-screen intent on Android 14+

**Device:** Must be Android 14 (API 34) or higher.

**Pre-conditions:** Fresh install.

**Steps:**

1. During onboarding, grant all permissions.
2. Check if full-screen intent permission is
   requested (Android 14+ special permission).
3. If requested: grant it via Settings.
4. If auto-granted (alarm category): verify it's
   already enabled.
5. Trigger escalation to FULLSCREEN (see D-02).
6. Verify full-screen alarm launches.

**Expected Result:** On Android 14+, full-screen
intent either auto-granted (if alarm category
declared in manifest) or user is guided to enable it.

**Pass Criteria:** Full-screen alarm works on
Android 14+ device.

---

### E-05: Exact alarm permission on Android 12+

**Device:** Must be Android 12 (API 31) or higher.

**Steps:**

1. During onboarding, verify exact alarm permission
   handling.
2. On Android 12-13: `SCHEDULE_EXACT_ALARM` should
   be declared in manifest. May require user to
   enable in Settings → Apps → Special Access →
   Alarms & Reminders.
3. On Android 14+: `USE_EXACT_ALARM` should be
   auto-granted for health/medication apps (declared
   category in manifest).
4. Schedule a reminder → verify it fires at exact
   time (not batched).

**Expected Result:** Exact alarms work per the
device's Android version.

**Pass Criteria:** Alarm fires within ±30 s of
scheduled time (exact, not Doze-delayed).

---

## Category F: Cross-Version Testing

### F-01: Android 12 (API 31)

**Device:** Any device running Android 12.

**Steps:**

1. Install app and complete onboarding.
2. Verify `SCHEDULE_EXACT_ALARM` behavior.
3. Schedule reminder → verify fires.
4. Trigger escalation → verify FULLSCREEN works
   (auto-granted on Android 12).
5. Run Category A tests (A-01 through A-05).

**Expected Result:** Full functionality on Android 12.

**Pass Criteria:** All alarm reliability tests pass.
Full-screen intent works without special permission.

---

### F-02: Android 13 (API 33)

**Device:** Any device running Android 13.

**Steps:**

1. Install app and complete onboarding.
2. Verify `POST_NOTIFICATIONS` runtime permission
   is requested (new in Android 13).
3. Grant and verify notifications work.
4. Run Category A and D tests.

**Expected Result:** POST_NOTIFICATIONS handled
correctly. All features work.

**Pass Criteria:** Notification permission requested
and granted. Alarms and escalation work.

---

### F-03: Android 14 (API 34)

**Device:** Any device running Android 14.

**Steps:**

1. Install app and complete onboarding.
2. Verify `USE_FULL_SCREEN_INTENT` handling (special
   permission on Android 14).
3. If not auto-granted, follow guidance to enable.
4. Trigger escalation → verify FULLSCREEN works.
5. Verify exact alarm uses `USE_EXACT_ALARM` (may be
   auto-granted for health apps).
6. Run Category A, D, and E tests.

**Expected Result:** Full-screen intent permission
handled. All features work.

**Pass Criteria:** Full-screen alarm works (either
directly or after user grants permission). Exact
alarms fire on time.

---

### F-04: Android 15 (API 35)

**Device:** Any device running Android 15.

**Steps:**

1. Install app and complete onboarding.
2. Verify background activity launch restrictions
   are handled (Android 15 further restricts
   `PendingIntent` launches from background).
3. Schedule reminder while app is in background.
4. Verify alarm fires and notification appears.
5. Verify escalation to FULLSCREEN works (may
   require `PendingIntent` flags adjustment).
6. Run Category A, D, and E tests.

**Expected Result:** Android 15 restrictions do not
break alarm functionality.

**Pass Criteria:** All alarm, escalation, and
permission tests pass on Android 15.

---

## General Notes

- **Test order:** Run Category E (permissions) first,
  then C (battery optimization), then A (alarm
  reliability), then B (boot), then D (escalation),
  then F (cross-version).
- **Screenshots:** Take a screenshot for every FAIL
  and PARTIAL result.
- **Timing:** Allow 2–3 hours per device for full
  checklist execution.
- **Reset between OEMs:** Factory-reset or fresh
  install the app for each device to ensure clean
  state.
- **Reference:** See `.planning/research/PITFALLS.md`
  (P-01, P-04) for detailed background on each
  pitfall.
