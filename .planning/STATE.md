# STATE.md — MemoCare

## Project Reference

**Core value:** Linked Reminder Chains that fire based on user confirmation, not just clock time.
**Current focus:** Pre-Work scope cleanup. Aligning codebase with PlayStore Readiness Plan.
**Blueprint:** `docs/MemoCare_App_Blueprint.md` — complete architecture, flows, edge cases.
**Source of truth:** `docs/MemoCare_PlayStore_Readiness_Plan.md` — all phases, checks, and pass conditions.

## Current Position

- **Stage:** Pre-Work execution (scope cleanup)
- **Phase:** Pre-Work — Remove Ramadan, lock Say It, simplify caregiver
- **Plan:** Phases 01-10 DONE. Audit complete. Pre-Work next, then PlayStore Phases 1-5.
- **Progress:** [█████████████░░] 85% (Phases 01-10 done, audit done, Pre-Work + PlayStore phases pending)
- **Current Wave:** Pre-Work (scope cleanup before PlayStore verification)
- **Tests:** 212 passing, 0 failures (some may break during fasting removal)
- **Analysis:** 0 errors, ~10 warnings (pre-existing), ~80 infos

## Scope Changes (March 28, 2026)

Per `docs/MemoCare_PlayStore_Readiness_Plan.md` (source of truth):

### 🗑️ REMOVED: Ramadan / Fasting Mode
- Entire `lib/features/fasting/` directory (14 files) to be deleted
- All references in 18+ other files purged (template_service, app_router, app_colors, etc.)
- Phase 11 plans 11-03 and 11-04 deleted from roadmap

### 🗑️ REMOVED: Complex Caregiver System
- Replaced by single WhatsApp alert via `url_launcher` (already implemented: `caregiver_service.dart`)
- Onboarding Slide 4 simplified to WhatsApp number input

### 🔒 Say It Mode — Coming Soon
- Phase 12 plans 12-03 and 12-04 deleted from roadmap
- `speech_to_text` and `tflite_flutter` removed from pubspec
- `RECORD_AUDIO` permission removed from Manifest
- Say It tab shows Coming Soon UI only

## Audit Summary (March 2026)

Full codebase audit completed. 12 critical + 15 medium issues found and fixed in 2 commits:

### Fixed Issues

- **Platform crashes:** iOS crash guards added to main.dart, oem_detector.dart, permission_service.dart
- **Logic bugs:** Snooze-calls-skip (hero card), null confirmation status, progress ring miscount
- **Persistence gaps:** Notification callbacks now write to DB (DONE/SNOOZE/SKIP), boot rescheduler implemented, onboarding + accessibility prefs persisted to SharedPreferences
- **Features wired:** CaregiverService for WhatsApp alerts (new file), actual permission requests in onboarding, caregiver alerts on missed reminders
- **Code cleanup:** Dead legacy onboarding routes removed, self-import in app_theme fixed, firstWhere safety in anchor_notifier
- **Test fixes:** All API changes reflected in tests, flaky font_scale test fixed with proper provider mocks

### Files Created

- `lib/core/platform/caregiver_service.dart` — WhatsApp notification service

## Plan Summary

| Phase | Plans | Waves | Notes |
| ----- | ----- | ----- | ----- |
| 01 | 3 | 2 | Dependencies, folder structure, Drift+bootstrap |
| 02 | 4 | 4 | Enums+models, DAOs, repos+providers, unit tests |
| 03 | 8 | 3 | FSM, notifications, permissions, alarms, OEM, boot, full-screen |
| 04 | 5 | 4 | Error types, validator (TDD), engine (TDD), confirmation, notifiers |
| 05 | 3 | 3 | Anchor models, resolver (TDD), notifier+integration |
| 06 | 7 | 3 | Templates, onboarding state, service, router, 3 UI steps |
| 07 | 5 | 3 | Router+settings, providers, home, history+settings, chain detail |
| 08 | 4 | 2 | TTS, undo bar, font/contrast audit, semantics+TalkBack |
| 09 | 5 | 3 | Patrol infra, core flows, notification tests, offline tests, OEM manual |
| 10 | 9 | 3 | Design system, Home, Schedule, Settings, History, Templates, Alert, Add Reminder, Onboarding |
| 11 | 2 | 2 | Kids dashboard+theme, kids rewards (Ramadan REMOVED) |
| 12 | 2 | 2 | Chain builder canvas+nodes, drag-drop+minimap+sim (Voice REMOVED) |
| PW | 1 | 1 | Pre-Work: Ramadan removal, Say It lockout, caregiver simplification |
| PS1-5 | 5 | 5 | PlayStore Phases 1-5: plugins, Android config, UI audit, E2E, release |

## Next Steps

| Action | Command / Notes |
| --- | --- |
| ✅ Phase 10 Design System | DONE |
| ✅ Codebase Audit | DONE — 12 critical + 15 medium fixed |
| ✅ App Blueprint Document | DONE — docs/MemoCare_App_Blueprint.md |
| ✅ Plan Alignment | DONE — ROADMAP/STATE/REQUIREMENTS updated March 28 |
| Next: Pre-Work | Remove Ramadan code, lock Say It, clean pubspec, fix Manifest |
| Then: PlayStore Phase 1 | Plugin & dependency verification |
| Then: PlayStore Phase 2 | Android configuration deep-dive |
| Then: Phase 11 | Kids Mode (11-01, 11-02 only) |
| Then: Phase 12 | Chain Builder (12-01, 12-02 only) |
| Then: PlayStore Phase 3-5 | UI audit, E2E testing, release preparation |

## Known Remaining Issues (Lower Priority)

| Issue | Severity | Notes |
| --- | --- | --- |
| Kids mode data not persisted | Medium | Quest points reset on restart (in-memory) |
| google_fonts may fetch over network | Low | Consider bundling fonts as assets |
| No draft system for Add Reminder | Low | Abandoned form loses state |
| No cloud backup | Low | Future Firebase integration |
| `applicationId` still `com.example.memo_care` | High | Must change before Play Store submission |

## Recent Decisions

- Dropped riverpod_generator, riverpod_annotation, riverpod_lint, custom_lint (analyzer ^9/^10 conflict with drift_dev)
- All Riverpod providers written manually (Provider/NotifierProvider/AsyncNotifierProvider)
- very_good_analysis pinned to 10.1.0 (10.2.0 needs Dart 3.11.0, SDK is 3.10.0)
- Drift resolved to 2.31.0, sqlite3 to 2.9.4 (transitive only)
- NLP deferred permanently for v1 — Say It tab locked as "Coming Soon"
- Ramadan/Fasting removed permanently for v1 — per PlayStore Readiness Plan
- Follow design text sizes exactly (no 18px minimum override for captions/tags)
- Caregiver notification: WhatsApp only (no SMS gateway), triggered on missed reminder detection
- Background isolates: Fresh AppDatabase() per invocation, closed in finally blocks (cannot use Riverpod)
- Router redirect: SharedPreferences check (not in-memory notifier) for onboarding guard
- Source of truth: `docs/MemoCare_PlayStore_Readiness_Plan.md` governs all scope and feature decisions

## Accumulated Context

### Architecture

- Feature-first Clean Architecture with Riverpod state management
- 5 DB tables (ReminderChains, Reminders, ChainEdges, Confirmations, MealAnchors) via Drift SQLite
- 13 feature modules, 18 screens, 40+ providers
- 2 theme variants: default (navy medical), kids (purple playful)
- Background isolate pattern for alarm callbacks and boot rescheduler

### Data Flow

- All data local (SQLite + SharedPreferences), zero network dependency for core features
- Only network feature: CaregiverService WhatsApp URL via url_launcher
- Chain Engine: DAG evaluation with LAZY (DONE: immediate children) and EAGER (SKIP: full transitive) strategies
- Escalation: 3-tier FSM (Silent 2min → Audible 3min → Fullscreen) with wakelock + volume control

## Blockers / Concerns

- OEM alarm behavior must be tested on physical Xiaomi/Samsung/Huawei devices
- Elderly user testing needed — recruit 3+ users aged 65+ for UAT
- `applicationId` must be changed from `com.example.memo_care` before Play Store submission

## Session Continuity

Last session: 2026-03-28
Stopped at: Plan alignment complete. Pre-Work scope cleanup next.
Total tests: 212 passing (0 failures)
Audit commits: 2 commits on main (c3fcedc, dba9d52)
Blueprint: docs/MemoCare_App_Blueprint.md (complete architecture, all flows, edge cases)
Source of truth: docs/MemoCare_PlayStore_Readiness_Plan.md (PlayStore readiness)
Design reference: 16 Stitch HTML screens in `.planning/design-reference/`
Design comparison: `.planning/design-reference/DESIGN_VS_CODE_COMPARISON.md` (1020 lines)
Planning rules: `.planning/PLANNING_RULES.md` (14 rules for Phases 10-12)
Phase 11 plans: 2 plans (11-01, 11-02) — Kids Mode only (11-03, 11-04 REMOVED)
Phase 12 plans: 2 plans (12-01, 12-02) — Chain Builder only (12-03, 12-04 REMOVED)
