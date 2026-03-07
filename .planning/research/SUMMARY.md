# Project Research Summary

**Project:** MemoCare
**Domain:** Offline-first chain-triggered medication reminder (Android/Flutter)
**Researched:** 2026-03-07
**Confidence:** HIGH

---

## Executive Summary

MemoCare is a DAG-based Linked Reminder Chain engine for Android that fires medication reminders based on user confirmations and meal anchors — not just clock time. Research confirms that **no existing competitor** (Medisafe, MyTherapy, Round Health) implements chain logic, meal-anchored timing, or accessibility-first design for elderly users. This is genuinely unoccupied territory.

The recommended approach is a **five-layer Flutter architecture** (Presentation → Application/State → Domain → Data → Platform Services) with the chain engine as pure Dart domain logic, Drift (SQLite) for relational storage of DAG structures, and Riverpod for reactive state management. The critical technical risk is **Android notification reliability across OEMs** — Xiaomi, Samsung, and Huawei aggressively kill background processes, making exact alarm delivery the hardest engineering problem in the app.

NLP via TensorFlow Lite should be **deferred to v1.x**. The chain engine is the core value proposition; NLP is an input method enhancement. Ship v1 with templates + forms, validate chain logic with real users, then layer NLP on top.

---

## Key Findings

### Recommended Stack

*Full details: [STACK.md](STACK.md)*

**Core technologies:**
- **Flutter 3.38.2 / Dart 3.10.0** — existing scaffold, Android-only for v1, cross-platform optionality for v2
- **Drift ^2.32.0 (SQLite)** — type-safe relational DB for DAG structures (chains, edges, triggers). Hive and Isar are both dead (SDK <3.0.0)
- **flutter_riverpod ^3.2.1** — state management with no BuildContext dependency (critical for background isolate chain evaluation)
- **android_alarm_manager_plus ^5.0.0** — exact alarms via `setExactAndAllowWhileIdle()` for medication timing
- **flutter_local_notifications ^21.0.0** — full-screen intent support for escalation tier 3
- **freezed ^3.2.5** — immutable union types for `ConfirmationState.done/.snoozed/.skipped` and `MedicineType`
- **fpdart ^1.2.0** — `Either<Failure, Success>` for chain engine error handling

**33 total packages** (22 runtime, 5 code-gen, 3 lint, 3 test). Build time: 15-30s initial code generation, 2-5s incremental.

### Expected Features

*Full details: [FEATURES.md](FEATURES.md)*

**Must have (table stakes — P0/P1):**
- Reliable notification engine with OEM-aware battery optimization guidance
- Linked Reminder Chain engine with DAG evaluation
- Meal-anchored medication timing (5 medicine types)
- DONE / SNOOZED / SKIPPED confirmation from notification
- 3-tier escalation: silent → sound+vibration → full-screen takeover
- 3 template packs (Diabetic, BP, School Morning)
- Daily schedule view + medication history log
- Accessibility-first UI (18pt+, 56dp+ touch targets, TTS readout)
- Guided onboarding: condition → template → anchors → medicines → review
- Offline-first storage (SQLite, zero network dependency)

**Should have (P2 — add in v1.x):**
- Hydration reminders with daily counter (LOW effort, independent of chains)
- Course tracker with progress bar (LOW effort)
- Voice command support for hands-free confirmation

**Defer (v2+):**
- Conversational NLP setup (VERY HIGH risk, needs dedicated ML engineering)
- Caregiver/family portal (requires cloud backend, auth, permissions)
- Ramadan/fasting mode, social reminders, kids dashboard, visual timeline builder

### Architecture Approach

*Full details: [ARCHITECTURE.md](ARCHITECTURE.md)*

A **feature-first + layered hybrid** structure under `lib/` with five architectural layers. The domain layer is pure Dart (no Flutter imports) for testability and isolate compatibility.

**Major components:**
1. **ChainEngine** — pure Dart DAG evaluator. Receives confirmed node + state, returns downstream reminders to activate/suspend. Stateless.
2. **AnchorResolver** — converts fuzzy anchors ("after lunch") to precise `DateTime` values. Recalculates all dependent reminder times when an anchor is confirmed.
3. **EscalationFSM** — finite state machine driving SILENT → AUDIBLE → FULLSCREEN with configurable timeouts per tier.
4. **Drift DAOs** — `ChainDao`, `ReminderDao`, `ConfirmationDao` with reactive streams. Schema: `reminder_chains`, `reminders`, `chain_edges`, `confirmations`, `meal_anchors`.
5. **AlarmScheduler** — wraps `android_alarm_manager_plus`. Callbacks run in background isolates — must open fresh Drift DB, pass only IDs (not objects).
6. **NotificationSvc** — three separate notification channels (silent, urgent, critical). Full-screen intent for tier 3.

**Key architectural decisions:**
- Chain engine never calls platform services directly — Riverpod notifiers orchestrate domain → platform handoff
- Provider families for per-entity state (`chainStateNotifierProvider(chainId)`)
- All times stored as UTC epoch millis in Drift, converted for display
- Alarm callback is a top-level function (isolate requirement), re-hydrates from Drift

### Critical Pitfalls

*Full details: [PITFALLS.md](PITFALLS.md)*

**BLOCKER-level (must solve before ship):**
1. **P-01: OEM battery killers** — Xiaomi/Samsung/Huawei silently murder background alarms. Mitigation: foreground service, OEM-specific onboarding guidance, WorkManager heartbeat fallback.
2. **P-02: DAG cycles/deadlocks** — circular chain dependencies cause infinite loops. Mitigation: topological sort (Kahn's algorithm) on every chain mutation, max depth limit of 10.
3. **P-07: Accessibility theater** — claiming accessible but failing real elderly users. Mitigation: test at 200% font scale, 56dp+ touch targets, TalkBack testing, recruit 65+ users for UAT.
4. **P-11: Boot-completed receiver** — phone restart clears all alarms. Mitigation: register `BOOT_COMPLETED` + `ACTION_MY_PACKAGE_REPLACED` receivers, headless Flutter engine to reschedule from Drift.

**HIGH-level (must address in relevant phase):**
5. **P-03: Drift migration failures** — add columns nullable/with defaults, test upgrade path matrix, nuclear fallback to JSON export
6. **P-04: Full-screen intent permissions** — Android 14+ changed rules. Check `canUseFullScreenIntent()`, degrade to high-priority notification if denied
7. **P-05: Battery drain** — batch alarms within 2-min windows, cap snooze retries, alarm-as-scheduler pattern
8. **P-06: Cascade storm** — lazy resolution (only schedule immediate next step), isolate for >5 node computation
9. **P-09: Snooze loops** — max 3 snoozes then auto-SKIP, finite state machine for snooze progression
10. **P-10: Timezone/DST** — store UTC epoch millis, use `timezone` package for display, test spring-forward/fall-back

---

## Implications for Roadmap

Based on research, the dependency graph reveals a clear critical path:

```
Storage → Data Model → Notification Engine → Confirmation States → Chain Engine → Meal Anchoring → Templates → Onboarding → UI Polish
```

### Phase 1: Project Foundation
**Rationale:** Establish architecture, dependencies, code generation pipeline before any feature code
**Delivers:** `pubspec.yaml` with all dependencies, Drift database definition, folder structure, lint configuration, code-gen pipeline
**Addresses:** Stack setup from STACK.md
**Avoids:** P-03 (migration framework from day 1), P-10 (UTC time storage decision)

### Phase 2: Data Layer + Models
**Rationale:** All features depend on the data model. Chain engine can't exist without the DAG schema.
**Delivers:** Drift tables (`reminder_chains`, `reminders`, `chain_edges`, `confirmations`, `meal_anchors`), DAOs, Freezed domain models, Riverpod database providers
**Addresses:** TS-1 (medication data model), TS-9 (offline storage)
**Avoids:** P-03 (migration framework), P-10 (time storage format)

### Phase 3: Notification Engine + Alarm Scheduling
**Rationale:** The #1 technical risk. Must validate on real OEM hardware before building anything that depends on it.
**Delivers:** `AlarmScheduler`, `NotificationSvc` with 3 channels, boot-completed receiver, OEM battery optimization guidance, permission request flow
**Addresses:** TS-2 (reliable notifications), TS-6 (persistent), TS-7 (sound+vibration), DF-3 (escalation stack)
**Avoids:** P-01 (OEM killers), P-04 (full-screen permissions), P-05 (battery drain), P-11 (boot rescheduling), P-12 (channel health check)

### Phase 4: Confirmation + Chain Engine
**Rationale:** The core differentiator. Depends on notification engine (to fire confirmations) and data model (to evaluate DAG).
**Delivers:** `ConfirmationService`, `ChainEngine` (DAG evaluator), `ChainValidator` (cycle detection), confirmation states, skip propagation, DONE cascades
**Addresses:** TS-3 (confirmation states), DF-1 (linked chains)
**Avoids:** P-02 (DAG cycles), P-06 (cascade storm), P-09 (snooze loops)

### Phase 5: Anchor Resolution + Meal Timing
**Rationale:** Meal-anchored timing IS chain logic — inseparable from chains but needs the chain engine working first.
**Delivers:** `AnchorResolver`, meal anchor management, 5 medicine types (before-meal, after-meal, empty-stomach, fixed-time, dose-gap)
**Addresses:** DF-2 (meal-anchored timing)

### Phase 6: Templates + Onboarding
**Rationale:** Templates instantiate chains. Onboarding guides users through setup. Both need the chain engine.
**Delivers:** 3 template packs, onboarding flow (condition → template → anchors → medicines → review), first-run experience
**Addresses:** DF-4 (templates), TS-10 (onboarding)
**Avoids:** P-UX-05 (too many onboarding steps)

### Phase 7: Daily View + History
**Rationale:** Primary UI surface. Needs chain engine + confirmations to display meaningful data.
**Delivers:** Daily schedule screen (home), medication history log, next-reminder widget
**Addresses:** TS-4 (daily view), TS-8 (history), TS-11 (settings)
**Avoids:** P-UX-03 (information overload)

### Phase 8: Accessibility + TTS + Voice
**Rationale:** Cross-cutting concern applied to all UI, but best to do a dedicated accessibility pass after UI exists.
**Delivers:** 18pt+ enforcement, high-contrast theme, TTS alert readout, voice command confirmation, TalkBack audit
**Addresses:** DF-6 (accessibility), DF-7 (TTS readout)
**Avoids:** P-07 (accessibility theater)

### Phase 9: Integration Testing + OEM Validation
**Rationale:** Validate the entire chain on real devices before release.
**Delivers:** Patrol integration tests, OEM device testing (Xiaomi, Samsung, Huawei), alarm reliability validation, permission flow testing
**Avoids:** All pitfalls validated in production-like conditions

### Phase Ordering Rationale

- **Data before notifications:** Alarm callbacks need Drift DB to load reminder details. Can't schedule without data model.
- **Notifications before chain engine:** Chain engine's value is scheduling the *next* notification on confirmation. Without reliable notifications, chains have nothing to orchestrate.
- **Chain engine before templates:** Templates are pre-built chain definitions. Without the engine to instantiate them, they're just JSON.
- **Chain engine before UI:** Daily view must show chain-aware status (pending, done, cascaded, suspended). Basic list view without chain context is misleading.
- **Accessibility as dedicated pass:** Not an afterthought, but a focused audit phase after UI screens exist. Accessibility constraints enforced from Phase 1 (design tokens, touch target minimums), but the audit catches what was missed.
- **OEM testing as final gate:** Real-device validation catches issues that emulators never surface (P-01, P-04, P-11).

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 3 (Notification Engine):** Android OEM fragmentation is vast. May need per-OEM platform channel implementations. Consult dontkillmyapp.com database during planning.
- **Phase 4 (Chain Engine):** DAG evaluation with lazy vs. eager resolution is an algorithmic design decision. Prototype both approaches before committing.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundation):** Standard Flutter project setup, well-documented
- **Phase 2 (Data Layer):** Drift documentation is excellent, patterns are well-established
- **Phase 7 (Daily View):** Standard Flutter UI, no unusual patterns

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | **HIGH** | All versions verified against pub.dev 2026-03-07. Hive/Isar confirmed dead. |
| Features | **MEDIUM-HIGH** | Competitor analysis from training data; may miss very recent feature additions |
| Architecture | **HIGH** | Patterns validated against Drift, Riverpod, and Android alarm API documentation |
| Pitfalls | **HIGH** | OEM battery issues well-documented via dontkillmyapp.com; DAG pitfalls from graph theory fundamentals |

**Overall confidence:** **HIGH**

### Gaps to Address

- **TFLite compatibility with Dart 3.10:** tflite_flutter is at 0.12.x (community-maintained). Need hands-on verification when NLP phase arrives in v1.x. Fallback: platform channel to Java TFLite API.
- **OEM-specific alarm behavior:** Must test on physical Xiaomi (MIUI), Samsung (OneUI), and Huawei (EMUI) devices. Emulator testing is insufficient for P-01.
- **Elderly user testing:** Research assumes elderly user needs based on accessibility guidelines. Actual behavior may differ. Recruit 3+ users aged 65+ for milestone UAT.
- **WorkManager reliability:** Pre-1.0 package. If periodic heartbeat is unreliable, fall back to pure AlarmManager for all scheduling.

---

## Sources

### Primary (HIGH confidence)
- **pub.dev** — all 33 package versions verified 2026-03-07
- **Drift documentation** (drift.simonbinder.eu) — DAO pattern, migrations, isolate usage
- **Riverpod documentation** (riverpod.dev) — AsyncNotifier, code-gen, provider lifecycle
- **Android developer docs** — AlarmManager, Doze, App Standby, notification channels, full-screen intent
- **dontkillmyapp.com** — OEM battery killer behaviors and severity scores

### Secondary (MEDIUM confidence)
- **Competitor feature analysis** — Medisafe, MyTherapy, Round Health public feature sets (training data for established apps)
- **WCAG 2.1 AAA guidelines** — contrast ratios, touch targets, text scaling

### Tertiary (LOW confidence)
- **tflite_flutter future compatibility** — community-maintained, pre-1.0, needs hands-on validation for Dart 3.10

---

*Research completed: 2026-03-07*
*Ready for roadmap: yes*
