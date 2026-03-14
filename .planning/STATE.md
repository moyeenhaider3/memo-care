# STATE.md — MemoCare

## Project Reference

**Core value:** Linked Reminder Chains that fire based on user confirmation, not just clock time.
**Current focus:** Post-audit stabilization. Phases 1–10 + audit complete. Phase 11 in progress.
**Blueprint:** `docs/MemoCare_App_Blueprint.md` — complete architecture, flows, edge cases.

## Current Position

- **Stage:** Phase execution + audit complete
- **Phase:** 11 of 12 — Kids Mode + Ramadan/Fasting
- **Plan:** Phase 10 fully DONE. Audit complete. Phase 11 Wave 1 next.
- **Progress:** [█████████████░] 92% (Phases 01-10 done, audit done, Phase 11 ~50%)
- **Current Wave:** Phase 11 Wave 1 (11-01 Kids Dashboard, 11-02 Kids Rewards)
- **Tests:** 212 passing, 0 failures
- **Analysis:** 0 errors, ~10 warnings (pre-existing), ~80 infos

## Audit Summary (March 2026)

Full codebase audit completed. 12 critical + 15 medium issues found and fixed in 2 commits:

### Fixed Issues

- **Platform crashes:** iOS crash guards added to main.dart, oem_detector.dart, permission_service.dart
- **Logic bugs:** Snooze-calls-skip (hero card), null confirmation status, progress ring miscount
- **Persistence gaps:** Notification callbacks now write to DB (DONE/SNOOZE/SKIP), boot rescheduler implemented, onboarding + accessibility prefs persisted to SharedPreferences
- **Features wired:** CaregiverService for WhatsApp alerts (new file), actual permission requests in onboarding, fasting medicines from real DB (not hardcoded), caregiver alerts on missed reminders
- **Code cleanup:** Dead legacy onboarding routes removed, self-import in app_theme fixed, firstWhere safety in anchor_notifier
- **Test fixes:** All API changes reflected in tests, flaky font_scale test fixed with proper provider mocks

### Files Created

- `lib/core/platform/caregiver_service.dart` — WhatsApp notification service

### Files Modified (30 files)

- lib/main.dart, lib/core/platform/alarm_callback.dart, alarm_rescheduler.dart, oem_detector.dart, permission_service.dart
- lib/core/router/app_router.dart, lib/core/theme/app_theme.dart
- lib/features/daily_schedule/\* (home_screen, hero_card, reminder_list_tile, notifier, providers)
- lib/features/onboarding/\* (notifier, page_view, permission_step, oem_guidance)
- lib/features/settings/\* (repository, model, screen)
- lib/features/fasting/application/fasting_notifier.dart
- lib/features/anchors/application/anchor_notifier.dart
- pubspec.yaml (added url_launcher)
- test/\* (widget_test, font_scale_test, semantics_test)

## Plan Summary

| Phase | Plans | Waves | Notes                                                                                        |
| ----- | ----- | ----- | -------------------------------------------------------------------------------------------- |
| 01    | 3     | 2     | Dependencies, folder structure, Drift+bootstrap                                              |
| 02    | 4     | 4     | Enums+models, DAOs, repos+providers, unit tests                                              |
| 03    | 8     | 3     | FSM, notifications, permissions, alarms, OEM, boot, full-screen                              |
| 04    | 5     | 4     | Error types, validator (TDD), engine (TDD), confirmation, notifiers                          |
| 05    | 3     | 3     | Anchor models, resolver (TDD), notifier+integration                                          |
| 06    | 7     | 3     | Templates, onboarding state, service, router, 3 UI steps                                     |
| 07    | 5     | 3     | Router+settings, providers, home, history+settings, chain detail                             |
| 08    | 4     | 2     | TTS, undo bar, font/contrast audit, semantics+TalkBack                                       |
| 09    | 5     | 3     | Patrol infra, core flows, notification tests, offline tests, OEM manual                      |
| 10    | 9     | 3     | Design system, Home, Schedule, Settings, History, Templates, Alert, Add Reminder, Onboarding |
| 11    | 4     | 2     | Kids dashboard+theme, kids rewards, Ramadan screen+theme, fasting logic                      |
| 12    | 4     | 2     | Chain builder canvas+nodes, drag-drop+minimap+sim, voice STT, NLP parsing                    |

## Completed Artifacts

| Phase | Artifact                                             | Status        |
| ----- | ---------------------------------------------------- | ------------- |
| init  | Git repo + Flutter scaffold                          | ✅            |
| init  | `.planning/PROJECT.md`                               | ✅ Committed  |
| init  | `.planning/config.json`                              | ✅ Committed  |
| init  | `.planning/research/STACK.md`                        | ✅ Committed  |
| init  | `.planning/research/FEATURES.md`                     | ✅ Committed  |
| init  | `.planning/research/ARCHITECTURE.md`                 | ✅ Committed  |
| init  | `.planning/research/PITFALLS.md`                     | ✅ Committed  |
| init  | `.planning/research/SUMMARY.md`                      | ✅ Committed  |
| init  | `.planning/REQUIREMENTS.md`                          | ✅ Committed  |
| init  | `.planning/ROADMAP.md`                               | ✅ Committed  |
| plan  | Phase 01 plans (3 plans)                             | ✅ Committed  |
| exec  | Phase 01 execution (3 plans)                         | ✅ Verified   |
| exec  | Phase 02 execution (4 plans)                         | ✅ Verified   |
| exec  | Phase 03 execution (8 plans)                         | ✅ Verified   |
| plan  | All phase plans (01-12)                              | ✅ Created    |
| exec  | Phase 10-01 Design System Foundation                 | ✅ Done       |
| exec  | Phase 10 Wave 2 (10-02 → 10-08)                      | ✅ Done       |
| exec  | Router wiring (/schedule, /add-reminder, /templates) | ✅ Done       |
| exec  | Phase 10-09 Onboarding Revamp (9-step PageView)      | ✅ Done       |
| test  | Full test suite after Phase 10                       | ✅ 183 passed |
| audit | Full codebase audit + critical fixes                 | ✅ 212 pass   |
| doc   | `docs/MemoCare_App_Blueprint.md`                     | ✅ Created    |

## Next Steps

| Action                    | Command / Notes                           |
| ------------------------- | ----------------------------------------- |
| ✅ Phase 10 Design System | DONE                                      |
| ✅ Codebase Audit         | DONE — 12 critical + 15 medium fixed      |
| ✅ App Blueprint Document | DONE — docs/MemoCare_App_Blueprint.md     |
| Next: Phase 11 Wave 1     | 11-01 Kids Dashboard, 11-02 Kids Rewards  |
| Then: Phase 11 Wave 2     | 11-03 Ramadan Screen, 11-04 Fasting Logic |
| Then: Phase 12            | Chain Builder + Voice Mode                |

## Known Remaining Issues (Lower Priority)

| Issue                               | Severity | Notes                                     |
| ----------------------------------- | -------- | ----------------------------------------- |
| Prayer times hardcoded for Dhaka    | Medium   | Needs geolocation + Adhan library         |
| Kids mode data not persisted        | Medium   | Quest points reset on restart (in-memory) |
| google_fonts may fetch over network | Low      | Consider bundling fonts as assets         |
| No draft system for Add Reminder    | Low      | Abandoned form loses state                |
| No cloud backup                     | Low      | Future Firebase integration               |
| Caregiver portal (read-only)        | Deferred | Requires remote backend                   |

## Recent Decisions

- Dropped riverpod_generator, riverpod_annotation, riverpod_lint, custom_lint (analyzer ^9/^10 conflict with drift_dev)
- All Riverpod providers written manually (Provider/NotifierProvider/AsyncNotifierProvider)
- very_good_analysis pinned to 10.1.0 (10.2.0 needs Dart 3.11.0, SDK is 3.10.0)
- Drift resolved to 2.31.0, sqlite3 to 2.9.4 (transitive only)
- NLP deferred to v1.x (VERY HIGH risk, chain engine is core value) — **REVERSED: included in Phase 12**
- Follow design text sizes exactly (no 18px minimum override for captions/tags)
- Onboarding: merge profile-based (Stitch design) + condition-based (current) into combined flow
- Voice Mode included in scope (Phase 12) despite original deferral
- UI split into 3 phases: Phase 10 (core revamp), Phase 11 (Kids+Ramadan), Phase 12 (Chain Builder+Voice)
- Caregiver notification: WhatsApp only (no SMS gateway), triggered on missed reminder detection
- Background isolates: Fresh AppDatabase() per invocation, closed in finally blocks (cannot use Riverpod)
- Router redirect: SharedPreferences check (not in-memory notifier) for onboarding guard

## Accumulated Context

### Architecture

- Feature-first Clean Architecture with Riverpod state management
- 5 DB tables (ReminderChains, Reminders, ChainEdges, Confirmations, MealAnchors) via Drift SQLite
- 13 feature modules, 18 screens, 40+ providers
- 3 theme variants: default (navy medical), kids (purple playful), ramadan (dark navy gold)
- Background isolate pattern for alarm callbacks and boot rescheduler

### Data Flow

- All data local (SQLite + SharedPreferences), zero network dependency for core features
- Only network feature: CaregiverService WhatsApp URL via url_launcher
- Chain Engine: DAG evaluation with LAZY (DONE: immediate children) and EAGER (SKIP: full transitive) strategies
- Escalation: 3-tier FSM (Silent 2min → Audible 3min → Fullscreen) with wakelock + volume control

### Roadmap Evolution

- Phase 10 added: Design System + Core UI Revamp (based on 16 Stitch design screens analysis)
- Phase 11 added: Kids Mode + Ramadan/Fasting (entirely new feature modules with independent themes)
- Phase 12 added: Visual Chain Builder + Voice Mode (canvas editor + NLP, originally deferred to v1.x)

## Pending Todos

- Persist kids mode quest data to SharedPreferences or SQLite
- Add geolocation-based prayer time calculation (replace Dhaka hardcode)
- Implement cloud backup toggle (Firebase Firestore, deferred)
- Add draft/autosave for Add Reminder form

## Blockers / Concerns

- TFLite compatibility with Dart 3.10 needs hands-on validation (v1.x)
- OEM alarm behavior must be tested on physical Xiaomi/Samsung/Huawei devices
- Elderly user testing needed — recruit 3+ users aged 65+ for UAT

## Session Continuity

Last session: 2026-03-14
Stopped at: Full audit complete, blueprint created. Phase 11 next.
Total tests: 212 passing (0 failures)
Audit commits: 2 commits on main (c3fcedc, dba9d52)
Blueprint: docs/MemoCare_App_Blueprint.md (complete architecture, all flows, edge cases)
Design reference: 16 Stitch HTML screens in `.planning/design-reference/`
Design comparison: `.planning/design-reference/DESIGN_VS_CODE_COMPARISON.md` (1020 lines)
Planning rules: `.planning/PLANNING_RULES.md` (14 rules for Phases 10-12)
Phase 11 plans: 4 plans (11-01 through 11-04), Wave 1→2
Phase 12 plans: 4 plans (12-01 through 12-04), Wave 1→2
