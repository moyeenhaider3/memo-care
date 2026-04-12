# MemoCare — Manual Test Guide & Verification

This document describes **manual test cases** aligned with the **Flutter implementation** under `lib/`. It is intended for human QA on device or emulator.

**Scope:** Routes (`lib/core/router/app_router.dart`), screens, dialogs, local persistence (Drift), notifications, WhatsApp caregiver flows, and platform permissions. There is **no REST login API** or server session in the current app code.

---

## Table of contents

1. [How to use this guide](#how-to-use-this-guide)
2. [App shell & global](#app-shell--global-tc-001--tc-012)
3. [Onboarding](#onboarding-tc-013--tc-045)
4. [Home](#home-tc-046--tc-065)
5. [Missed reminders sheet](#missed-reminders-sheet-tc-066--tc-074)
6. [Today’s schedule](#todays-schedule-tc-075--tc-084)
7. [History](#history-tc-085--tc-099)
8. [Profile / Settings](#profile--settings-tc-100--tc-125)
9. [Add reminder](#add-reminder-tc-126--tc-148)
10. [Template library](#template-library-tc-149--tc-158)
11. [Chain context](#chain-context-tc-159--tc-168)
12. [Fullscreen alarm & tray](#fullscreen-alarm--tray-tc-169--tc-188)
13. [Kids mode](#kids-mode-tc-189--tc-205)
14. [Summary & coverage](#summary--coverage)

---

## How to use this guide

| Topic | Guidance |
|--------|----------|
| **Build** | Run debug or release on a **real device** for alarms, notifications, and permissions. |
| **Fresh onboarding** | Clear app data or reinstall so `onboarding_complete` is false (SharedPreferences). |
| **After onboarding** | App lands on **Home** (`/home`). |
| **Deep links** | Routes such as `/alarm/:id`, `/kids`, `/templates` are registered in `app_router.dart`. Some have **no in-app navigation** from the main shell—use team-provided deep links, `adb`, or internal QA entry points. |
| **“API / server”** | No HTTP client for auth. “Server error” style checks map to **local DB** failures, **PDF export** errors, or **template apply** errors (snackbars). |
| **Session expired** | **Not applicable**—no login flow in `lib/`. |

**Test case format**

Each case uses:

- **Precondition** — setup before testing  
- **Steps** — numbered actions  
- **Expected result** — observable outcome  
- **Test data** — sample inputs where useful  

---

## App shell & global (TC-001 – TC-012)

### TC-001 | App shell | Bottom navigation

**Priority:** Critical  

**Precondition:** Onboarding complete; app shows main shell.

**Steps:**

1. Open the app on **Home**.
2. Tap **Schedule** (calendar icon).
3. Tap **History** (history icon).
4. Tap **Profile** (person icon).
5. Tap **Home** (house icon).

**Expected result:** Each tab switches the main content; the selected destination is highlighted; returning to a tab restores its state (StatefulShell indexed stack).

**Test data:** N/A  

**Code reference:** `lib/core/presentation/app_shell.dart`

---

### TC-002 | App shell | Center slot opens Add Reminder

**Priority:** Critical  

**Precondition:** Main shell visible.

**Steps:**

1. Tap the **center** navigation destination (empty label between Schedule and History).

**Expected result:** Navigator pushes **Add Reminder** (`/add-reminder`): title “Add Reminder”, leading close icon.

**Test data:** N/A  

**Code reference:** `app_shell.dart` — index 2 intercept → `context.push(AppRoutes.addReminder)`

---

### TC-003 | App shell | FAB opens Add Reminder

**Priority:** Critical  

**Precondition:** Main shell visible.

**Steps:**

1. Tap the **floating +** (center-docked FAB).

**Expected result:** Same as TC-002 — Add Reminder screen opens.

**Test data:** N/A  

**Code reference:** `MemoFab` in `app_shell.dart`

---

### TC-004 | App shell | Post-launch permission flow (Android)

**Priority:** High  

**Precondition:** Android; fresh install or missing critical permissions.

**Steps:**

1. Cold-start the app; wait after first frame.

**Expected result:** `PermissionService` may prompt for notifications, exact alarms, battery optimization, full-screen intent (order varies). App remains stable after grant/dismiss.

**Test data:** N/A  

**Code reference:** `app_shell.dart` → `_requestMissingPermissionsOnLaunch`

---

### TC-005 | Channel disabled banner

**Priority:** High  

**Precondition:** System has disabled one or more notification channels for MemoCare.

**Steps:**

1. Open any main tab.

**Expected result:** Red **MaterialBanner** at top: “Medication reminders may not work” with issue bullets; **FIX NOW** calls `openAppSettings`.

**Test data:** N/A  

**Code reference:** `lib/features/common/presentation/widgets/channel_disabled_banner.dart`

---

### TC-006 | Global | Orientation

**Priority:** Medium  

**Precondition:** Device rotation not locked.

**Steps:**

1. On Home, rotate the device 90°.

**Expected result:** No crash; layout remains usable.

**Test data:** N/A  

---

### TC-007 | Global | Background and resume

**Priority:** High  

**Precondition:** App on Home.

**Steps:**

1. Send app to background (Home button / gesture). Wait 10s. Reopen from recents.

**Expected result:** Same tab and state; no crash.

**Test data:** N/A  

---

### TC-008 | Global | Double-tap FAB

**Priority:** Low  

**Precondition:** Home tab.

**Steps:**

1. Double-tap the FAB quickly.

**Expected result:** Single sensible navigation to Add Reminder (no stacked broken routes).

**Test data:** N/A  

---

### TC-009 | Routing | Legacy `/settings` → Profile

**Priority:** Low  

**Precondition:** Deep link or dev navigation to `/settings`.

**Steps:**

1. Open `/settings`.

**Expected result:** Redirect to **`/profile`** (Settings screen as Profile tab).

**Test data:** N/A  

**Code reference:** `app_router.dart` redirect

---

### TC-010 | Routing | Alarm route bypasses onboarding redirect

**Priority:** Critical  

**Precondition:** Valid `/alarm/:reminderId`; onboarding incomplete optional.

**Steps:**

1. Navigate to `/alarm/<validReminderId>`.

**Expected result:** Alarm screen loads; redirect logic does **not** send user to onboarding when path starts with `/alarm`.

**Test data:** Existing `reminderId` from DB  

**Code reference:** `app_router.dart` `redirect`

---

### TC-011 | Product | No login / session

**Priority:** Medium  

**Precondition:** N/A  

**Steps:**

1. Confirm with stakeholders: app has **no** login screen or bearer token flow in `lib/`.

**Expected result:** “Session expired / 401” scenarios **do not apply** to shipped flows.

**Test data:** N/A  

---

### TC-012 | Error analogue | Local and export failures

**Priority:** Medium  

**Precondition:** N/A  

**Steps:**

1. Use **History PDF export** failure path and **Template apply** failure snackbar for “operation failed” coverage.

**Expected result:** User-visible error messages; no silent failure.

**Test data:** See TC-090, TC-151  

---

## Onboarding (TC-013 – TC-045)

**Container:** `OnboardingPageView` — `PageView` with `NeverScrollableScrollPhysics` (no swipe between steps).

**Code reference:** `lib/features/onboarding/presentation/onboarding_page_view.dart`

---

### TC-013 | Welcome | Get Started

**Priority:** Critical  

**Precondition:** Fresh install; `onboarding_complete` false.

**Steps:**

1. Launch app → Welcome gradient, “MemoCare”, **Get Started**.
2. Tap **Get Started**.

**Expected result:** Advances to Profile type (Step 1 of 7); dot indicators visible (not on Welcome/Celebration).

**Test data:** N/A  

---

### TC-014 | Onboarding | Swipe does not change step

**Priority:** Medium  

**Precondition:** On any onboarding page.

**Steps:**

1. Attempt horizontal swipe between pages.

**Expected result:** Page does not change (scroll physics disabled).

**Test data:** N/A  

---

### TC-015 | Profile type | Continue

**Priority:** Critical  

**Precondition:** Step 1 of 7.

**Steps:**

1. Select **Elderly**, **Adult**, or **Parent**.
2. Tap **Continue**.

**Expected result:** Selection stored; advances to Condition step.

**Code reference:** `profile_type_page.dart`, `onboarding_notifier.dart`

---

### TC-016 | Condition | Path with template

**Priority:** Critical  

**Precondition:** Condition step.

**Steps:**

1. Tap **Diabetes** (or BP / School Morning — non-Other).

**Expected result:** Navigates to **Template** step with packs filtered by condition.

**Code reference:** `condition_page.dart`, `template_page.dart`

---

### TC-017 | Condition | Other / Manual skips template

**Priority:** High  

**Precondition:** Condition step.

**Steps:**

1. Tap **Other / Manual Setup**.

**Expected result:** Jumps to **Anchors** (skips Template), per `onSkipTemplate` → `_goTo(_kAnchors)`.

**Test data:** N/A  

---

### TC-018 | Template | Select pack and proceed

**Priority:** High  

**Precondition:** Template step with available packs.

**Steps:**

1. Select a template pack.
2. Continue per on-screen primary action.

**Expected result:** `useTemplate` / `selectedTemplateId` set; flow continues.

**Test data:** Any listed pack  

---

### TC-019 | Template | No packs for condition

**Priority:** Medium  

**Precondition:** Condition yields empty list from `templateRepositoryProvider.getByCondition`.

**Steps:**

1. Observe empty state / skip path.

**Expected result:** Message e.g. “No templates available…”; user can skip without crash.

**Test data:** N/A  

---

### TC-020 – TC-024 | Anchors & medicines

**Priority:** Critical  

**Precondition:** Reached `AnchorsPage` and `MedicinesPage`.

**Steps:**

1. Complete anchor configuration as UI requires.
2. Add medicine rows with valid names/doses.
3. Advance to Accessibility.

**Expected result:** State held for Celebration; no crash.

**Code reference:** `anchors_page.dart`, `medicines_page.dart`

---

### TC-025 | Accessibility | Large text & high contrast

**Priority:** High  

**Precondition:** Accessibility step.

**Steps:**

1. Toggle large text and high contrast.
2. Tap **Next** (`onNext` with `largeText`, `highContrast`).

**Expected result:** `settingsRepository.setLargeText` / `setHighContrast` invoked; navigates to Caregiver.

**Code reference:** `onboarding_page_view.dart`, `accessibility_page.dart`

---

### TC-026 | Caregiver (onboarding)

**Priority:** High  

**Precondition:** Caregiver onboarding page.

**Steps:**

1. Enter optional caregiver info per screen or skip.
2. Continue to Celebration.

**Expected result:** Flow reaches Celebration page.

**Code reference:** `caregiver_page.dart`

---

### TC-027 | Celebration | Finish — success

**Priority:** Critical  

**Precondition:** Celebration; Android with permission dialogs possible.

**Steps:**

1. Tap primary action to complete onboarding / create schedule.
2. Grant **Notifications** and **Exact alarms** when prompted (Android).

**Expected result:** `completeOnboarding` path runs; `context.go(AppRoutes.home)`; `onboarding_complete` true.

**Code reference:** `celebration_page.dart`, `onboarding_notifier.dart`

---

### TC-028 | Celebration | Permissions denied

**Priority:** High  

**Precondition:** User denies notification or exact alarm during `_ensureCriticalPermissions`.

**Steps:**

1. Deny permissions; attempt finish.

**Expected result:** Error message requiring Notification + Exact Alarm; `setPermissionsGranted(false)` path; user informed.

**Test data:** N/A  

---

### TC-029 | Onboarding | System back

**Priority:** Medium  

**Precondition:** Mid-flow onboarding.

**Steps:**

1. Use Android system back.

**Expected result:** Many steps use `automaticallyImplyLeading: false` — document whether back exits app or pops; **no crash**.

**Test data:** N/A  

---

### TC-030 – TC-045 | Onboarding edge cases

**Priority:** Medium  

**Coverage:** Rotate device; background/resume; double-tap **Continue** / finish on Celebration (`_isCreating` guard); verify no duplicate chains if finish tapped twice.

---

## Home (TC-046 – TC-065)

**Code reference:** `lib/features/daily_schedule/presentation/home_screen.dart`

---

### TC-046 | Home | Loading state

**Priority:** Medium  

**Precondition:** `dailyScheduleNotifierProvider` loading.

**Steps:**

1. Open Home.

**Expected result:** Centered `CircularProgressIndicator` until data.

---

### TC-047 | Home | Error state + pull to refresh

**Priority:** Medium  

**Precondition:** Schedule async error (rare).

**Steps:**

1. If message “Something went wrong. Pull down to retry” appears, pull down.

**Expected result:** `RefreshIndicator` → `invalidate(dailyScheduleNotifierProvider)`; retry succeeds when DB OK.

---

### TC-048 | Home | Pull to refresh (happy path)

**Priority:** High  

**Precondition:** Home loaded with data.

**Steps:**

1. Pull down on scroll view.

**Expected result:** Refresh completes; list updates.

---

### TC-049 | Home | Empty schedule

**Priority:** High  

**Precondition:** No reminders for today.

**Expected result:** Empty state copy: “No reminders scheduled for today” / “Tap + to add…”.

---

### TC-050 | Home | Hero — I Took It

**Priority:** Critical  

**Precondition:** `nextPendingReminderProvider` non-null.

**Steps:**

1. On navy **NEXT UP** card, tap **I Took It**.

**Expected result:** `confirmationNotifier.confirm` with `done`; optional undo bar; hero updates.

---

### TC-051 | Home | Hero — Snooze

**Priority:** Critical  

**Precondition:** Pending reminder.

**Steps:**

1. Tap **Snooze**.

**Expected result:** Snooze until `now + snoozeDurationMinutes` from settings; confirmation `snoozed`.

---

### TC-052 | Home | All done card

**Priority:** High  

**Precondition:** No next pending reminder.

**Expected result:** Green “All done for today!” card (`_AllDoneCard`).

---

### TC-053 | Home | Timeline row → Chain context

**Priority:** High  

**Precondition:** At least one reminder in list.

**Steps:**

1. Tap a **Today’s Schedule** row (not hero).

**Expected result:** `context.push('/reminder/${reminder.id}/chain')`.

---

### TC-054 | Home | Pull to refresh

**Priority:** Medium  

**Steps:**

1. On Home, pull down on the main scroll area.

**Expected result:** `RefreshIndicator` runs; daily schedule reloads without crash.

---

### TC-055 | Home | Hydration +1 glass

**Priority:** Medium  

**Precondition:** `hydration.glasses > 0` (shows `HydrationCounter`).

**Steps:**

1. Tap **+1 glass**.

**Expected result:** `hydrationNotifier.addGlass` — count increases in label.

**Code reference:** `hydration_counter.dart`, `hydration_notifier.dart`

---

### TC-056 | Home | Undo bar — undo

**Priority:** High  

**Precondition:** After hero confirmation that returns `UndoableConfirmation`.

**Steps:**

1. Tap **UNDO** on bottom bar within countdown.

**Expected result:** `UndoConfirmationBar` → `undoConfirmationService.undo`; success snackbar or failure snackbar.

**Code reference:** `undo_confirmation_bar.dart`

---

### TC-057 | Home | Undo bar — timeout

**Priority:** Medium  

**Precondition:** Undo bar visible.

**Steps:**

1. Wait ~10s without tapping UNDO.

**Expected result:** Animation completes → `onDismissed`; bar disappears.

---

### TC-058 – TC-065 | Home edge cases

**Priority:** Medium  

**Coverage:** Rotate; background/resume; double-tap hero buttons; open app when missed reminders exist → **Missed sheet** (next section).

---

## Missed reminders sheet (TC-066 – TC-074)

**Code reference:** `missed_reminders_sheet.dart`, `home_screen.dart` (`showModalBottomSheet`, `isDismissible: false`, `enableDrag: false`)

---

### TC-066 | Missed sheet | Opens when missed exist

**Priority:** Critical  

**Precondition:** `hasMissedRemindersProvider` true on Home init.

**Steps:**

1. Navigate to Home (or cold start).

**Expected result:** Sheet shows count; drag handle visible; **cannot** dismiss by dragging away.

---

### TC-067 | Missed sheet | Done (single)

**Priority:** Critical  

**Precondition:** ≥1 unresolved missed item.

**Steps:**

1. Tap green **Done** for one reminder.

**Expected result:** `MissedSheet.done` trace path; item marked resolved locally; when all resolved, `Navigator.pop`.

---

### TC-068 | Missed sheet | Skip (single)

**Priority:** Critical  

**Steps:**

1. Tap **Skip** for one item.

**Expected result:** `MissedSheet.skip`; skipped confirmation; sheet closes when all resolved.

---

### TC-069 | Missed sheet | Mark All Done

**Priority:** High  

**Precondition:** Multiple missed.

**Steps:**

1. Tap **Mark All Done**.

**Expected result:** All done; sheet closes.

---

### TC-070 | Missed sheet | Skip All

**Priority:** High  

**Steps:**

1. Tap **Skip All**.

**Expected result:** All skipped; sheet closes.

---

### TC-071 – TC-074 | Missed sheet edge cases

**Priority:** Medium  

**Coverage:** Rapid taps on Done/Skip; many items; **list scrolls** inside a **bounded height** (`ConstrainedBox` + `Expanded` + `ListView` — not `Flexible` inside a `Column` with `mainAxisSize: min`, which used to collapse width and break text layout). **Layout:** Reminder title and time/dose render on **normal horizontal lines** (not one character per line); per-row **Done** / **Skip** stay aligned; **Mark All Done** / **Skip All** sit **above** the center-docked FAB and bottom nav (extra bottom padding). On narrow widths, details may stack above the action buttons.

---

## Today’s schedule (TC-075 – TC-084)

**Code reference:** `todays_full_schedule_screen.dart`

---

### TC-075 | Schedule | Happy path

**Priority:** High  

**Precondition:** Reminders today.

**Steps:**

1. Tap **Schedule** tab.

**Expected result:** App bar “Today’s Schedule” + today’s date; `ScheduleStatusChips`; hourly groups + `HourlyTimelineItem` rows.

---

### TC-076 | Schedule | Empty

**Priority:** Medium  

**Precondition:** Empty `todayReminders`.

**Expected result:** `ScheduleEmptyState`.

---

### TC-077 | Schedule | Error

**Priority:** Low  

**Precondition:** Provider error.

**Expected result:** Center text “Failed to load schedule”.

---

### TC-078 | Schedule | Hourly item display

**Priority:** Medium  

**Precondition:** Reminder with `chainId > 0`.

**Expected result:** “Chain linked” row in `HourlyTimelineItem` when applicable.

---

### TC-079 – TC-084 | Schedule navigation & UX

**Priority:** Medium  

**Coverage:** FAB still opens Add from shell; rotate; background; chips reflect `scheduleStatsProvider` / `hourlyGroupsProvider`.

---

## History (TC-085 – TC-099)

**Code reference:** `history_screen.dart`, `history_export_service.dart`

---

### TC-085 | History | Loading / error / retry

**Priority:** High  

**Steps:**

1. Open History; if error, tap **Retry**.

**Expected result:** Loading spinner; error UI with **Retry** → `invalidate(historyNotifierProvider)`.

---

### TC-086 | History | Week previous / next

**Priority:** Critical  

**Precondition:** History data.

**Steps:**

1. Use week strip **previous** / **next** (`_previousWeek` / `_nextWeek`).

**Expected result:** `_weekStart` shifts by 7 days; `_selectedDay` cleared; visible entries update.

---

### TC-087 | History | Day selection

**Priority:** High  

**Precondition:** Week with entries.

**Steps:**

1. Tap one day in `WeekSelectorStrip`.

**Expected result:** `_selectedDay` set; `_visibleHistoryEntries` filters to that day; donut counts recompute from visible items.

---

### TC-088 | History | Export PDF — success

**Priority:** Critical  

**Precondition:** ≥1 visible entry in selected period.

**Steps:**

1. Tap app bar **Export PDF** (`ExportPdfButton`).

**Expected result:** `HistoryScreen.exportPdf` trace; `HistoryExportService.exportPdf`; no error snackbar on success.

---

### TC-089 | History | Export PDF — empty period

**Priority:** High  

**Precondition:** Filter yields zero entries.

**Steps:**

1. Tap Export PDF.

**Expected result:** Snackbar “No history entries in the selected period.”

---

### TC-090 | History | Export PDF — still loading

**Priority:** Medium  

**Precondition:** `historyNotifierProvider` not `asData`.

**Steps:**

1. Tap Export immediately on first paint.

**Expected result:** Snackbar “History is still loading. Please try again.”

---

### TC-091 | History | Export PDF — exception

**Priority:** Medium  

**Precondition:** Force failure if testable.

**Steps:**

1. Complete export flow.

**Expected result:** Snackbar “PDF export failed: …”; `_isExportingPdf` reset in `finally`.

---

### TC-092 – TC-099 | History UX

**Priority:** Medium  

**Coverage:** `ComplianceDonutChart` matches filtered items; `DayGroupedLog`; bottom padding for FAB overlap; rotate.

---

## Profile / Settings (TC-100 – TC-125)

**Code reference:** `settings_screen.dart`, `caregiver_section.dart`, `display_settings_section.dart`, `data_export_section.dart`

---

### TC-100 | Profile | Loading / error

**Priority:** Medium  

**Expected result:** `appSettingsProvider` loading → spinner; error → “Failed to load settings”.

---

### TC-101 – TC-103 | Display settings

**Priority:** High  

**Steps:** Toggle large text, high contrast, dark mode via `DisplaySettingsSection`.

**Expected result:** `settingsRepository.setLargeText`, `setHighContrast`, `setDarkMode` persist.

---

### TC-104 – TC-106 | Notification toggles

**Priority:** High  

**Steps:** Toggle Notifications, Sound, Vibration.

**Expected result:** `setNotificationsEnabled`, `setSoundEnabled`, `setVibrationEnabled` persist.

---

### TC-107 – TC-109 | Snooze & escalation sliders

**Priority:** High  

**Steps:** Adjust Snooze duration (1–15), Silent→Audible (1–10), Audible→Full-Screen (1–10).

**Expected result:** Subtitle shows minutes; repository setters called.

---

### TC-110 | Caregiver | Add valid E.164

**Priority:** Critical  

**Steps:**

1. **Add Caregiver** → enter `+923001234567` (hint matches code).
2. **Save**.

**Expected result:** `CaregiverService.normalizeE164Phone` / `isValidE164` pass; `setCaregiverPhone`; snackbar “Caregiver WhatsApp number saved.”

---

### TC-111 | Caregiver | Invalid phone

**Priority:** High  

**Steps:**

1. Enter invalid string (e.g. `123`).
2. **Save**.

**Expected result:** Inline error “Enter a valid number like +923001234567”; dialog stays open.

---

### TC-112 | Caregiver | Remove

**Priority:** High  

**Precondition:** Caregiver linked.

**Steps:**

1. Tap **Remove**.

**Expected result:** `setCaregiverPhone('')`; **Add Caregiver** shown again.

---

### TC-113 | Caregiver | Send test alert — offline

**Priority:** High  

**Precondition:** Caregiver set; **airplane mode** / no network.

**Steps:**

1. Tap **Send Test Alert**.

**Expected result:** `CaregiverService.hasNetworkConnection` false → snackbar “No internet connection…”

---

### TC-114 | Caregiver | Send test alert — online

**Priority:** Critical  

**Precondition:** Network on; WhatsApp or browser available.

**Steps:**

1. Tap **Send Test Alert**.

**Expected result:** `sendTestAlert` launches WhatsApp or `wa.me`; snackbar “Opening WhatsApp test alert.” or failure message if launch fails.

---

### TC-115 | Caregiver | Empty phone — test alert

**Priority:** Medium  

**Precondition:** No caregiver.

**Steps:**

1. If **Send Test Alert** visible, tap (or confirm section hidden).

**Expected result:** `_sendTestAlert` returns early when `phone.isEmpty` — no crash.

---

### TC-116 – TC-117 | Data export (Settings) — stubs

**Priority:** Low  

**Steps:** Tap Export PDF / CSV in **DataExportSection**.

**Expected result:** **Stub only** (`SettingsScreen.exportPdf.stub` / `exportCsv.stub`) — **no** real file export from Settings. Real PDF export is **History** app bar (TC-088).

---

### TC-118 | Profile | Version string

**Priority:** Low  

**Steps:** Scroll to bottom.

**Expected result:** “MemoCare v1.0”.

---

### TC-119 – TC-125 | Profile header & edge cases

**Priority:** Low  

**Note:** `ProfileHeader` uses static name **User** in code — not editable on this screen. Rotate; background; rapid toggle switches.

---

## Add reminder (TC-126 – TC-148)

**Code reference:** `add_reminder_screen.dart`, `add_reminder_notifier.dart`, `add_reminder_state.dart`

**Validation (`isValid`):** Trimmed non-empty name; non-empty `selectedDays`; if type **medicine**, dose non-empty; fixed mode requires `fixedTime`; linked mode requires non-empty `linkedEvent`.

---

### TC-126 | Add | Close without save

**Priority:** Critical  

**Steps:**

1. Tap leading **close** icon.

**Expected result:** `context.pop()`; form discarded.

---

### TC-127 | Add | Reminder type grid

**Priority:** High  

**Steps:** Select Medicine, Meal, Activity, Call, Exercise, Custom.

**Expected result:** `setType`; name hint updates (`_hintForType`).

---

### TC-128 | Add | Medicine without dose — invalid

**Priority:** Critical  

**Steps:**

1. Type **Medicine**, name filled, **dose empty**.
2. Tap **Save Reminder**.

**Expected result:** Button disabled (`!state.isValid`) or error “Please fill in all required fields.” on save attempt.

---

### TC-129 | Add | Valid save — fixed time

**Priority:** Critical  

**Steps:**

1. Fill name, dose, unit; fixed time; pick future time; keep ≥1 repeat day.
2. **Save Reminder**.

**Expected result:** Permission prompts if needed; `createReminder` + `schedule` when `scheduledAt` non-null; screen pops on success.

---

### TC-130 | Add | Linked time

**Priority:** High  

**Steps:**

1. Switch to linked mode; choose meal event and offset.

**Expected result:** `MedicineType` derived from `linkedEvent`; `_computeInitialScheduledAt` uses anchor minutes.

---

### TC-131 | Add | No repeat days

**Priority:** High  

**Steps:**

1. Deselect all weekdays if UI allows.

**Expected result:** `selectedDays.isEmpty` → invalid.

---

### TC-132 | Add | Long / special character name

**Priority:** Medium  

**Steps:**

1. Enter very long name with emoji/symbols.

**Expected result:** No crash; save or clear error message.

---

### TC-133 | Add | Save with permissions granted

**Priority:** Medium  

**Precondition:** Valid form; notification + exact-alarm permissions granted.

**Expected result:** Reminder persists; alarm schedules when `scheduledAt` is set.

---

### TC-134 | Add | Permissions not granted

**Priority:** High  

**Precondition:** Deny notification + exact alarm.

**Expected result:** Error text requiring Notification and Exact Alarm; save aborted.

---

### TC-135 | Add | Chain toggle

**Priority:** Low  

**Steps:** Toggle **Add to Chain**.

**Expected result:** `toggleChainLink`; notifier still creates chain via `chainRepo.createChain` on save.

---

### TC-136 – TC-148 | Add edge cases

**Priority:** Medium  

**Coverage:** `isSaving` shows spinner on button; double save; notes field; `ReminderModeToggle` “Say It” is no-op (`onChanged` empty); rotate.

---

## Template library (TC-149 – TC-158)

**Code reference:** `template_library_screen.dart`, `template_service.dart`

**Entry:** Route `/templates` — **no** `context.push` from main shell found in `lib/`; use deep link / QA navigation.

---

### TC-149 | Template library | Search and category

**Priority:** High  

**Steps:**

1. Type in `TemplateSearchBar`.
2. Select category chips (All, Diabetes, …).

**Expected result:** Grid filters; empty state “No templates found” when no match.

---

### TC-150 | Template library | Apply success

**Priority:** Critical  

**Steps:**

1. Tap card → `TemplateDetailSheet` → Apply.

**Expected result:** `TemplateLibrary.apply` trace; success → snackbar “`<pack>` applied!”; `context.go('/home')`.

---

### TC-151 | Template library | Apply failure

**Priority:** Medium  

**Precondition:** Induce `result.fold` left (e.g. DB error in test).

**Expected result:** Snackbar “Failed: …”.

---

### TC-152 – TC-158 | Template library UX

**Priority:** Medium  

**Coverage:** Back via app bar (no leading in scaffold — use system back); rotate; 2-column grid scroll.

---

## Chain context (TC-159 – TC-168)

**Code reference:** `chain_context_screen.dart`

---

### TC-159 | Chain | App bar back

**Priority:** High  

**Steps:**

1. Tap back arrow.

**Expected result:** `context.pop()`.

---

### TC-160 | Chain | Loading / error / retry

**Priority:** High  

**Expected result:** Loading spinner; error UI “Could not load chain context.” + **Retry** → `invalidate(chainContextProvider(reminderId))`.

---

### TC-161 | Chain | Navigate to other node

**Priority:** High  

**Precondition:** Non-current upstream/downstream node.

**Steps:**

1. Tap a non-current row.

**Expected result:** `context.push('/reminder/${reminder.id}/chain')`.

---

### TC-162 | Chain | Current node not tappable

**Priority:** Medium  

**Steps:**

1. Tap **CURRENT** card.

**Expected result:** `onTap: null` for current — no navigation.

---

### TC-163 – TC-168 | Chain content

**Priority:** Medium  

**Expected result:** Sections TRIGGERED BY / CURRENT / TRIGGERS NEXT; empty hints for first/last step; footer “Part of `<chainName>`”.

---

## Fullscreen alarm & tray (TC-169 – TC-188)

**Code reference:** `alarm_screen_loader.dart`, `fullscreen_alarm_screen.dart`, `main.dart` (`_onNotificationTap`, `onNotificationAction`)

---

### TC-169 | Alarm | Cold start from notification

**Priority:** Critical  

**Precondition:** App killed; notification tap payload with `reminderId` (not action id).

**Steps:**

1. Tap notification.

**Expected result:** `MemoCareApp.initialAlarmReminderId` → `go('/alarm/$id')` after first frame.

**Code reference:** `app.dart`, `main.dart`

---

### TC-170 | Alarm | Loader — missing reminder

**Priority:** High  

**Precondition:** Deleted reminder id.

**Expected result:** `reminder == null` → post-frame `context.pop` or loading then exit.

---

### TC-171 | Alarm | Done

**Priority:** Critical  

**Steps:**

1. Tap primary done (`I've Done It` / label from theme).

**Expected result:** `AlarmScreen.acknowledge` → TTS stop; `AlarmScreen.done`; `confirm(done)`; `context.pop`.

---

### TC-172 | Alarm | Snooze

**Priority:** Critical  

**Steps:**

1. Tap the orange snooze button. Its label is **“Remind me in N min”**, where **N** is the fullscreen-alarm snooze constant (`kAlarmScreenSnoozeMinutes` in `alarm_screen_loader.dart` — **not** the general Profile snooze duration used on Home).

**Expected result:** `AlarmScreen.snooze`; `confirm(snoozed)` with `snoozeUntil`; navigation leaves the alarm route (`pop` or `go` home).

---

### TC-173 | Alarm | Skip

**Priority:** Critical  

**Steps:**

1. Tap **Skip this reminder** text button.

**Expected result:** `AlarmScreen.skip`; `confirm(skipped)`; pop.

---

### TC-174 | Alarm | Caregiver warning strip

**Priority:** Medium  

**Precondition:** `caregiverPhone` non-empty.

**Expected result:** `CaregiverWarning` visible; minutes from `silentTimeout + audibleTimeout`.

---

### TC-175 | Alarm | Chain step on card

**Priority:** Medium  

**Precondition:** `chainContextProvider` has data.

**Expected result:** `AlarmContentCard` receives `chainStep` / `chainTotal` from upstream/downstream counts.

---

### TC-176 | Alarm | Immersive UI

**Priority:** Low  

**Expected result:** `SystemChrome.setEnabledSystemUIMode(immersiveSticky)` on alarm; restored on actions.

---

### TC-177 | Notification | Tap body opens alarm

**Priority:** Critical  

**Precondition:** Foreground/background app; notification without `actionId`.

**Steps:**

1. Tap notification body.

**Expected result:** `GoRouter.go('/alarm/$reminderId')`.

---

### TC-178 | Notification | Tray action — no navigation

**Priority:** Critical  

**Precondition:** `actionId` non-empty (DONE/SNOOZE/SKIP).

**Steps:**

1. Tap action in tray.

**Expected result:** `onNotificationAction` only — **no** `go` to alarm route.

**Code reference:** `main.dart` lines 31–35

---

### TC-179 – TC-188 | Escalation audio / full-screen intent

**Priority:** High  

**Precondition:** Android; permissions.

**Expected result:** `EscalationController` coordinates notifications and **in-app** looping audio (`AudioService` / `just_audio`) so the alarm tone **continues until** the user taps **Done**, **Snooze**, or **Skip** on the fullscreen alarm (`acknowledge()` stops playback). The OS notification sound may play per system rules; continuous ringing is from the in-app loop. `EscalationController.dispose()` must **stop** audio but **not** dispose the shared `AudioService` player (Riverpod singleton). `canUseFullScreen` comes from the permission service for full-screen intent notifications.

---

## Kids mode (TC-189 – TC-205)

**Code reference:** `kids_dashboard_screen.dart`, `kids_reward_screen.dart`, `kids_reward_sound_screen.dart`, `parent_view_toggle.dart`

**Entry:** `/kids` — **no** in-app link from main shell in reviewed `lib/`; use deep link.

---

### TC-189 | Kids | Dashboard layout

**Priority:** High  

**Steps:**

1. Open `/kids`.

**Expected result:** `KidsTheme`; greeting `Good Morning/Afternoon/Evening`, child name; `ParentViewToggle`; `PointsDisplay`; `QuestProgressBar`; `DailyChecklist`; `KidsBottomNav`.

---

### TC-190 | Kids | Bottom nav — Prizes & Me

**Priority:** Medium  

**Steps:**

1. Tap **Prizes** (index 1) and **Me** (index 2).

**Expected result:** Placeholders “Prizes coming soon!”, “My Profile”.

---

### TC-191 | Kids | Complete all quests → reward route

**Priority:** High  

**Precondition:** `completeQuest` drives all quests done.

**Steps:**

1. Complete every daily quest.

**Expected result:** `rewardNotifierProvider` triggers; `consumeTrigger`; `context.go('/kids/reward')` or `'/kids/reward-sound'` based on `useSoundVariant`.

---

### TC-192 | Kids reward | Back to dashboard

**Priority:** High  

**Steps:**

1. On reward screen, tap **Back to Dashboard**.

**Expected result:** `context.go('/kids')`.

---

### TC-193 | Kids reward sound | Fanfare

**Priority:** Medium  

**Precondition:** Routed to `/kids/reward-sound`.

**Expected result:** `KidsRewardSound.playFanfare` attempts asset `cheer_fanfare.wav`; UI still works if audio fails.

---

### TC-194 | Parent view | Confirm dialog (no PIN)

**Priority:** Critical  

**Precondition:** `ParentViewToggle` with `pin` null/empty.

**Steps:**

1. Tap **Parent View** → **Switch**.

**Expected result:** `ParentViewToggle.unlock` trace; `onUnlocked` → `context.go('/home')`.

---

### TC-195 | Parent view | PIN (when configured)

**Priority:** Medium  

**Precondition:** Widget created with non-empty `pin` (if product wires it).

**Steps:**

1. Enter wrong PIN → **Incorrect PIN**.
2. Enter correct PIN → unlock → `/home`.

---

### TC-196 – TC-205 | Kids edge cases

**Priority:** Medium  

**Coverage:** Background during reward; double quest tap; mascot message strings for 0/total progress.

---

## Summary & coverage

| Metric | Value |
|--------|--------|
| **Test case IDs** | TC-001 – TC-205 |
| **Primary code map** | `lib/core/router/app_router.dart`, `lib/core/presentation/app_shell.dart`, features under `lib/features/` |

### Automated widget tests (CI)

| Area | File(s) | Notes |
|------|---------|--------|
| Alarm screen traces (Done / Snooze / Skip, escalation, confirmation) | `test/phase3_alarm_screen_trace_test.dart` | Snooze tap uses `find.textContaining('Remind me in')` so the test does not hardcode the minute value when `kAlarmScreenSnoozeMinutes` changes. |
| Notification tray actions | `test/phase4_alarm_tray_trace_test.dart` | Tray action IDs. |
| Accessibility (semantics, font scale) | `test/accessibility/*.dart` | Includes `FullScreenAlarmScreen` labels. |

Run all: `flutter test` from the project root.

### Screens / routes verified against code

| Route / screen | Primary file(s) |
|----------------|-----------------|
| Shell (tabs + FAB) | `app_shell.dart` |
| `/onboarding` | `onboarding_page_view.dart` + pages |
| `/home` | `home_screen.dart` |
| `/schedule` | `todays_full_schedule_screen.dart` |
| `/history` | `history_screen.dart` |
| `/profile` | `settings_screen.dart` |
| `/add-reminder` | `add_reminder_screen.dart` |
| `/templates` | `template_library_screen.dart` |
| `/reminder/:id/chain` | `chain_context_screen.dart` |
| `/kids`, `/kids/reward`, `/kids/reward-sound` | `kids_*_screen.dart` |
| `/alarm/:reminderId` | `alarm_screen_loader.dart`, `fullscreen_alarm_screen.dart` |

### Known limitations (for QA sign-off)

1. **Kids** and **standalone Template library** — routes exist; **documented deep link / QA entry** may be required (no shell navigation found in `lib/` grep).
2. **Profile name** — static “User” in `SettingsScreen` / `ProfileHeader`; not a live profile edit form.
3. **Settings PDF/CSV** — **stubs** only; real PDF is **History** export.
4. **`template_picker_screen.dart`** — not a separate GoRoute; onboarding uses `TemplatePage`.

---

## Document history

| Version | Date | Notes |
|---------|------|--------|
| 1.0 | 2026-04-11 | Initial manual test guide from `lib/` implementation review |
| 1.1 | 2026-04-12 | Missed-sheet layout constraints; fullscreen snooze vs profile snooze; escalation audio until acknowledge; shared `AudioService` lifecycle; CI note for `phase3` snooze finder (`textContaining`) |
