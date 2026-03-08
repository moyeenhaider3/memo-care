# Requirements: MemoCare

**Defined:** 2026-03-07
**Core Value:** Linked Reminder Chains that fire based on user confirmation, not just clock time.

## v1.0 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Foundation (FNDN)

- [x] **FNDN-01**: Project has all dependencies installed and code-gen pipeline (`build_runner`) works
- [x] **FNDN-02**: Drift database is configured with migration framework and opens successfully
- [x] **FNDN-03**: Folder structure follows feature-first + layered hybrid pattern from ARCHITECTURE.md
- [x] **FNDN-04**: Lint rules (very_good_analysis + riverpod_lint) are active and passing
- [x] **FNDN-05**: Android manifest declares all required permissions (exact alarm, notifications, full-screen intent, boot completed, wake lock, vibrate, microphone, foreground service)

### Data Model (DATA)

- [x] **DATA-01**: Drift tables exist for `reminder_chains`, `reminders`, `chain_edges`, `confirmations`, `meal_anchors`
- [x] **DATA-02**: Freezed domain models exist for ReminderChain, Reminder, ChainEdge, Confirmation, MealAnchor
- [x] **DATA-03**: DAOs expose reactive streams (`watch*`) and CRUD operations for each aggregate
- [x] **DATA-04**: All times stored as UTC epoch millis; display conversion via `intl` package
- [x] **DATA-05**: `MedicineType` enum with 5 types: beforeMeal, afterMeal, emptyStomach, fixedTime, doseGap
- [x] **DATA-06**: `ConfirmationState` enum with 3 states: done, snoozed, skipped
- [x] **DATA-07**: Riverpod providers wired for database, DAOs, and repositories

### Notifications (NOTF)

- [x] **NOTF-01**: Exact alarms fire via `android_alarm_manager_plus` using `setExactAndAllowWhileIdle()`
- [x] **NOTF-02**: Three notification channels exist: silent, urgent (sound+vibration), critical (full-screen)
- [x] **NOTF-03**: Notification action buttons (DONE / SNOOZE / SKIP) work from notification tray without opening app
- [x] **NOTF-04**: Notifications persist until user acts (not auto-dismissed)
- [x] **NOTF-05**: Boot-completed receiver reschedules all pending alarms after device restart
- [x] **NOTF-06**: App-update receiver (`ACTION_MY_PACKAGE_REPLACED`) reschedules alarms
- [x] **NOTF-07**: Permission request flow handles exact alarm, notification, and full-screen intent permissions across Android 12-15
- [x] **NOTF-08**: Notification channel health check runs on every `AppLifecycleState.resumed`; banner shown if disabled
- [x] **NOTF-09**: OEM battery optimization guidance shown during onboarding (device-specific instructions)

### Escalation (ESCL)

- [x] **ESCL-01**: Escalation progresses: SILENT (notification only) → AUDIBLE (sound + vibration) → FULLSCREEN (takeover with alarm sound)
- [x] **ESCL-02**: Escalation timeouts are configurable per user (default: 2 min silent → 3 min audible → fullscreen)
- [x] **ESCL-03**: Full-screen intent launches dedicated alarm screen with large DONE/SKIP buttons
- [x] **ESCL-04**: Full-screen gracefully degrades to high-priority notification if permission denied
- [x] **ESCL-05**: Screen stays on during full-screen escalation (wakelock)
- [x] **ESCL-06**: Alarm sound loops until user confirms/skips

### Chain Engine (CHAIN)

- [x] **CHAIN-01**: DAG-based chain engine evaluates edges from confirmed node; DONE activates downstream, SKIPPED suspends downstream
- [x] **CHAIN-02**: Topological sort (Kahn's algorithm) validates all chains on creation/mutation — rejects cycles
- [x] **CHAIN-03**: Max chain depth limited to 10 nodes
- [x] **CHAIN-04**: Lazy resolution: confirmation schedules only immediate next step(s), not entire downstream DAG
- [x] **CHAIN-05**: Chain engine is pure Dart (no Flutter imports) — runs in both main isolate and alarm callback isolate
- [x] **CHAIN-06**: Snooze limited to max 3 per reminder; after max, auto-transitions to SKIPPED with reason

### Anchor Resolution (ANCR)

- [x] **ANCR-01**: Meal anchors (breakfast, lunch, dinner) have user-configurable default times
- [x] **ANCR-02**: When user confirms a meal, AnchorResolver recalculates all dependent reminder times
- [x] **ANCR-03**: Before-meal reminders fire at (anchor_time - offset), after-meal at (anchor_time + offset)
- [x] **ANCR-04**: Dose-gap reminders fire at (previous_dose_confirmed_at + gap_hours)
- [x] **ANCR-05**: Empty-stomach reminders fire at anchor_time with pre-condition: no meal confirmed in last N hours

### Templates (TMPL)

- [x] **TMPL-01**: Diabetic Pack template creates a chain with insulin + metformin anchored to meals
- [x] **TMPL-02**: Blood Pressure Pack template creates morning/evening BP medication chain
- [x] **TMPL-03**: School Morning Pack template creates wake-up → breakfast → medicine → leave chain
- [x] **TMPL-04**: Templates are instantiated as real chains — user can customize medicine names, doses, and times after applying
- [x] **TMPL-05**: Template application runs DAG cycle validation before saving

### Onboarding (ONBD)

- [x] **ONBD-01**: First-run flow: condition picker → template suggestion → meal anchor setup → medicine entry → day review
- [x] **ONBD-02**: User can skip template and manually add medicines
- [x] **ONBD-03**: Permissions requested in batch during onboarding (notifications, exact alarm, battery optimization)
- [x] **ONBD-04**: Onboarding completes in under 3 minutes with template path
- [x] **ONBD-05**: All onboarding text is minimum 18pt with high-contrast colors

### Daily View (VIEW)

- [x] **VIEW-01**: Home screen shows today's reminders in chronological order with status indicators (pending/done/skipped/missed)
- [x] **VIEW-02**: Next pending reminder is prominently displayed at top
- [x] **VIEW-03**: User can tap any reminder to see chain context (what it triggers, what triggered it)
- [x] **VIEW-04**: Missed reminders (scheduled_time < now AND status = PENDING) surface on app open
- [x] **VIEW-05**: Settings screen for notification preferences, snooze defaults, escalation timeouts

### History (HIST)

- [x] **HIST-01**: Medication history log shows date, medication name, status (taken/skipped/missed), time confirmed
- [x] **HIST-02**: History is scrollable and paginated (no loading 1000+ rows at once)
- [x] **HIST-03**: User can filter history by medication name

### Accessibility (A11Y)

- [x] **A11Y-01**: All text is minimum 18pt; app tested at 200% system font scale
- [x] **A11Y-02**: All interactive elements have minimum 56dp touch targets
- [x] **A11Y-03**: All colors pass WCAG AAA (7:1 contrast ratio)
- [x] **A11Y-04**: Every interactive widget has a `Semantics` label readable as natural language
- [x] **A11Y-05**: TalkBack testing passes — correct focus order, all actions announced
- [x] **A11Y-06**: Text-to-speech reads medication name + dose + context aloud on each reminder
- [x] **A11Y-07**: 10-second undo bar (not 3s toast) for accidental confirmations

### Offline (OFFL)

- [x] **OFFL-01**: App launches and functions with zero network connectivity
- [x] **OFFL-02**: All reminder scheduling, chain evaluation, and confirmation logging work offline
- [x] **OFFL-03**: No login/signup required — app is single-user, local-only

## v1.x Requirements

Deferred to post-launch. Tracked for future roadmap.

### Hydration (HYDR)

- **HYDR-01**: Interval-based hydration reminders (configurable: 45/60/90 min during waking hours)
- **HYDR-02**: Daily glass counter with configurable target (default: 8 glasses)
- **HYDR-03**: Counter resets daily at configured wakeup time

### Course Tracking (CRSE)

- **CRSE-01**: Medication can have a course duration (e.g., 7-day antibiotic)
- **CRSE-02**: Progress bar shows "Day 3 of 7" on daily view and in notification
- **CRSE-03**: Course auto-completes when duration reached

### Voice Commands (VOIC)

- **VOIC-01**: User can confirm/snooze/skip reminders via voice from notification screen
- **VOIC-02**: Speech recognition supports English and Hindi commands

### NLP Setup (NLP)

- **NLP-01**: User speaks/types medication routine in natural language (Hindi or English)
- **NLP-02**: TFLite model parses input into structured chain definition
- **NLP-03**: Model size < 50MB (int8 quantized)
- **NLP-04**: Fallback to manual entry if parse confidence is low

### Smart Patterns (PTTN)

- **PTTN-01**: Detect when user consistently confirms at a different time than scheduled (median drift > 10 min over 5+ days)
- **PTTN-02**: Suggest anchor time adjustment via non-intrusive home screen card

## Out of Scope

| Feature                                 | Reason                                                                 |
| --------------------------------------- | ---------------------------------------------------------------------- |
| Caregiver/family portal                 | Requires cloud backend, auth, permissions — v2                         |
| Caregiver SMS / auto-call escalation    | Third-party telephony services — v2                                    |
| Ramadan/fasting mode                    | Complex chain rewiring around Sehri/Iftar — v2                         |
| Social/communication reminders          | Scope creep beyond medication focus — v2                               |
| iOS / web / desktop                     | Android-only for v1                                                    |
| Cloud sync / cross-device               | Offline-only for v1                                                    |
| Kids dashboard                          | Multi-user model required — v2                                         |
| Visual timeline builder (drag-and-drop) | Template + form is sufficient — v2                                     |
| Drug interaction checker                | Licensed medical database, liability — never                           |
| Pill identification (camera)            | Complex ML, orthogonal to core — never                                 |
| Gamification (streaks, badges)          | Potentially patronizing for elderly audience — revisit v2              |
| Vitals logging (weight, BP readings)    | Separate product category — v2+                                        |
| Refill reminders                        | Inventory tracking adds data entry burden — v2                         |
| Multilingual UI                         | English-only UI for v1; externalize strings from day 1 for future i18n |

## Traceability

| Requirement  | Phase    | Status  |
| ------------ | -------- | ------- |
| FNDN-01..05  | Phase 01 | Done    |
| DATA-01..07  | Phase 02 | Done    |
| NOTF-01..09  | Phase 03 | Done    |
| ESCL-01..06  | Phase 03 | Done    |
| CHAIN-01..06 | Phase 04 | Done    |
| ANCR-01..05  | Phase 05 | Done    |
| TMPL-01..05  | Phase 06 | Done    |
| ONBD-01..05  | Phase 06 | Done    |
| VIEW-01..05  | Phase 07 | Done    |
| HIST-01..03  | Phase 07 | Done    |
| A11Y-01..07  | Phase 08 | Done    |
| OFFL-01..03  | Phase 09 | Done    |

**Coverage:**

- v1.0 requirements: 62 total
- Mapped to phases: 62
- Unmapped: 0 ✓

---

_Requirements defined: 2026-03-07_
_Last updated: 2026-03-08 after all phases complete_
