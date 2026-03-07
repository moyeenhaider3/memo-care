# STATE.md — MemoCare

## Project Reference

**Core value:** Linked Reminder Chains that fire based on user confirmation, not just clock time.
**Current focus:** All 9 phases planned (44 plans total). Ready to begin execution.

## Current Position

- **Stage:** Roadmap execution — all phases planned
- **Phase:** 01 of 09 — Project Foundation (ready to execute)
- **Plan:** All 44 plans created across 9 phases
- **Progress:** [░░░░░░░░░░] 0% (planning complete, execution not started)

## Plan Summary

| Phase | Plans | Waves | Notes                                                                   |
| ----- | ----- | ----- | ----------------------------------------------------------------------- |
| 01    | 3     | 2     | Dependencies, folder structure, Drift+bootstrap                         |
| 02    | 4     | 4     | Enums+models, DAOs, repos+providers, unit tests                         |
| 03    | 8     | 3     | FSM, notifications, permissions, alarms, OEM, boot, full-screen         |
| 04    | 5     | 4     | Error types, validator (TDD), engine (TDD), confirmation, notifiers     |
| 05    | 3     | 3     | Anchor models, resolver (TDD), notifier+integration                     |
| 06    | 7     | 3     | Templates, onboarding state, service, router, 3 UI steps                |
| 07    | 5     | 3     | Router+settings, providers, home, history+settings, chain detail        |
| 08    | 4     | 2     | TTS, undo bar, font/contrast audit, semantics+TalkBack                  |
| 09    | 5     | 3     | Patrol infra, core flows, notification tests, offline tests, OEM manual |

## Completed Artifacts

| Phase | Artifact                             | Status       |
| ----- | ------------------------------------ | ------------ |
| init  | Git repo + Flutter scaffold          | ✅           |
| init  | `.planning/PROJECT.md`               | ✅ Committed |
| init  | `.planning/config.json`              | ✅ Committed |
| init  | `.planning/research/STACK.md`        | ✅ Committed |
| init  | `.planning/research/FEATURES.md`     | ✅ Committed |
| init  | `.planning/research/ARCHITECTURE.md` | ✅ Committed |
| init  | `.planning/research/PITFALLS.md`     | ✅ Committed |
| init  | `.planning/research/SUMMARY.md`      | ✅ Committed |
| init  | `.planning/REQUIREMENTS.md`          | ✅ Committed |
| init  | `.planning/ROADMAP.md`               | ✅ Committed |
| plan  | Phase 01 plans (3 plans)             | ✅ Committed |
| plan  | Phase 02 plans (4 plans)             | ✅ Created   |
| plan  | Phase 03 plans (8 plans)             | ✅ Created   |
| plan  | Phase 04 plans (5 plans)             | ✅ Created   |
| plan  | Phase 05 plans (3 plans)             | ✅ Created   |
| plan  | Phase 06 plans (7 plans)             | ✅ Created   |
| plan  | Phase 07 plans (5 plans)             | ✅ Created   |
| plan  | Phase 08 plans (4 plans)             | ✅ Created   |
| plan  | Phase 09 plans (5 plans)             | ✅ Created   |

## Next Steps

| Action                                | Command                |
| ------------------------------------- | ---------------------- |
| Execute Phase 01: Project Foundation  | `/gsd-execute-phase 1` |
| Execute Phase 02: Data Layer + Models | `/gsd-execute-phase 2` |

## Recent Decisions

- NLP deferred to v1.x (VERY HIGH risk, chain engine is core value)
- Drift (SQLite) over Hive/Isar (both dead, SDK <3.0.0)
- Feature-first + layered hybrid folder structure
- Chain engine as pure Dart domain logic (no Flutter dependency)
- Lazy chain resolution (schedule immediate next step only)
- 3 separate notification channels (silent, urgent, critical)
- UTC epoch millis for all time storage
- @DataClassName('XxxRow') on Drift tables to avoid collision with Freezed models
- TDD approach for ChainValidator, ChainEngine, and AnchorResolver
- Phase 09-05 requires physical OEM device testing (checkpoint:human-verify)

## Pending Todos

(None captured yet)

## Blockers / Concerns

- TFLite compatibility with Dart 3.10 needs hands-on validation (v1.x)
- OEM alarm behavior must be tested on physical Xiaomi/Samsung/Huawei devices
- Elderly user testing needed — recruit 3+ users aged 65+ for UAT

## Session Continuity

Last session: 2026-03-07
Stopped at: All 9 phases planned. Ready for `/gsd-execute-phase 1`.
Resume file: none
