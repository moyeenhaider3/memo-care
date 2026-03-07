# STATE.md — MemoCare

## Project Reference

**Core value:** Linked Reminder Chains that fire based on user confirmation, not just clock time.
**Current focus:** GSD initialization pipeline — research complete, ready for requirements + roadmap.

## Current Position

- **Stage:** GSD Initialization (pre-roadmap)
- **Phase:** 6 of ~10 — Research ✅ COMPLETE
- **Progress:** [███████░░░] ~65%

## Completed Artifacts

| Phase | Artifact | Status |
|-------|----------|--------|
| 1 | Git repo + Flutter scaffold | ✅ |
| 2 | Brownfield mapping (skipped — fresh scaffold) | ✅ |
| 3 | Questioning (answers captured) | ✅ |
| 4 | `.planning/PROJECT.md` | ✅ Committed |
| 5 | `.planning/config.json` | ✅ Committed |
| 6 | `.planning/research/STACK.md` | ✅ Committed |
| 6 | `.planning/research/FEATURES.md` | ✅ Committed |
| 6 | `.planning/research/ARCHITECTURE.md` | ✅ Committed |
| 6 | `.planning/research/PITFALLS.md` | ✅ Committed |
| 6 | `.planning/research/SUMMARY.md` | ✅ Committed |

## Next Steps

| Phase | Action | Command |
|-------|--------|---------|
| 7 | Define requirements (scope categories from research) | `/gsd-requirements` |
| 8 | Create roadmap (spawn gsd-roadmapper) | `/gsd-roadmap` |
| 10 | Done banner | — |

## Recent Decisions

- NLP deferred to v1.x (VERY HIGH risk, chain engine is core value)
- Drift (SQLite) over Hive/Isar (both dead, SDK <3.0.0)
- Feature-first + layered hybrid folder structure
- Chain engine as pure Dart domain logic (no Flutter dependency)
- Lazy chain resolution (schedule immediate next step only)
- 3 separate notification channels (silent, urgent, critical)
- UTC epoch millis for all time storage

## Pending Todos

(None captured yet)

## Blockers / Concerns

- TFLite compatibility with Dart 3.10 needs hands-on validation (v1.x)
- OEM alarm behavior must be tested on physical Xiaomi/Samsung/Huawei devices
- Elderly user testing needed — recruit 3+ users aged 65+ for UAT

## Session Continuity

Last session: 2026-03-07
Stopped at: Phase 6 research completed. Ready for Phase 7 (requirements).
Resume file: none
