# PITFALLS.md — MemoCare

> **Domain:** Offline-first chain-triggered medication reminder (Android/Flutter)
> **Date:** 2026-03-07
> **Confidence:** High — based on production patterns from Android alarm scheduling, OEM behavior databases, and DAG execution engines
> **Scope:** v0.1 through v1.x milestones

---

## 1. Critical Pitfalls

### P-01: Android OEM Battery Killers Silently Murder Alarms

**What goes wrong:** Scheduled alarms via `android_alarm_manager_plus` never fire on Xiaomi (MIUI), Samsung (OneUI 5+), Huawei (EMUI), Oppo (ColorOS), and Vivo (FuntouchOS). The user misses critical medication — the exact failure the app exists to prevent.

**Why it happens:** OEMs add proprietary battery optimization layers on top of stock Android Doze. MIUI's "Battery Saver" kills background processes after 10 minutes. Samsung's "Sleeping Apps" list silently adds apps after 3 days of low foreground use. These bypass `AlarmManager.setExactAndAllowWhileIdle()`.

**How to avoid:**

- Use a **foreground service with notification** for active reminder windows (not just alarm callbacks)
- Implement OEM-specific detection: check `Build.MANUFACTURER` and guide users through whitelisting (AutoStart on Xiaomi, "Unmonitored apps" on Samsung)
- Show an onboarding screen with device-specific battery optimization disable instructions
- Use `RequestIgnoreBatteryOptimizations` intent (but know Google Play restricts this to specific categories — medication reminders qualify under "health")
- **Fallback heartbeat:** Schedule a `WorkManager` periodic task (15-min minimum) as a secondary check that re-fires missed alarms

**Warning signs:** QA passes on Pixel/emulator but field reports show missed reminders. Crash-free rate is high but "alarm fired" analytics events drop off after 48 hours on specific OEMs.

**Phase to address:** Phase 70 (Notification Engine) — must be the first thing validated on real OEM hardware.

---

### P-02: Chain Engine DAG Cycles and Deadlocks

**What goes wrong:** A user (or template pack) creates a reminder chain where step A depends on step B which depends on step A — a cycle. The chain engine loops infinitely or deadlocks waiting for a confirmation that can never arrive. Alternatively, orphaned nodes (no parent fires them) silently never execute.

**Why it happens:** DAG validation isn't enforced at write time. The chain builder UI allows arbitrary linking. Template pack import doesn't run cycle detection. A "dose-gap" reminder that depends on "after-meal" which depends on "before-meal" seems linear but can cycle if the user edits the after-meal to also trigger on the dose-gap's completion.

**How to avoid:**

- Run **topological sort** (Kahn's algorithm) on every chain mutation — reject if cycle detected
- Store `in_degree` counts in Drift and validate invariants on write
- Limit max chain depth to 10 (no medical regimen needs deeper)
- Add `chain_id` + `position_in_chain` columns for fast orphan detection queries
- Unit test: generate random DAGs with 100+ nodes, assert no cycle passes validation

**Warning signs:** `StackOverflowError` in chain traversal. Reminders that appear in the DB but never show as notifications. Users report "my evening pills never remind me."

**Phase to address:** Phase 71 (Chain Engine Core) — cycle detection must be a hard invariant, not a nice-to-have.

---

### P-03: Drift Schema Migrations Break on App Updates

**What goes wrong:** User updates from v1.0 to v1.1, migration step 2→3 fails, Drift throws `SqliteException`, app crashes on launch. User's entire medication history is lost or inaccessible.

**Why it happens:** Drift migrations are imperative SQL. Skipping a version (1→3 directly), renaming columns without `ALTER TABLE`, or adding NOT NULL columns without defaults all crash. Testing only covers fresh installs, not upgrade paths from every prior version.

**How to avoid:**

- Write **every migration as a separate numbered `.dart` file** with rollback SQL
- Test upgrade path matrix: v1→v2, v1→v3, v2→v3 in integration tests
- Always add columns as `NULLABLE` or with `DEFAULT` values
- Keep a `schema_version` audit log table that records every migration applied
- **Nuclear fallback:** If migration fails, export all data to JSON backup before attempting migration, restore on failure
- Never use `ALTER TABLE RENAME COLUMN` (not supported in SQLite < 3.25.0, and many Android devices ship older SQLite)

**Warning signs:** Works on emulator (ships latest SQLite) but crashes on Android 10 devices with older SQLite. Migration tests only run on fresh DB.

**Phase to address:** Phase 70 (Data Layer) — establish migration framework before first schema is finalized.

---

### P-04: Full-Screen Intent Permissions Across Android Versions

**What goes wrong:** The 3rd-tier escalation (full-screen takeover alarm) silently downgrades to a heads-up notification on Android 14+ because the app lacks `USE_FULL_SCREEN_INTENT` permission, which became a special permission requiring user grant in Android 14 (API 34).

**Why it happens:** Android 12 introduced `SCHEDULE_EXACT_ALARM` (auto-granted for alarm apps). Android 13 added `POST_NOTIFICATIONS` runtime permission. Android 14 made `USE_FULL_SCREEN_INTENT` a special permission — only auto-granted for apps in the "Communication" or "Alarm" category. Android 15 further restricted background activity launches. Each version changes the rules.

**How to avoid:**

- Check `NotificationManager.canUseFullScreenIntent()` on Android 14+ before relying on it
- If denied, guide user to Settings → Apps → Special access → Full-screen notifications
- Declare `<category android:name="android.intent.category.ALARM" />` in manifest to get auto-grant on Android 14
- For Android 15+: use `PendingIntent` with `FLAG_ALLOW_UNSAFE_INTENT_LAUNCH` carefully
- **Degrade gracefully:** If full-screen denied, use high-priority notification with custom sound + persistent vibration as fallback

**Warning signs:** Full-screen alarm works on Android 12 test device but not on user's Android 14 phone. No crash — just silent degradation.

**Phase to address:** Phase 70 (Notification Engine) and revisit at each Android version target bump.

---

### P-05: Battery Drain from Aggressive Alarm Scheduling

**What goes wrong:** A user with 8 medications × 3 doses/day × snooze retries = 50+ exact alarms/day. Android starts throttling `setExactAndAllowWhileIdle()` (minimum 9-minute window between firings in Doze). Some alarms silently delayed. Users uninstall because "it drains my battery."

**Why it happens:** Each alarm schedules independently. Snooze creates additional alarms. Chain triggers fire synchronously, each scheduling its own alarm. No batching or coalescing.

**How to avoid:**

- **Batch alarms** within a 2-minute window into a single alarm that fires multiple notifications
- Cap snooze retries per reminder (max 3 snoozes, then auto-SKIP with escalation to caregiver)
- Use a single recurring `AlarmManager` alarm every 1 minute during active hours, check Drift for due reminders (alarm-as-scheduler pattern)
- Track alarm count per day and warn if > 30
- Idle hours (11 PM – 6 AM default): switch to `WorkManager` periodic checks instead of exact alarms

**Warning signs:** `BatteryManager` stats show app in top 3 consumers. Play Console vitals show "excessive wakeups" warning.

**Phase to address:** Phase 70 (Notification Engine) — design the scheduling strategy before implementing individual alarms.

---

### P-06: Chain Cascade Storm

**What goes wrong:** User confirms a morning "before-meal" reminder. This triggers "after-meal" (30 min gap), which triggers "dose-gap" (2 hr gap), which triggers "fixed-time" afternoon set — all computed and scheduled in one synchronous burst. On a low-end device, this blocks the UI for 2+ seconds and schedules 15 alarms simultaneously.

**Why it happens:** The chain engine eagerly resolves the entire downstream DAG on each confirmation. With `fpdart` functional chains, it's tempting to do a pure recursive resolution — but pure doesn't mean fast.

**How to avoid:**

- **Lazy resolution:** On confirmation, only schedule the immediate next step(s). Each step schedules its own successors when it fires.
- Add `max_cascade_depth` per trigger (default: 1 level ahead, configurable to 2 for dose-gap)
- Use `Isolate` for chain computation if resolution touches > 5 nodes
- Add telemetry: log cascade depth per confirmation event

**Warning signs:** UI jank on "Confirm" button press. ANR reports in Play Console. Users report "the app freezes when I take my pills."

**Phase to address:** Phase 71 (Chain Engine) — architect lazy vs. eager before implementing.

---

### P-07: Accessibility Theater

**What goes wrong:** App claims 18pt+ fonts and high contrast but: touch targets are 40dp (minimum is 48dp), confirmation buttons disappear below the fold on large-text settings, TTS reads "btn_confirm_med_01" instead of "Confirm taking Metformin," screen reader skips the chain status visualization.

**Why it happens:** Accessibility tested with default font scale only. `Semantics` widgets added as afterthought. Elderly testing done by 30-year-old developers, not actual 70-year-old users with tremor and presbyopia.

**How to avoid:**

- Set minimum touch target to **56dp** (above Material's 48dp) for all interactive elements
- Test at **200% font scale** and **largest display size** on device settings
- Every widget gets a `Semantics` label that reads as natural language: "Take Metformin 500mg, tap to confirm"
- Run **TalkBack testing** as part of CI (use `flutter test` with `SemanticsHandle`)
- Recruit 3+ actual elderly users (65+) for every milestone's UAT
- Ensure all colors pass **WCAG AAA** (7:1 contrast ratio), not just AA

**Warning signs:** Accessibility audit tool shows 0 issues but real elderly user can't find the confirm button. TTS reads widget keys instead of labels.

**Phase to address:** Every phase — accessibility is not a phase, it's a constraint on every UI commit.

---

### P-08: TFLite Model Bloats APK Beyond Play Store Comfort

**What goes wrong:** The NLP model for parsing "take 2 Crocin after food" is 25MB. With Hindi support, it's 45MB. APK goes from 15MB to 60MB. Elderly users on budget Android phones with 32GB storage and slow 4G connections can't download or update the app.

**Why it happens:** TFLite models aren't tree-shaken. Dictionary/vocabulary files for Hindi NER add bulk. Default quantization (float32) isn't applied.

**How to avoid:**

- Use **int8 quantization** — reduces model 4x with < 2% accuracy loss for NER tasks
- Ship NLP as an **on-demand module** via Play Feature Delivery (deferred download post-install)
- Start with **regex + rule-based parser** for v0.x, only add TFLite in v1.x when proven necessary
- Set hard APK budget: base ≤ 20MB, with NLP module ≤ 15MB additional
- Measure model accuracy vs. rule-based on actual MemoCare input patterns before committing to ML

**Warning signs:** APK size jumps 3x when adding `tflite_flutter`. Install conversion rate drops on Play Console for low-storage devices.

**Phase to address:** v1.x milestone — explicitly deferred, but set APK budget constraints now.

---

### P-09: Snooze Loop — Infinite Deferral Without Resolution

**What goes wrong:** Elderly user snoozes "Take blood pressure medicine" 12 times across 3 hours. Each snooze reschedules. Escalation resets on snooze. The next chain step never fires because step N is perpetually SNOOZED. By evening, 6 medications are backed up in the chain.

**Why it happens:** Snooze is treated as "not yet decided" rather than a distinct state with limits. The chain engine waits for DONE/SKIPPED to propagate but SNOOZED is an infinite limbo.

**How to avoid:**

- **Max snooze count per reminder:** 3 (configurable per med type). After max, auto-transition to SKIPPED with reason "auto-skipped after max snooze"
- Snooze timeout: if snoozed 3x, fire escalation tier 3 (full-screen) regardless of normal escalation schedule
- SNOOZED state must propagate a "tentative schedule" to downstream chain steps so they aren't fully blocked
- Record snooze patterns — surface in weekly report ("You snoozed blood pressure medicine 15 times this week")

**Warning signs:** Chain steps stuck in PENDING for hours. Users report "it stopped reminding me about my other pills."

**Phase to address:** Phase 71 (Chain Engine) — snooze finite state machine must be designed with the chain propagation rules.

---

### P-10: Time Zone and DST Shifts Break Scheduled Reminders

**What goes wrong:** User in India (IST, no DST) works fine. User in US sets "take at 8 AM", clock springs forward, reminder fires at 9 AM because the stored time was UTC and the offset shifted. Dose-gap calculations using `DateTime.now()` without zone awareness produce wrong intervals.

**Why it happens:** Dart's `DateTime` has `isUtc` but no proper timezone database. `AlarmManager` uses epoch millis (UTC). Converting between local display time and stored UTC time without anchoring to a zone database causes drift.

**How to avoid:**

- Store all times as **UTC epoch millis** in Drift
- Use `timezone` package with IANA database for display conversion
- For dose-gap calculations, use `Duration` from UTC anchors, never local `DateTime` arithmetic
- DST-aware test: write tests that mock `TZ=America/New_York` and simulate spring-forward/fall-back
- India-only for v0.x? If so, hardcode IST offset (+5:30) and add timezone support in v1.x — but architecture must not assume single-zone

**Warning signs:** Reminders fire at wrong wall-clock time twice a year (DST transitions). Dose-gap reminders drift by 1 hour.

**Phase to address:** Phase 70 (Data Layer) — time storage format is a day-1 decision.

---

### P-11: Boot-Completed Receiver Fails to Reschedule Alarms

**What goes wrong:** User restarts their phone. All `AlarmManager` alarms are cleared (Android behavior). No reminders fire until user manually opens the app. Elderly users restart phones frequently (or phones auto-restart for updates overnight).

**Why it happens:** `BOOT_COMPLETED` BroadcastReceiver isn't registered, or it's registered but the Flutter engine isn't initialized in the receiver so Drift can't be queried for pending reminders.

**How to avoid:**

- Register `BOOT_COMPLETED` and `QUICKBOOT_POWERON` (HTC/some OEMs) receivers in `AndroidManifest.xml`
- In the receiver, start a **headless Flutter engine** (`FlutterEngine` in `Application.onCreate`) to query Drift and reschedule all pending alarms
- Also handle `ACTION_MY_PACKAGE_REPLACED` (app update clears alarms on some devices)
- Test: `adb reboot` as part of integration test, verify alarms fire post-boot
- Add a "last heartbeat" timestamp; if the app detects a gap > 30 min on open, re-sync all alarms

**Warning signs:** Users report "reminders stopped after I restarted my phone." No crash, no error — just silence.

**Phase to address:** Phase 70 (Notification Engine) — must be implemented alongside initial alarm scheduling.

---

### P-12: Notification Channel Disabled Without App Awareness

**What goes wrong:** User (or OEM setup wizard) disables the notification channel for medication reminders. App keeps scheduling alarms and calling `flutter_local_notifications.show()` — no error returned, but no notification appears. App thinks it's working; user gets no reminders.

**Why it happens:** `NotificationManager.notify()` silently drops notifications when the channel is disabled. There's no exception. The `areNotificationsEnabled()` API exists but apps rarely check it proactively.

**How to avoid:**

- Check `NotificationManager.areNotificationsEnabled()` **and** `NotificationChannel.getImportance() != IMPORTANCE_NONE` on each app foreground resume
- If disabled, show an **in-app banner** (not a notification, obviously) with a direct intent to channel settings
- Create notification channels with `IMPORTANCE_HIGH` and names like "Medication Reminders — Critical" so users understand the consequence of disabling
- Never bundle med reminders with non-critical notifications (e.g., weekly report) in the same channel
- Log channel state to local analytics; surface in "Diagnostic" screen

**Warning signs:** Alarm callback fires (confirmed via log), `show()` returns success, but user sees nothing. Impossible to debug without checking channel state.

**Phase to address:** Phase 70 (Notification Engine) — channel health check on every `AppLifecycleState.resumed`.

---

## 2. Technical Debt Patterns

| Shortcut                                        | Why It's Tempting                  | Long-Term Cost                                                                 |
| ----------------------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------ |
| Storing alarm times as local `DateTime` strings | Simple to read in debug            | Breaks on DST, impossible to sort/query across zones                           |
| Single Drift database file for everything       | Fast to start                      | 50MB+ DB on heavy users, migration is all-or-nothing, can't archive old chains |
| `setState` for notification state               | Quick UI update                    | State lost on widget rebuild, impossible to test, Riverpod exists for this     |
| Hardcoding escalation timings                   | "We'll make it configurable later" | Every med type needs different escalation; hardcoded = rewrite                 |
| Skipping `freezed` for chain state models       | "Too much codegen"                 | Mutable state in DAG traversal = race conditions, impossible equality checks   |
| One giant `ReminderProvider`                    | "It's all related"                 | 800-line provider, untestable, every UI rebuild triggers full chain recompute  |
| String-based medicine type checks               | `if (type == "before-meal")`       | Typo = silent bug, no exhaustive switch, add new type = grep entire codebase   |
| Platform channel for every Android API          | Direct control                     | Maintenance burden, version skew, `method_channel` error handling is verbose   |

---

## 3. Integration Gotchas

### Android Alarm Manager

- `setExactAndAllowWhileIdle()` has a **minimum 9-minute interval** in Doze on Android 12+. Scheduling two alarms 5 minutes apart? Second one gets deferred.
- `PendingIntent` extras are limited in size. Don't pass full medication JSON — pass the Drift row ID and query in the callback.
- `PendingIntent.FLAG_UPDATE_CURRENT` vs `FLAG_NO_CREATE`: Using the wrong flag silently replaces or ignores alarm updates. Use unique request codes per reminder (hash of `chain_id + step_index`).

### flutter_local_notifications

- Android 13+ requires `POST_NOTIFICATIONS` permission at runtime. The plugin's `requestPermissions()` must be called and the result checked — it can return `false` permanently if the user selects "Don't ask again."
- Custom notification sounds must be in `res/raw/`, not assets. Flutter asset bundling doesn't put files there. Requires manual Android-side setup.
- `BigTextStyleInformation` truncates at ~450 characters. Medication instructions longer than this get cut off silently.

### Drift (SQLite)

- WAL mode is enabled by default. On app crash during write, WAL file can grow unbounded. Add `PRAGMA wal_checkpoint(TRUNCATE)` on app startup.
- `SELECT` during `transaction()` block sees uncommitted writes in the same transaction (SQLite isolation is serializable within a connection). This is correct but surprising — chain state queries inside a confirmation transaction will see the just-updated state.
- Custom SQL queries bypass Drift's type safety. Every raw query is a migration risk.

### WorkManager

- Minimum periodic interval is **15 minutes**. Cannot be used as a reliable alarm for medication reminders that need minute-level precision.
- `OneTimeWorkRequest` with initial delay is **not exact** — subject to Doze batching. Only use as a fallback heartbeat, never as the primary alarm mechanism.

---

## 4. Performance Traps

### Many Medications, Long Chains

- A user on 12 medications with 3 doses each = 36 reminders/day. If each has a 3-step chain with branching, the DAG has 100+ nodes. Querying all pending nodes on boot with joins across `reminders`, `chain_steps`, and `medications` tables without proper indexing = 500ms+ on budget devices.
- **Fix:** Composite index on `(chain_id, status, scheduled_time)`. Denormalize `next_step_id` into the reminder row for O(1) chain traversal. Pre-compute daily schedule on midnight alarm.

### Riverpod Rebuild Avalanche

- `ref.watch(chainProvider(chainId))` in a `ListView` of 36 reminders. One confirmation invalidates the chain, all 36 items rebuild. On a Redmi 9A (2GB RAM), this causes 200ms frame drops.
- **Fix:** Split providers: `reminderStatusProvider(reminderId)` watches only its own status. Chain mutations notify only affected step IDs via `ref.invalidate()` targeting specific family members.

### Drift Query in UI Thread

- `select(reminders).get()` is async but runs on the main isolate's event loop. With 1000+ historical reminders, the query itself blocks the UI for 100ms+.
- **Fix:** Use Drift's `computeWithDatabase()` or run queries in a separate `Isolate` for any list exceeding 50 rows. Paginate history views.

### TTS Blocking Chain Confirmation

- `FlutterTts.speak("Take Metformin 500mg")` is async but the audio engine initialization on first call takes 300-800ms on cold start. If TTS is called before showing the notification UI, the notification appears late.
- **Fix:** Pre-initialize TTS engine on app startup. Cache the engine instance. Speak and show notification in parallel, don't await TTS before notification.

---

## 5. Security Mistakes

### Health Data Sensitivity

- Medication names, dosages, and adherence patterns are **sensitive health data** even though there's no backend. A stolen/shared phone exposes the user's entire medical regimen.
- **Mitigation:** Offer optional app-level PIN/biometric lock. Encrypt the Drift database using `sqlcipher_flutter_libs` (drop-in SQLite replacement with AES-256). Never log medication names in debug output.

### Drift Database File Access

- The `.sqlite` file is world-readable on rooted devices and accessible via `adb backup` (unless `android:allowBackup="false"` is set).
- **Mitigation:** Set `android:allowBackup="false"` in `AndroidManifest.xml` **and** `android:fullBackupContent` to exclude the DB. Use `EncryptedSharedPreferences` for any tokens/keys.

### Export/Share Features

- Weekly adherence reports exported as PDF/CSV may be shared via WhatsApp to a caregiver. If the export contains full medication details and is sent to the wrong contact, it's a privacy breach.
- **Mitigation:** Warn before export. Don't include dosages in shareable summaries unless explicitly opted in. Watermark exports with timestamp + intended recipient.

### Debug Builds Leaking Data

- `flutter run --debug` enables Dart DevTools. If a debug build is given to a beta tester, anyone on the same network can inspect the app's state, including medication data.
- **Mitigation:** Never distribute debug builds. Use `--profile` for beta testing. Strip logs with `kReleaseMode` checks.

---

## 6. UX Pitfalls — Elderly User Specific

### P-UX-01: Confirm Button Too Small or Ambiguous

Elderly users with reduced motor control need targets > 56dp. A "✓" icon without text label is meaningless. Use "I Took It ✓" with green fill, minimum 56×56dp touch area, 2dp border.

### P-UX-02: Undo Window Too Short

Confirming a medication accidentally (DONE instead of SKIP) must be reversible. A 3-second undo toast disappears before the user processes it. Use a **10-second undo bar** pinned to the bottom of the screen with large "UNDO" button.

### P-UX-03: Information Overload on Home Screen

Showing all 12 medications' chain states, next doses, adherence percentages simultaneously overwhelms. Show **only the next pending action** prominently. Everything else behind a "See All" expansion.

### P-UX-04: Notification Sound Indistinguishable

Default notification sound is the same as WhatsApp/SMS. User ignores medication reminders because they sound like everything else. Use a **distinct, configurable alarm tone** that the user picks during onboarding. Escalation Tier 2+ should use a unique, non-dismissable sound.

### P-UX-05: Onboarding Requires Too Many Steps

"Add medication → set type → set time → set chain → enable notifications → disable battery optimization → grant alarm permission → grant full-screen permission" = 8 steps before the app works. Template packs should reduce this to: "Select condition → review schedule → grant permissions (batch) → done."

### P-UX-06: Error Messages in Developer Language

"SQLiteException: UNIQUE constraint failed: reminders.chain_id" means nothing to an elderly user. Every error must be translated: "This medication time overlaps with another. Would you like to adjust?"

### P-UX-07: Font Scaling Breaks Layout

Setting phone to "Largest" font size (200% scale) causes text to overflow `Container` widgets, buttons to stack vertically off-screen, and the confirm action to become unreachable. **Every screen must be tested at 200% font scale.**

---

## 7. "Looks Done But Isn't" Checklist

- [ ] Alarms work on Pixel emulator but never tested on Xiaomi/Samsung physical device
- [ ] Notifications show in foreground but not when app is in background/killed
- [ ] Chain engine handles DONE→next but not SKIPPED→downstream propagation
- [ ] Snooze works once but second snooze overwrites the first alarm's PendingIntent (same request code)
- [ ] Migration test runs on fresh install but not on v1→v2 upgrade path
- [ ] TTS reads English but crashes on Hindi text without language pack installed
- [ ] Accessibility labels exist but TalkBack reads them in wrong order (focus order not set)
- [ ] Weekly report calculates adherence but doesn't account for SKIPPED-with-reason vs SKIPPED-missed
- [ ] Boot receiver registered but doesn't handle `ACTION_MY_PACKAGE_REPLACED` (alarms lost on app update)
- [ ] Dose-gap timer uses `DateTime.now()` which returns local time, but stored reference is UTC
- [ ] Full-screen intent works on Android 12 but silently fails on 14+ (permission not requested)
- [ ] Template pack import succeeds but doesn't run DAG cycle validation on the imported chain
- [ ] Voice command recognizes "take" but not "took" / "taken" / "le liya" (Hindi past tense)
- [ ] Notification channel created with `IMPORTANCE_DEFAULT` instead of `IMPORTANCE_HIGH`, no heads-up display

---

## 8. Recovery Strategies

### Missed Alarm Recovery

On app open, query Drift for all reminders where `scheduled_time < now AND status = PENDING`. Show a "Missed Reminders" screen. Allow bulk DONE/SKIP. Re-derive chain state from confirmed subset.

### Corrupt Database Recovery

Wrap Drift `openConnection` in try-catch. On `SqliteException`, attempt `PRAGMA integrity_check`. If failed, rename corrupt file to `.bak`, create fresh DB, and show "Data recovery needed" screen with option to export backup file to support channel.

### Chain State Inconsistency

Add a `chain_audit` function that runs on app startup: verify every chain's DAG is acyclic, every non-terminal node has a valid `next_step_id`, every DONE node has a `confirmed_at` timestamp. Log inconsistencies, auto-repair where possible (orphaned nodes → mark as SKIPPED with reason "system recovery").

### Permission Revocation Recovery

On every `AppLifecycleState.resumed`, run a permission health check: exact alarms, notifications, full-screen intent, battery optimization whitelist. Store results in a `system_health` table. If any critical permission is revoked, show a non-dismissable banner (not a dialog — elderly users dismiss dialogs reflexively).

---

## 9. Pitfall-to-Phase Mapping

| Pitfall                              | Phase                          | Priority    |
| ------------------------------------ | ------------------------------ | ----------- |
| P-01: OEM battery killers            | Phase 70 (Notification Engine) | **BLOCKER** |
| P-02: DAG cycles/deadlocks           | Phase 71 (Chain Engine)        | **BLOCKER** |
| P-03: Drift migration failures       | Phase 70 (Data Layer)          | HIGH        |
| P-04: Full-screen intent permissions | Phase 70 (Notification Engine) | HIGH        |
| P-05: Battery drain from alarms      | Phase 70 (Notification Engine) | HIGH        |
| P-06: Cascade storm                  | Phase 71 (Chain Engine)        | HIGH        |
| P-07: Accessibility theater          | All UI phases                  | **BLOCKER** |
| P-08: TFLite APK bloat               | v1.x (NLP milestone)           | MEDIUM      |
| P-09: Snooze loops                   | Phase 71 (Chain Engine)        | HIGH        |
| P-10: Timezone/DST handling          | Phase 70 (Data Layer)          | HIGH        |
| P-11: Boot-completed receiver        | Phase 70 (Notification Engine) | **BLOCKER** |
| P-12: Notification channel disabled  | Phase 70 (Notification Engine) | HIGH        |

---

## 10. Sources

- [Don't Kill My App](https://dontkillmyapp.com/) — OEM-specific background process killing behaviors, severity scores, and workarounds. Xiaomi severity: 10/10, Samsung: 8/10.
- [Android AlarmManager documentation](https://developer.android.com/reference/android/app/AlarmManager) — Exact alarm restrictions in API 31+.
- [Android 14 behavior changes](https://developer.android.com/about/versions/14/behavior-changes-14) — `USE_FULL_SCREEN_INTENT` permission requirements.
- [Android 15 behavior changes](https://developer.android.com/about/versions/15/behavior-changes-15) — Background activity launch restrictions.
- [Drift documentation](https://drift.simonbinder.eu/docs/migrations/) — Schema migration patterns and testing strategies.
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) — Channel configuration, Android 13 permission flow.
- [WCAG 2.1 AAA Guidelines](https://www.w3.org/WAI/WCAG21/quickref/) — Contrast ratios, touch target sizes, text scaling requirements.
- [Android Doze and App Standby](https://developer.android.com/training/monitoring-device-state/doze-standby) — Alarm batching behavior in Doze mode.
- [SQLCipher](https://www.zetetic.net/sqlcipher/) — SQLite encryption for health data at rest.
