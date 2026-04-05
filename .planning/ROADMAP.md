# Roadmap: MemoCare

## Overview

MemoCare is built along its critical dependency path: data foundation → notification reliability → chain engine → meal anchoring → templates → UI → accessibility → validation. Each phase delivers something testable and builds on the previous. The chain engine (Phase 04) is the architectural spine — everything before it is prerequisite infrastructure, everything after it consumes chain logic.

## Phases

- [x] **Phase 01: Project Foundation** - Dependencies, folder structure, Drift DB config, code-gen pipeline, Android manifest
- [x] **Phase 02: Data Layer + Models** - Drift tables, DAOs, Freezed domain models, Riverpod providers
- [x] **Phase 03: Notification Engine + Alarm Scheduling** - Exact alarms, 3 notification channels, escalation FSM, boot receiver, OEM guidance
- [x] **Phase 04: Chain Engine + Confirmation** - DAG evaluator, cycle detection, confirmation states, skip/done propagation, snooze limits
- [x] **Phase 05: Anchor Resolution + Meal Timing** - AnchorResolver, 5 medicine types, meal confirmation → downstream recalculation
- [x] **Phase 06: Templates + Onboarding** - 3 template packs, guided onboarding flow, permission batch request
- [x] **Phase 07: Daily View + History + Settings** - Home screen, schedule view, medication history, settings screen
- [x] **Phase 08: Accessibility + TTS** - 18pt+ enforcement, high-contrast theme, TTS readout, TalkBack audit, undo bar
- [x] **Phase 09: Integration Testing + OEM Validation** - Patrol tests, OEM device testing, alarm reliability, permission flows
- [x] **Phase 10: Design System + Core UI Revamp** - Navy theme, Inter font, bottom nav, Home/Schedule/Settings/History/Onboarding/Alert/Templates/Add Reminder revamp
- [ ] **Phase 11: Kids Mode** - Kids dashboard, rewards, mascot (Ramadan/Fasting REMOVED per PlayStore plan)
- [ ] **Phase 12: Visual Chain Builder** - Canvas node editor, drag-and-drop chains (Voice Mode REMOVED — Say It locked as Coming Soon)
- [ ] **Pre-Work: Scope Cleanup** - Remove Ramadan/Fasting, simplify caregiver to WhatsApp, lock Say It as Coming Soon
- [ ] **PlayStore Phase 1: Plugin & Dependency Verification** - pubspec audit, plugin-by-plugin runtime test
- [ ] **PlayStore Phase 2: Android Configuration** - build.gradle, Manifest, channels, battery, ProGuard
- [ ] **PlayStore Phase 3: UI Audit** - Screen-by-screen verification on device
- [ ] **PlayStore Phase 4: End-to-End Testing** - 9 functional scenarios on release build
- [ ] **PlayStore Phase 5: Release Preparation** - Signing, bundle, store listing, permissions declaration

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

### Phase 10: Design System + Core UI Revamp

**Goal:** Revamp the entire design system (navy primary #1A3C5B, Inter font, Material Symbols Outlined icons) and rebuild all existing screens to match the Stitch design specifications. Add bottom navigation, FAB, timeline visualization, and merge onboarding flows.
**Depends on:** Phase 09
**Requirements:** UI-REVAMP-01 through UI-REVAMP-08 (see Stitch design comparison report)
**Success Criteria** (what must be TRUE):

1. Design system updated: Navy primary (#1A3C5B), Inter font, accent blue (#4A90D9), success/danger/warning palette matches design tokens
2. Bottom navigation bar visible on all main screens (Home, Schedule, Templates, History, Settings)
3. Home Dashboard: User avatar + greeting, circular progress ring, navy hero card with DONE/SNOOZE, dotted timeline visualization, centered FAB
4. Today's Full Schedule: Dedicated screen with hourly timeline, summary status chips, chain grouping with lock icons, color-coded left border strips
5. Onboarding: Combined flow — Welcome splash → Profile Type (Elderly/Adult/Parent) → Condition → Template → Anchors → Accessibility toggles → Caregiver Link → Review → Celebration with page dots
6. Settings & Profile: Profile section with avatar/name/badge, Display settings (Text Size/Contrast/Dark Mode), Fasting toggle, Caregiver management, Data export
7. Template Library: Standalone browsable screen with Search bar, category filter chips, 120pt cards with icon circles and tag pills, Template Detail bottom sheet
8. History & Compliance: Week selector strip, compliance donut chart with %, Export PDF, day-grouped logs with colored status dots
9. Full-Screen Alert: Pulsing radial gradient bg, 64px time hero, white content card with step indicator, 88px DONE/SNOOZE buttons, caregiver escalation warning
10. Add Reminder (Manual): Segmented Say It/Build It toggle, Reminder type grid (Medicine/Meal/Activity/Call), Fixed Time/Linked to Event toggle, Notes textarea, Daily Repeat day-of-week pills

**Plans:** 9 plans

**Wave Structure:**

- **Wave 1:** 10-01 (Design System Foundation) — must complete first
- **Wave 2:** 10-02, 10-03, 10-04, 10-05, 10-06, 10-07, 10-08 — all parallel after Wave 1
- **Wave 3:** 10-09 (Onboarding) — depends on 10-04 (Settings) + 10-06 (Templates)

Plans:

- [ ] 10-01: Design System Foundation — AppTheme (navy #1A3C5B, Inter font, design tokens), BottomNavShell (5-tab: Home/Schedule/Add/History/Profile), centered FAB, Material Symbols Outlined icon migration, color constants, text theme, component radius tokens
- [ ] 10-02: Home Dashboard Revamp — Avatar + greeting header, circular progress ring (x/y done today), navy hero card with next-up DONE/SNOOZE, dotted timeline visualization, empty state illustration
- [ ] 10-03: Today's Full Schedule — New dedicated screen, hourly timeline with colored left border strips, summary status chips (Done/Pending/Missed counts), chain grouping with lock icons, empty state ("Rest of the day is free" tea cup)
- [ ] 10-04: Settings & Profile Revamp — Profile section (avatar/name/badge), Display settings (Text Size slider/High Contrast/Dark Mode toggle), Fasting mode toggle (gold accent), Caregiver management section, Data export (PDF/CSV)
- [ ] 10-05: History & Compliance Revamp — Week selector strip, compliance donut chart with %, Export PDF button, day-grouped history logs with colored status dots (green=done, orange=snoozed, red=missed, grey=skipped), empty state ("No data yet" calendar+leaf)
- [ ] 10-06: Template Library + Detail — Standalone browsable screen (new route), search bar, category filter chips, 120pt cards with icon circles and tag pills, Template Detail bottom sheet, add 4 new packs (Hydration Booster, Heart Patient, Elderly Wellness, Eye Care), course tracker (Day X of Y) badge
- [ ] 10-07: Full-Screen Alert Revamp — Pulsing radial gradient background (2s breathing), 64px time hero, white content card with step indicator (Step 2 of 5), 88px DONE/SNOOZE buttons with spring bounce, caregiver escalation warning text, chain context info
- [ ] 10-08: Add Reminder Manual — Segmented Say It/Build It toggle (Build It tab), reminder type grid (Medicine/Meal/Activity/Call/Exercise/Custom), Fixed Time / Linked to Event toggle, notes textarea, daily repeat day-of-week pills, dose + unit fields
- [ ] 10-09: Onboarding Merged Flow — 9-step PageView with dot indicators: Welcome Splash → Profile Type (Elderly/Adult/Parent) → Condition Select → Template Picker (filtered) → Anchor Setup → Medicine Entry → Accessibility Settings → Caregiver Link → Review + Celebration (confetti)

**Details:**
Reference designs: `.planning/design-reference/` (16 downloaded Stitch HTML files)
Comparison report: `.planning/design-reference/DESIGN_VS_CODE_COMPARISON.md`
Design tokens: See Section 4 of comparison report for all colors, typography, spacing, border radius, shadows, icons, animations, and gradients.
Rules: `.planning/PLANNING_RULES.md` (14 rules — must be read before planning/executing)
Key decisions:

- Follow design sizes exactly (no 18px minimum override for captions/tags)
- Merge onboarding: profile-based + condition-based combined into one flow
- Icon set: Switch from Material Icons to Material Symbols Outlined
- Font: Switch from Noto Sans (Google Fonts) to Inter
- Primary color: #1A3C5B navy (replacing #004D40 teal)
- Caregiver Portal screen explicitly excluded (per user instruction)
- 4 new template packs added (Hydration Booster, Heart Patient, Elderly Wellness, Eye Care)
- Course tracker (Day X of Y) badge on relevant templates
- Empty state illustrations on schedule + history screens

### Phase 11: Kids Mode

**Goal:** Build the Kids Mode feature with independent purple theme, gamified dashboard, reward celebrations with mascot + confetti.
**Depends on:** Phase 10
**Requirements:** KIDS-01 through KIDS-05

> **SCOPE CHANGE (March 2026):** Ramadan/Fasting Mode (plans 11-03, 11-04) has been **permanently removed** per the PlayStore Readiness Plan. All Ramadan code must be deleted in Pre-Work. Only Kids Mode (11-01, 11-02) remains.

**Success Criteria** (what must be TRUE):

1. Kids Mode Dashboard: Purple theme override, morning quest progress bar, daily checklist with animated task cards, points display, mascot robot widget, star rating, parent view toggle
2. Kids Mode Reward (Mascot variant): Confetti animation (50 falling circles), gold star SVG with bounce animation, waving mascot robot SVG, "Amazing!" celebration text, 50 bonus points display, "Back to Dashboard" button
3. Kids Mode Reward (Sound variant): Same celebration without mascot, cheerful fanfare audio playback
4. Kids Bottom Nav: Custom nav bar (Quest/Prizes/Me), purple/10 border, rocket/events/face icons
5. Parent View toggle requires PIN gate for switching between kids/parent views

**Plans:** 2 plans

**Wave Structure:**

- **Wave 1:** 11-01 (Kids Theme + Dashboard)
- **Wave 2:** 11-02 (Kids Rewards) depends on 11-01

Plans:

- [ ] 11-01: Kids Mode Theme + Dashboard — Purple theme override (#7C3AED), Kids bottom nav (Quest/Prizes/Me), morning quest progress bar, daily checklist with animated task cards, points display, mascot robot widget, star rating, parent view toggle (PIN protected), kids-specific route shell
- [ ] 11-02: Kids Rewards + Animations — Reward screen (mascot variant): confetti animation (50 falling circles), gold star SVG bounce, waving mascot robot SVG, "Amazing!" celebration text, 50 bonus points display, "Back to Dashboard" button; Reward screen (sound variant): cheerful fanfare audio playback, same celebration without mascot
- ~~11-03: Ramadan Theme + Screen~~ — **REMOVED** per PlayStore Readiness Plan
- ~~11-04: Fasting Logic + Scheduling~~ — **REMOVED** per PlayStore Readiness Plan

**Details:**
Reference designs: `kids-mode-dashboard.html`, `kids-mode-reward-mascot.html`, `kids-mode-reward-sound.html`
Kids Mode palette: #7C3AED (purple), #FBBF24 (yellow), #22C55E (green), #FB7185 (coral), #F87171 (red), bg #FDFCFE
Animations: confetti-fall, star-pop, shimmer-effect, waving, bobbing
Key decisions:

- Parent View toggle requires PIN gate for switching between kids/parent views
- Kids quest data should be persisted to SharedPreferences or SQLite

### Phase 12: Visual Chain Builder

**Goal:** Build the Visual Chain Builder (canvas-based node editor with drag-and-drop, mini-map, zoom controls, timeline simulation).
**Depends on:** Phase 11
**Requirements:** CHAIN-UI-01 through CHAIN-UI-05

> **SCOPE CHANGE (March 2026):** Voice Mode / NLP (plans 12-03, 12-04) has been **permanently removed** per the PlayStore Readiness Plan. Say It tab is locked as "Coming Soon" with no functional voice input. Only Chain Builder (12-01, 12-02) remains.

**Success Criteria** (what must be TRUE):

1. Visual Chain Builder canvas: Dot-grid background (24px spacing), scrollable/pannable
2. Anchor Node: Gold #F0A500 pill shape with schedule icon, editable time, white border
3. Chain Nodes: 320px wide cards with colored left strips (blue=medication, green=meal, grey=activity), offset badges, connector labels ("After Done"/"Always")
4. Dashed connectors for "regardless of completion" relationships
5. Add Step button: Dashed border, accent-blue bg, add_circle icon
6. Mini-Map: 128×160px fixed bottom-right, simplified node preview
7. Zoom Controls: 3 circular buttons (zoom in, zoom out, center focus)
8. Timeline Simulation Sheet: Bottom sheet with timeline items, colored dots, pause button
9. "Save Chain" + "Test Run" header actions

**Plans:** 2 plans

**Wave Structure:**

- **Wave 1:** 12-01 (Chain Builder Canvas + Nodes)
- **Wave 2:** 12-02 (Drag-and-Drop + Connectors) depends on 12-01

Plans:

- [ ] 12-01: Chain Builder Canvas + Nodes — Dot-grid background (24px spacing), scrollable/pannable CustomPainter canvas, anchor node (gold #F0A500 pill with schedule icon, editable time, white border), chain nodes (320px wide cards with colored left strips: blue=medication, green=meal, grey=activity), offset badges, connector labels ("After Done"/"Always"), dashed connectors for "regardless" relationships, add step button (dashed border, accent-blue, add_circle icon)
- [ ] 12-02: Drag-and-Drop + Connectors — GestureDetector drag-and-drop for nodes on canvas, snap-to-grid, mini-map (128×160px fixed bottom-right, simplified node preview), zoom controls (3 circular buttons: zoom in/out/center), timeline simulation bottom sheet (timeline items, colored dots, pause button), "Save Chain" + "Test Run" header actions
- ~~12-03: Voice Mode Speech-to-Text~~ — **REMOVED** per PlayStore Readiness Plan (Say It = Coming Soon)
- ~~12-04: NLP Parsing + Chain Preview~~ — **REMOVED** per PlayStore Readiness Plan

**Details:**
Reference designs: `visual-chain-builder.html`
Chain Builder colors: #F0A500 (anchor gold), #4A90D9 (accent blue), standard blue/green/slate for node types
Canvas: CustomPainter approach (not WebView or external library)

## Progress

| Phase                                    | Plans Complete | Status      | Completed  |
| ---------------------------------------- | -------------- | ----------- | ---------- |
| 01. Project Foundation                   | 3/3            | Done        | 2026-03-07 |
| 02. Data Layer + Models                  | 4/4            | Done        | 2026-03-07 |
| 03. Notification Engine + Alarms         | 8/8            | Done        | 2026-03-07 |
| 04. Chain Engine + Confirmation          | 5/5            | Done        | 2026-03-07 |
| 05. Anchor Resolution + Meal Timing      | 3/3            | Done        | 2026-03-07 |
| 06. Templates + Onboarding               | 7/7            | Done        | 2026-03-07 |
| 07. Daily View + History + Settings      | 5/5            | Done        | 2026-03-07 |
| 08. Accessibility + TTS                  | 4/4            | Done        | 2026-03-08 |
| 09. Integration Testing + OEM Validation | 5/5            | Done\*      | 2026-03-08 |
| 10. Design System + Core UI Revamp       | 9/9            | Done        | 2026-03-14 |
| 11. Kids Mode                            | 0/2            | Not started | —          |
| 12. Visual Chain Builder                 | 0/2            | Not started | —          |
| Pre-Work: Scope Cleanup                  | 0/1            | Not started | —          |
| PlayStore Phase 1: Plugin Verification   | 0/1            | Not started | —          |
| PlayStore Phase 2: Android Config        | 0/1            | Not started | —          |
| PlayStore Phase 3: UI Audit              | 0/1            | Not started | —          |
| PlayStore Phase 4: E2E Testing           | 0/1            | Not started | —          |
| PlayStore Phase 5: Release Prep          | 0/1            | Not started | —          |

\* Phase 09 Plan 09-05 (OEM Manual Testing) has checkpoint:human-verify — requires physical device test execution.

**Scope changes (March 28, 2026):**
- Phase 11: Plans 11-03 (Ramadan) and 11-04 (Fasting Logic) **REMOVED** — per PlayStore Readiness Plan
- Phase 12: Plans 12-03 (Voice STT) and 12-04 (NLP Parsing) **REMOVED** — Say It locked as Coming Soon
- Pre-Work + PlayStore Phases 1-5 added from `docs/MemoCare_PlayStore_Readiness_Plan.md`
