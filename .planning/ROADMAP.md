# Roadmap: MemoCare

## Overview

MemoCare is built along its critical dependency path: data foundation → notification reliability → chain engine → meal anchoring → templates → UI → accessibility → validation. Each phase delivers something testable and builds on the previous. The chain engine (Phase 04) is the architectural spine — everything before it is prerequisite infrastructure, everything after it consumes chain logic.

## Phases

- [ ] **Phase 01: Project Foundation** - Dependencies, folder structure, Drift DB config, code-gen pipeline, Android manifest
- [ ] **Phase 02: Data Layer + Models** - Drift tables, DAOs, Freezed domain models, Riverpod providers
- [ ] **Phase 03: Notification Engine + Alarm Scheduling** - Exact alarms, 3 notification channels, escalation FSM, boot receiver, OEM guidance
- [ ] **Phase 04: Chain Engine + Confirmation** - DAG evaluator, cycle detection, confirmation states, skip/done propagation, snooze limits
- [ ] **Phase 05: Anchor Resolution + Meal Timing** - AnchorResolver, 5 medicine types, meal confirmation → downstream recalculation
- [ ] **Phase 06: Templates + Onboarding** - 3 template packs, guided onboarding flow, permission batch request
- [ ] **Phase 07: Daily View + History + Settings** - Home screen, schedule view, medication history, settings screen
- [ ] **Phase 08: Accessibility + TTS** - 18pt+ enforcement, high-contrast theme, TTS readout, TalkBack audit, undo bar
- [ ] **Phase 09: Integration Testing + OEM Validation** - Patrol tests, OEM device testing, alarm reliability, permission flows

## Phase Details

### Phase 01: Project Foundation

**Goal**: Establish architecture, dependencies, code-gen pipeline, and Android configuration so all subsequent phases can build on a solid foundation.
**Depends on**: Nothing (first phase)
**Requirements**: FNDN-01, FNDN-02, FNDN-03, FNDN-04, FNDN-05
**Success Criteria** (what must be TRUE):

1. `flutter pub get` succeeds with all 33 packages from STACK.md
2. `dart run build_runner build` completes without errors
3. `lib/` follows feature-first + layered structure from ARCHITECTURE.md
4. `flutter analyze` passes with zero warnings (very_good_analysis + riverpod_lint)
5. Drift database opens and creates empty tables on app launch
6. Android manifest has all required permissions declared
   **Plans**: 3 plans (01-01: Dependencies + Lint, 01-02: Folder Structure + Android Config, 01-03: Drift DB + Code-Gen + Bootstrap)

### Phase 02: Data Layer + Models

**Goal**: Create the complete data model for chains, reminders, confirmations, and anchors — the foundation every feature depends on.
**Depends on**: Phase 01
**Requirements**: DATA-01, DATA-02, DATA-03, DATA-04, DATA-05, DATA-06, DATA-07
**Success Criteria** (what must be TRUE):

1. All 5 Drift tables created with proper foreign keys and indexes
2. Freezed domain models compile with `fromJson`/`toJson` and `copyWith`
3. DAOs expose `watch*()` streams that emit on data changes
4. Repository layer maps between Drift rows and domain models
5. All times stored as UTC epoch millis (verified by unit test)
6. Riverpod providers for database, DAOs, and repositories are wired and testable
   **Plans**: 4 plans (02-01: Enums + Freezed Models, 02-02: DAOs + Database Update, 02-03: Repositories + Providers, 02-04: Unit Tests)

### Phase 03: Notification Engine + Alarm Scheduling

**Goal**: Build reliable alarm scheduling and tiered notifications — the #1 technical risk in the entire project. Must work across Android OEMs.
**Depends on**: Phase 02
**Requirements**: NOTF-01, NOTF-02, NOTF-03, NOTF-04, NOTF-05, NOTF-06, NOTF-07, NOTF-08, NOTF-09, ESCL-01, ESCL-02, ESCL-03, ESCL-04, ESCL-05, ESCL-06
**Success Criteria** (what must be TRUE):

1. Exact alarm fires at scheduled time (within 1 minute) on emulator
2. Notification shows with action buttons — tapping DONE/SNOOZE/SKIP updates state
3. Escalation progresses through 3 tiers with configurable timeouts
4. Full-screen intent launches alarm screen (or degrades to heads-up if permission denied)
5. After `adb reboot`, pending alarms are rescheduled automatically
6. Notification channel health check detects disabled channels and shows in-app banner
7. Permission request flow works on Android 12, 13, 14, 15
   **Plans**: 8 plans (03-01: EscalationFSM, 03-02: NotificationService + Channels, 03-03: Permission Flow, 03-04: AlarmScheduler + Actions, 03-05: Channel Health Check, 03-06: OEM Battery Guidance, 03-07: Boot + App-Update Receivers, 03-08: Full-Screen Alarm + Escalation Controller)

### Phase 04: Chain Engine + Confirmation

**Goal**: Implement the core differentiator — DAG-based chain evaluation where confirming/skipping a reminder propagates to downstream nodes.
**Depends on**: Phase 03
**Requirements**: CHAIN-01, CHAIN-02, CHAIN-03, CHAIN-04, CHAIN-05, CHAIN-06
**Success Criteria** (what must be TRUE):

1. Confirming DONE on a chain node schedules the immediate next node(s) via AlarmScheduler
2. Confirming SKIPPED on a chain node suspends all transitive downstream nodes
3. Cycle detection rejects circular chain definitions at creation time
4. Chain engine runs successfully in background alarm callback isolate
5. Snooze limit (3x) enforced — 4th snooze auto-transitions to SKIPPED
6. Chain evaluation completes in < 50ms for chains with ≤ 10 nodes
   **Plans**: 5 plans (04-01: ChainError + ChainEvalResult Types, 04-02: ChainValidator (TDD), 04-03: ChainEngine (TDD), 04-04: ConfirmationService + SnoozeLimiter, 04-05: ChainNotifier + ConfirmationNotifier)

### Phase 05: Anchor Resolution + Meal Timing

**Goal**: Implement meal-anchored medication timing — the bridge between "take after lunch" and a precise alarm time.
**Depends on**: Phase 04
**Requirements**: ANCR-01, ANCR-02, ANCR-03, ANCR-04, ANCR-05
**Success Criteria** (what must be TRUE):

1. User can set default times for breakfast, lunch, and dinner anchors
2. Confirming a meal recalculates all dependent reminder times and reschedules alarms
3. Before-meal, after-meal, empty-stomach, fixed-time, and dose-gap types all compute correct fire times
4. Changing an anchor time cascades to all dependent reminders in the chain
   **Plans**: 3 plans (05-01: AnchorConfig + ReminderScheduleUpdate Models, 05-02: AnchorResolver (TDD), 05-03: AnchorNotifier + Integration)

### Phase 06: Templates + Onboarding

**Goal**: Deliver the first-run experience — template packs for quick setup and a guided onboarding flow that gets users running in under 3 minutes.
**Depends on**: Phase 05
**Requirements**: TMPL-01, TMPL-02, TMPL-03, TMPL-04, TMPL-05, ONBD-01, ONBD-02, ONBD-03, ONBD-04, ONBD-05
**Success Criteria** (what must be TRUE):

1. Selecting "Diabetic Pack" creates a complete chain with insulin + metformin linked to meal anchors
2. User can customize medicine names, doses, and times after applying a template
3. Onboarding flow: condition → template → anchors → medicines → review works end-to-end
4. User can skip template and manually add medicines
5. All permissions requested during onboarding in a single batch flow
6. Onboarding text is ≥ 18pt with high-contrast colors
   **Plans**: 7 plans (06-01: TemplatePack Model + Pack Definitions, 06-02: OnboardingState + OnboardingNotifier, 06-03: TemplateService, 06-04: GoRouter + OnboardingFlow Shell, 06-05: ConditionStep + TemplatePickerScreen, 06-06: AnchorStep + MedicineStep, 06-07: ReviewStep + PermissionStep)

### Phase 07: Daily View + History + Settings

**Goal**: Build the primary UI screens — daily schedule (home), medication history, and settings.
**Depends on**: Phase 06
**Requirements**: VIEW-01, VIEW-02, VIEW-03, VIEW-04, VIEW-05, HIST-01, HIST-02, HIST-03
**Success Criteria** (what must be TRUE):

1. Home screen shows today's reminders chronologically with pending/done/skipped/missed status
2. Next pending reminder is prominently displayed at top of home screen
3. Tapping a reminder shows chain context (upstream/downstream relationships)
4. Missed reminders surface on app open with bulk DONE/SKIP option
5. History screen shows paginated medication log with filter by medication name
6. Settings screen allows configuring snooze duration, escalation timeouts, and notification preferences
   **Plans**: 5 plans (07-01: GoRouter Shell + Settings Data Layer, 07-02: Daily Schedule + History Providers, 07-03: Home Screen + Hero Card, 07-04: History Screen + Settings Screen, 07-05: Chain Context Detail + Router Wiring)

### Phase 08: Accessibility + TTS

**Goal**: Dedicated accessibility pass — enforce minimum standards, add TTS readout, audit with TalkBack, ensure elderly users can actually use the app.
**Depends on**: Phase 07
**Requirements**: A11Y-01, A11Y-02, A11Y-03, A11Y-04, A11Y-05, A11Y-06, A11Y-07
**Success Criteria** (what must be TRUE):

1. All text renders correctly at 200% system font scale — no overflow, no clipping
2. All interactive elements have ≥ 56dp touch targets
3. All color combinations pass WCAG AAA (7:1 contrast ratio)
4. TalkBack reads all interactive elements with meaningful labels in correct focus order
5. TTS speaks "Time to take [medicine], [dose], [context]" on each reminder notification
6. 10-second undo bar appears after confirming a medication
   **Plans**: 4 plans (08-01: TTSService + Alarm Integration, 08-02: UndoBar + Revert Service, 08-03: Font Scale + Touch Targets + Contrast Audit, 08-04: Semantics Labels + TalkBack Focus Order)

### Phase 09: Integration Testing + OEM Validation

**Goal**: Validate the entire flow on real devices — alarms, chains, escalation, boot rescheduling — with focus on Xiaomi, Samsung, and Huawei OEM behaviors.
**Depends on**: Phase 08
**Requirements**: OFFL-01, OFFL-02, OFFL-03
**Success Criteria** (what must be TRUE):

1. Patrol integration tests pass end-to-end: onboarding → template → confirmation → chain cascade
2. Alarms fire reliably on Xiaomi (MIUI), Samsung (OneUI), and Huawei (EMUI) physical devices
3. Boot-completed rescheduling works on all test devices
4. App launches, schedules, and fires reminders with zero network connectivity
5. Permission flows work correctly on Android 12, 13, 14, and 15
   **Plans**: 5 plans (09-01: Patrol Infrastructure, 09-02: Core Flow Tests, 09-03: Notification/Permission Tests, 09-04: Offline/Boot/History Tests, 09-05: OEM Manual Testing Checklist)

## Progress

| Phase                                    | Plans Complete | Status | Completed  |
| ---------------------------------------- | -------------- | ------ | ---------- |
| 01. Project Foundation                   | 3/3            | Done   | 2026-03-07 |
| 02. Data Layer + Models                  | 4/4            | Done   | 2026-03-07 |
| 03. Notification Engine + Alarms         | 8/8            | Done   | 2026-03-07 |
| 04. Chain Engine + Confirmation          | 5/5            | Done   | 2026-03-07 |
| 05. Anchor Resolution + Meal Timing      | 3/3            | Done   | 2026-03-07 |
| 06. Templates + Onboarding               | 7/7            | Done   | 2026-03-07 |
| 07. Daily View + History + Settings      | 5/5            | Done   | 2026-03-07 |
| 08. Accessibility + TTS                  | 4/4            | Done   | 2026-03-08 |
| 09. Integration Testing + OEM Validation | 5/5            | Done\* | 2026-03-08 |

\* Phase 09 Plan 09-05 (OEM Manual Testing) has checkpoint:human-verify — requires physical device test execution.
