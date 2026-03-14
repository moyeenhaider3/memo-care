# STATE.md — MemoCare

## Project Reference

**Core value:** Linked Reminder Chains that fire based on user confirmation, not just clock time.
**Current focus:** Phase 10 — Design System + Core UI Revamp (executing).

## Current Position

- **Stage:** Phase execution
- **Phase:** 11 of 12 — Kids Mode + Ramadan/Fasting
- **Plan:** Phase 10 fully DONE. Starting Phase 11 (11-01 Kids Dashboard)
- **Progress:** [████████████░] 90% (Phases 01-10 done, Phase 11 in progress)
- **Current Wave:** Phase 11 Wave 1 (11-01, 11-02)

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

## Next Steps

| Action                           | Command / Notes                            |
| -------------------------------- | ------------------------------------------ |
| ✅ Phase 10-01 Design System     | DONE — AppColors, AppTypography, 5-tab nav |
| ✅ Execute Wave 2: 10-02 → 10-08 | DONE — core screen revamps completed       |
| ✅ Phase 10-09 Onboarding        | DONE — 9-step PageView merged flow         |
| Next: Phase 11 Wave 1            | 11-01 Kids Dashboard, 11-02 Kids Rewards   |
| Then: Phase 11 Wave 2            | 11-03 Ramadan Screen, 11-04 Fasting Logic  |
| Then: Phase 12                   | Chain Builder + Voice Mode                 |

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

## Accumulated Context

### Roadmap Evolution

- Phase 10 added: Design System + Core UI Revamp (based on 16 Stitch design screens analysis)
- Phase 11 added: Kids Mode + Ramadan/Fasting (entirely new feature modules with independent themes)
- Phase 12 added: Visual Chain Builder + Voice Mode (canvas editor + NLP, originally deferred to v1.x)

## Pending Todos

(None captured yet)

## Blockers / Concerns

- TFLite compatibility with Dart 3.10 needs hands-on validation (v1.x)
- OEM alarm behavior must be tested on physical Xiaomi/Samsung/Huawei devices
- Elderly user testing needed — recruit 3+ users aged 65+ for UAT

## Session Continuity

Last session: 2026-03-14
Stopped at: Phase 10 fully DONE (183 tests passing). Starting Phase 11.
Total tests: 183 passing (full suite green after Phase 10 execution)
10-09 artifacts: onboarding_page_view.dart + 9 page files (welcome, profile_type, condition, template, anchors, medicines, accessibility, caregiver, celebration)
Phase 03 commits: 03-01 through 03-08 all committed to main branch
Design reference: 16 Stitch HTML screens downloaded to `.planning/design-reference/`
Design comparison: `.planning/design-reference/DESIGN_VS_CODE_COMPARISON.md` (1020 lines)
Planning rules: `.planning/PLANNING_RULES.md` (14 rules for Phases 10-12)
Phase 10 plans: 9 plans (10-01 through 10-09), Wave 1→2→3
Phase 11 plans: 4 plans (11-01 through 11-04), Wave 1→2
Phase 12 plans: 4 plans (12-01 through 12-04), Wave 1→2
