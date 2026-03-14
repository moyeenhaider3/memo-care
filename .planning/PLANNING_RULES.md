# PLANNING RULES — MemoCare UI Revamp

> These rules MUST be followed during planning and execution of Phases 10-12.
> Any AI agent working on this project must read this file first.

---

## Rule 1: Every Screen Must Have a Design Source

Every screen in the app MUST be backed by either:

- **A Stitch design HTML** (in `.planning/design-reference/*.html`) — PRIMARY source for visual specs
- **The MemoCare_UI_UX_Prompts.docx** (in `docs/`) — SECONDARY source for screens not in Stitch

If a screen appears in BOTH, the Stitch design takes priority for visual specs, and the docx fills in any missing interaction/behavior details.

### Screen-to-Source Mapping

| Screen                    | Stitch Design                  | Docx Section         | Notes                                                          |
| ------------------------- | ------------------------------ | -------------------- | -------------------------------------------------------------- |
| Home Dashboard            | `home-dashboard.html`          | P2                   | Merge both                                                     |
| Today's Full Schedule     | `todays-full-schedule.html`    | P5                   | Merge both                                                     |
| Full-Screen Alert         | `full-screen-alert.html`       | P3                   | Merge both                                                     |
| Add Reminder (Manual)     | `add-reminder-manual.html`     | P4 (Build It tab)    | Merge both                                                     |
| Add Reminder (Voice)      | `add-reminder-voice.html`      | P4 (Say It tab)      | Merge both                                                     |
| Template Library          | `template-library.html`        | P6                   | Merge both                                                     |
| Template Detail Sheet     | `template-detail-sheet.html`   | P6 (detail section)  | Merge both                                                     |
| Onboarding Flow           | `onboarding-flow.html`         | P1                   | Merge both + existing condition/template/anchor/medicine steps |
| Settings & Profile        | `settings-profile.html`        | P10                  | Merge both                                                     |
| History & Compliance      | `history-compliance.html`      | P8                   | Merge both                                                     |
| Ramadan / Fasting Mode    | `ramadan-fasting.html`         | P7                   | Merge both                                                     |
| Visual Chain Builder      | `visual-chain-builder.html`    | P11                  | Merge both                                                     |
| Kids Mode Dashboard       | `kids-mode-dashboard.html`     | P12                  | Merge both                                                     |
| Kids Mode Reward (Mascot) | `kids-mode-reward-mascot.html` | P12 (reward section) | Stitch primary                                                 |
| Kids Mode Reward (Sound)  | `kids-mode-reward-sound.html`  | P12 (reward section) | Stitch primary                                                 |
| Caregiver Portal          | `(skipped)`                    | P9                   | **EXCLUDED** — user said ignore                                |
| Generated Screen          | `generated-screen.html`        | —                    | Reward variant                                                 |

---

## Rule 2: Design Token System — Use These Exact Values

All screens MUST use the global design tokens from the Stitch designs:

### Colors (from Stitch HTML analysis)

```
Primary:        #1A3C5B (Deep Navy) — headers, primary CTAs, icons
   (docx says #1A3A5C — use Stitch value #1A3C5B)
Accent:         #4A90D9 (Sky Blue) — active states, links, progress
Success:        #22C55E (Calm Green) — done states (Stitch)
   Alt success:  #27AE60 (docx value for alert screen)
Warning:        #F39C12 / #F59E0B (Amber) — snoozed, pending
Danger:         #EF4444 (Soft Red) — missed, escalation (Stitch)
   Alt danger:   #E74C3C (docx value)
Background:     #F7F9FC (Off-White)
Card BG:        #FFFFFF
Skipped Grey:   #94A3B8
Accent Gold:    #D4AF37 / #F0A500 (fasting/Ramadan)
Accent Teal:    #0D9488 (caregiver actions)
```

### Kids Mode Palette (independent)

```
Primary Purple: #7C3AED
Warm Yellow:    #FBBF24
Playful Green:  #22C55E / #10B981
Coral Pink:     #FB7185 / #F87171
Background:     #FDFCFE
```

### Ramadan Palette (independent)

```
Primary Gold:   #F0A500
Background:     #0D1B2A
Card BG:        #1A2E44
Sehri Blue:     #4A90E2
Iftar Gold:     #F0A500
```

### Typography

```
Font:           Inter (not Noto Sans, not SF Pro)
H1:             28pt Bold
H2:             22pt SemiBold
Body:           17pt Regular
Caption:        14pt (follow design sizes exactly — no 18px minimum override)
Alarm time:     64px extrabold
Hero medicine:  32px extrabold
```

### Component Sizes

```
Cards:          16px border radius
Buttons:        14px border radius
Chips/Tags:     999px (pill shape)
Input fields:   12px border radius
Button height:  56px standard, 88px alert, 64px kids
Touch targets:  44x44pt minimum (WCAG AA)
Bottom nav:     5-tab fixed (Home | Schedule | Add | History | Profile)
FAB:            56-64px circular, primary/accent fill
```

---

## Rule 3: Follow Design Sizes Exactly

Per user decision: **Do NOT override caption/tag sizes to 18px.**
Use the exact sizes from the Stitch designs (11px-14px for captions/tags/labels).
The previous 18px minimum enforcement (from Phase 08 accessibility pass) is superseded for this revamp.

---

## Rule 4: Onboarding Is a Merged Flow

The onboarding must combine BOTH the existing condition-based flow AND the new profile-based design:

**Combined flow (9 steps):**

1. **Welcome Splash** — gradient hero, "Never miss what matters", "Get Started" (NEW from design)
2. **Profile Type** — Elderly / Adult / Parent cards (NEW from design)
3. **Condition Selection** — Diabetes / BP / School / Other (EXISTING)
4. **Template Picker** — condition-filtered template list (EXISTING, revamped)
5. **Anchor Setup** — meal time configuration (EXISTING, revamped)
6. **Medicine Entry** — add/edit medicines (EXISTING, revamped)
7. **Accessibility Settings** — Large Text + High Contrast toggles (NEW from design)
8. **Caregiver Link** — phone number + SMS invite (NEW from design)
9. **Review + Celebration** — summary card + confetti (EXISTING review + NEW celebration)

Navigation: PageView with dot indicators (not linear push navigation).

---

## Rule 5: Missing Features That Must Be Built

These features from the docx/blueprint are NOT in the current app and MUST be planned:

### Features Missing from Current App

| Feature                                           | Source                  | Phase |
| ------------------------------------------------- | ----------------------- | ----- |
| Bottom navigation (5-tab)                         | Stitch + Docx           | 10    |
| FAB for quick-add                                 | Stitch + Docx           | 10    |
| User avatar + greeting header                     | Stitch + Docx P2        | 10    |
| Progress ring (x/y done)                          | Stitch + Docx P2        | 10    |
| Timeline visualization (dotted line)              | Stitch + Docx P2/P5     | 10    |
| Today's Full Schedule (dedicated screen)          | Stitch + Docx P5        | 10    |
| Template Detail bottom sheet                      | Stitch + Docx P6        | 10    |
| Search bar in template library                    | Stitch + Docx P6        | 10    |
| Category filter chips (templates)                 | Stitch + Docx P6        | 10    |
| Standalone template browsing                      | Stitch + Docx P6        | 10    |
| Week selector strip (history)                     | Stitch + Docx P8        | 10    |
| Compliance donut chart                            | Stitch + Docx P8        | 10    |
| Export PDF button (history)                       | Stitch + Docx P8        | 10    |
| Day-grouped history logs                          | Stitch + Docx P8        | 10    |
| Profile section (settings)                        | Stitch + Docx P10       | 10    |
| Display settings (Text Size, Contrast, Dark Mode) | Stitch + Docx P10       | 10    |
| Fasting mode toggle (settings)                    | Stitch + Docx P10       | 10    |
| Caregiver management (settings)                   | Stitch + Docx P10       | 10    |
| Data export (PDF/CSV)                             | Stitch + Docx P10       | 10    |
| Add Reminder Manual (full form)                   | Stitch + Docx P4        | 10    |
| SNOOZE button on alert                            | Stitch + Docx P3        | 10    |
| Step indicator on alert                           | Stitch + Docx P3        | 10    |
| Caregiver warning text on alert                   | Stitch + Docx P3        | 10    |
| Welcome splash onboarding                         | Stitch + Docx P1        | 10    |
| Profile type selector onboarding                  | Stitch + Docx P1        | 10    |
| Accessibility step onboarding                     | Stitch + Docx P1        | 10    |
| Caregiver link onboarding                         | Stitch + Docx P1        | 10    |
| Celebration screen onboarding                     | Stitch + Docx P1        | 10    |
| Kids Mode Dashboard                               | Stitch + Docx P12       | 11    |
| Kids Mode Rewards (Mascot + Sound)                | Stitch + Docx P12       | 11    |
| Kids Bottom Nav (custom)                          | Stitch + Docx P12       | 11    |
| Parent View toggle (PIN protected)                | Docx P12                | 11    |
| Ramadan/Fasting Mode screen                       | Stitch + Docx P7        | 11    |
| Sehri/Iftar twin countdown cards                  | Stitch + Docx P7        | 11    |
| Fasting progress bar                              | Stitch + Docx P7        | 11    |
| Prayer time auto-calculation (location)           | Docx P7                 | 11    |
| Fasting day suspend (daytime reminders)           | Docx P7                 | 11    |
| Visual Chain Builder canvas                       | Stitch + Docx P11       | 12    |
| Node drag-and-drop                                | Stitch + Docx P11       | 12    |
| Mini-map                                          | Stitch + Docx P11       | 12    |
| Zoom controls                                     | Stitch + Docx P11       | 12    |
| Timeline simulation (Test Run)                    | Stitch + Docx P11       | 12    |
| Voice Mode (speech-to-text)                       | Stitch + Docx P4        | 12    |
| NLP parsing for reminders                         | Docx P4 + Blueprint 4.1 | 12    |
| Waveform visualizer                               | Stitch                  | 12    |
| Parsed chain preview                              | Stitch + Docx P4        | 12    |
| Hydration reminder + daily counter                | Blueprint 3.2           | 11\*  |
| Course tracker (Day X of Y)                       | Blueprint 3.1           | 10\*  |
| Empty state illustrations                         | Docx P5                 | 10    |

\*Will be discussed — may defer to Phase 11 or v1.x if scope too large.

---

## Rule 6: Phase Parallelism

Phases can run in parallel IF they don't share code dependencies:

### Dependency Graph

```
Phase 10: Design System + Core UI Revamp
    ├── 10-A: Design System Foundation (theme, colors, fonts, icons, bottom nav, FAB)
    │         → ALL other subplans depend on this
    ├── 10-B: Home Dashboard revamp        (depends on 10-A)
    ├── 10-C: Today's Full Schedule        (depends on 10-A)
    ├── 10-D: Settings & Profile revamp    (depends on 10-A)
    ├── 10-E: History & Compliance revamp  (depends on 10-A)
    ├── 10-F: Template Library + Detail    (depends on 10-A)
    ├── 10-G: Full-Screen Alert revamp     (depends on 10-A)
    ├── 10-H: Add Reminder (Manual)        (depends on 10-A)
    └── 10-I: Onboarding (merged flow)     (depends on 10-A + 10-D + 10-F)

Phase 11: Kids Mode + Ramadan/Fasting
    ├── 11-A: Kids Mode theme + dashboard  (depends on 10-A)
    ├── 11-B: Kids Rewards + animations    (depends on 11-A)
    ├── 11-C: Ramadan theme + screen       (depends on 10-A)
    └── 11-D: Fasting mode logic + scheduling (depends on 11-C + existing anchor system)

Phase 12: Visual Chain Builder + Voice Mode
    ├── 12-A: Chain Builder canvas + nodes  (depends on 10-A)
    ├── 12-B: Drag-and-drop + connectors    (depends on 12-A)
    ├── 12-C: Voice Mode speech-to-text     (depends on 10-H)
    └── 12-D: NLP parsing + chain preview   (depends on 12-C)
```

### Parallel Execution Rules

- **10-B through 10-H** can all run in parallel after 10-A is done
- **10-I (onboarding)** must run LAST within Phase 10 (depends on settings + templates being revamped)
- **11-A and 11-C** can run in parallel (kids and ramadan don't share code)
- **11-B depends on 11-A**, **11-D depends on 11-C**
- **12-A and 12-C** can run in parallel (chain builder and voice mode don't share code)
- **12-B depends on 12-A**, **12-D depends on 12-C**
- **Phase 11 and Phase 12** can run in parallel with each other (after Phase 10-A is done)

---

## Rule 7: Docx Behavioral Specs Fill Stitch Gaps

The Stitch designs are STATIC visual mockups. The docx contains BEHAVIORAL specs:

| Behavior                               | Source          | Screen                     |
| -------------------------------------- | --------------- | -------------------------- |
| Pulsing glow animation (2s breathing)  | Docx P3         | Full-Screen Alert          |
| Spring micro-bounce on button tap      | Docx Global     | All buttons                |
| Chain fire slide-in animation          | Docx Global     | Chain transitions          |
| Alert escalation pulse ring animation  | Docx Global     | Alert screen               |
| Transitions max 300ms ease-in-out      | Docx Global     | All transitions            |
| Confirmation tap spring bounce         | Docx Global     | DONE/SNOOZE buttons        |
| Voice input waveform animation         | Docx P4         | Add Reminder Voice         |
| Elderly mode +4pt text + 64pt targets  | Docx Global/P10 | All screens (when toggled) |
| Smart Pattern Detection (auto-suggest) | Blueprint 4.4   | Future — defer             |
| Auto-call escalation (Layer 5)         | Blueprint 5.1   | Future — defer             |
| One-tap phone dial from notification   | Blueprint 3.5   | Future — defer             |
| Photo log for wound dressing           | Blueprint 3.4   | Future — defer             |

---

## Rule 8: Caregiver Portal Is EXCLUDED

The user explicitly said "Ignore caregiver screen for now." Do NOT plan or build:

- Caregiver Portal / Family Portal (P9 in docx)
- `caregiver-portal.html` from Stitch (screen c0245c8f)
- Remote reminder editing from caregiver side
- End-of-day report generation for caregivers

Caregiver-related SETTINGS (link caregiver, send SMS alerts) ARE included because they're part of Settings & Profile.

---

## Rule 9: 8 Template Packs from Docx

The docx (P6) specifies 8 template packs. Current app has 3. Add the missing 5:

| Template               | Current    | Add?                                 |
| ---------------------- | ---------- | ------------------------------------ |
| Diabetic Daily Pack    | ✅ Exists  | Revamp card design                   |
| Blood Pressure Pack    | ✅ Exists  | Revamp card design                   |
| School Morning Routine | ✅ Exists  | Revamp card design                   |
| Ramadan Medicine Pack  | ❌ Missing | Add in Phase 11 (needs fasting mode) |
| Hydration Booster      | ❌ Missing | Add in Phase 10                      |
| Heart Patient Pack     | ❌ Missing | Add in Phase 10                      |
| Elderly Wellness Daily | ❌ Missing | Add in Phase 10                      |
| Eye Care Routine       | ❌ Missing | Add in Phase 10                      |

---

## Rule 10: Icon System Migration

Switch from `Icons.xxx` (Material Icons) to Material Symbols Outlined.
Package: `material_symbols_icons` (pub.dev) or continue using `Icons.xxx` with outlined variants where available.
Decision: Use Flutter's built-in `Icons.xxx_outlined` variants first. Only add `material_symbols_icons` package if specific icons are missing.

---

## Rule 11: Font System Migration

Switch from `GoogleFonts.notoSansTextTheme()` to `GoogleFonts.interTextTheme()`.
Both are available in the `google_fonts` package (already a dependency).

---

## Rule 12: Test Continuity

After each phase plan execution:

1. Existing 67 unit tests must still pass
2. New screens must have at minimum widget tests for rendering
3. Integration tests (Patrol) from Phase 09 must be updated if routes change

---

## Rule 13: Empty State Designs

From docx P5: "Soft illustration of a tea cup with steam and text 'Rest of the day is free'"
From docx P8: "Soft illustration of a calendar page with leaf. Text: 'No data yet for this week.'"

Every screen with a list MUST have an empty state per docx specs.

---

## Rule 14: Ramadan Mode Impact on Existing Screens

When Ramadan/Fasting Mode is active (toggle in Settings):

- Today's Full Schedule: Add Sehri/Iftar divider lines (gold #F0A500 horizontal rules)
- Home Dashboard: Show fasting-aware hero card
- Templates: Include Ramadan Medicine Pack
- Daytime meal-linked reminders: Auto-suppress during fast hours

---

## Quick Reference: Phase → Screen Mapping

| Phase | Screens to Build/Revamp                                |
| ----- | ------------------------------------------------------ |
| 10-A  | Theme, BottomNav, FAB (no screen — design system only) |
| 10-B  | Home Dashboard                                         |
| 10-C  | Today's Full Schedule (NEW)                            |
| 10-D  | Settings & Profile                                     |
| 10-E  | History & Compliance                                   |
| 10-F  | Template Library + Detail Sheet (NEW)                  |
| 10-G  | Full-Screen Alert                                      |
| 10-H  | Add Reminder Manual (NEW, was TODO stub)               |
| 10-I  | Onboarding (merged 9-step flow)                        |
| 11-A  | Kids Mode Dashboard (NEW)                              |
| 11-B  | Kids Rewards — Mascot + Sound (NEW)                    |
| 11-C  | Ramadan/Fasting Mode (NEW)                             |
| 11-D  | Fasting scheduling logic                               |
| 12-A  | Chain Builder canvas (NEW)                             |
| 12-B  | Drag-and-drop + connectors                             |
| 12-C  | Voice Mode speech-to-text (NEW)                        |
| 12-D  | NLP parsing + chain preview                            |
