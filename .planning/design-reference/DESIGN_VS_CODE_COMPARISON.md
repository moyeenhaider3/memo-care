# MemoCare: Design HTML vs Current Flutter Code — Comprehensive Comparison Report

> Generated 8 March 2026. Covers all 16 Stitch design HTML files and current Flutter presentation-layer code.

---

## Table of Contents

1. [Global Design System Differences](#1-global-design-system-differences)
2. [Screen-by-Screen Comparison](#2-screen-by-screen-comparison)
   - [2.1 Home Dashboard](#21-home-dashboard)
   - [2.2 Today's Full Schedule](#22-todays-full-schedule)
   - [2.3 Onboarding Flow](#23-onboarding-flow)
   - [2.4 Settings & Profile](#24-settings--profile)
   - [2.5 Template Library](#25-template-library)
   - [2.6 Template Detail Sheet](#26-template-detail-sheet)
   - [2.7 History & Compliance](#27-history--compliance)
   - [2.8 Full-Screen Alert](#28-full-screen-alert)
   - [2.9 Add Reminder (Manual)](#29-add-reminder-manual)
   - [2.10 Add Reminder (Voice) — NEW](#210-add-reminder-voice--new)
   - [2.11 Visual Chain Builder — NEW](#211-visual-chain-builder--new)
   - [2.12 Kids Mode Dashboard — NEW](#212-kids-mode-dashboard--new)
   - [2.13 Kids Mode Reward (Mascot) — NEW](#213-kids-mode-reward-mascot--new)
   - [2.14 Kids Mode Reward (Sound) — NEW](#214-kids-mode-reward-sound--new)
   - [2.15 Ramadan / Fasting Mode — NEW](#215-ramadan--fasting-mode--new)
   - [2.16 Generated Screen — NEW](#216-generated-screen--new)
3. [Complete New Screens Summary](#3-complete-new-screens-summary)
4. [Full Design Token Reference](#4-full-design-token-reference)

---

## 1. Global Design System Differences

### Font Family

| Aspect       | NEW DESIGN                                | CURRENT APP                       |
| ------------ | ----------------------------------------- | --------------------------------- |
| Primary font | **Inter** (sans-serif)                    | **Noto Sans** (via Google Fonts)  |
| Usage        | `font-family: "Inter"` across all screens | `GoogleFonts.notoSansTextTheme()` |

### Color Palette

| Token              | NEW DESIGN (hex)           | CURRENT APP (hex)                        | Notes                          |
| ------------------ | -------------------------- | ---------------------------------------- | ------------------------------ |
| Primary            | `#1A3C5B` (dark navy)      | `Colors.teal` seed → `#004D40` deep teal | **Major change**: navy vs teal |
| Background Light   | `#F6F7F8` / `#F7F9FC`      | Material 3 default surface               | Design specifies exact bg      |
| Background Dark    | `#13191F`                  | Material 3 default dark surface          | Design specifies exact bg      |
| Accent Blue        | `#4A90D9`                  | None                                     | **New** accent color           |
| Success/Done Green | `#22C55E` / `#27AE60`      | `#1B5E20` (dark green AAA)               | Design uses brighter green     |
| Missed Red         | `#EF4444`                  | `#B71C1C` (dark red AAA)                 | Design uses brighter red       |
| Warning Amber      | `#F59E0B` / `#F39C12`      | `#E65100` (deep orange AAA)              | Design uses standard amber     |
| Pending Orange     | `#F59E0B`                  | `#E65100`                                |                                |
| Skipped Grey       | `#94A3B8`                  | `#424242`                                | Lighter in design              |
| Accent Gold        | `#D4AF37` / `#F0A500`      | None                                     | **New** fasting/Ramadan accent |
| Accent Teal        | `#0D9488`                  | None                                     | **New** for caregiver actions  |
| Kids Primary       | `#7C3AED` (vibrant purple) | None                                     | **New** entire kids palette    |
| Kids Green         | `#22C55E`                  | None                                     |                                |
| Kids Yellow        | `#FBBF24`                  | None                                     |                                |
| Kids Coral         | `#FB7185` / `#F87171`      | None                                     |                                |
| Kids Brand Green   | `#10B981`                  | None                                     |                                |
| Sehri Blue         | `#4A90E2`                  | None                                     | **New** Ramadan palette        |
| Iftar Gold         | `#F0A500`                  | None                                     | **New** Ramadan palette        |
| Card BG (Ramadan)  | `#1A2E44`                  | None                                     | **New** dark card              |
| Ramadan BG         | `#0D1B2A`                  | None                                     | **New** deep navy bg           |

### Border Radius

| Token   | NEW DESIGN               | CURRENT APP                      |
| ------- | ------------------------ | -------------------------------- |
| Default | `8px` (0.5rem)           | `12px` (buttons), `16px` (cards) |
| Large   | `16px` (1rem)            | `16px`                           |
| XL      | `24px` (1.5rem)          | None                             |
| Full    | `9999px` (pills/circles) | `9999px` on chips                |
| Cards   | `12px` rounded-xl        | `16px` via CardTheme             |
| Buttons | `14px` / `12px`          | `12px`                           |

### Typography Scale

| Element         | NEW DESIGN                   | CURRENT APP                          |
| --------------- | ---------------------------- | ------------------------------------ |
| Hero heading    | `64px` (alarm time)          | `36px` max                           |
| Screen title    | `28pt` (headlineSmall equiv) | `28px` titleLarge                    |
| Section heading | `22pt`                       | `24px` titleMedium                   |
| Card title      | `18pt`                       | `20px` bodyLarge                     |
| Body text       | `17pt`                       | `20px` bodyLarge / `18px` bodyMedium |
| Small label     | `13pt`                       | `18px` minimum (A11Y)                |
| Caption / tag   | `11px` – `13px`              | `18px` minimum                       |
| Button text     | `20pt` – `28px`              | `20px`                               |

> **Key difference**: Design uses smaller caption/label text (11–13px) that may conflict with current app's 18px minimum for accessibility compliance.

### Icon System

| Aspect         | NEW DESIGN                                           | CURRENT APP                   |
| -------------- | ---------------------------------------------------- | ----------------------------- |
| Icon set       | **Material Symbols Outlined** (variable weight/fill) | **Material Icons** (standard) |
| Filled variant | `font-variation-settings: 'FILL' 1`                  | Not used                      |
| Sizes          | Variable: `text-sm` to `text-5xl`                    | Standard sizes                |

### Navigation

| Aspect           | NEW DESIGN                              | CURRENT APP                         |
| ---------------- | --------------------------------------- | ----------------------------------- |
| Bottom nav style | Fixed bottom bar, 4-5 items             | No bottom nav (GoRouter push-based) |
| Nav items        | Home, Schedule, Meds/Care, Profile      | Tab-less, route-based               |
| FAB              | Floating centered (+) button, `56-64px` | None                                |
| Back nav         | Arrow in header                         | Standard AppBar back                |

---

## 2. Screen-by-Screen Comparison

### 2.1 Home Dashboard

**Design file**: `home-dashboard.html`
**Current code**: `lib/features/daily_schedule/presentation/home_screen.dart` + widgets

#### NEW DESIGN Layout

- **Header**: Sticky white bar with:
  - User avatar (56px circle with image, primary/10 bg, 2px border)
  - Greeting: "Good Morning, Abdul" (24px bold)
  - Date subtitle: "Monday, Oct 24th" (slate-500)
  - Circular SVG progress ring (64px, showing 3/8 done)
- **Hero Card** ("Up Next"):
  - Full-width dark navy (`#1A3C5B`) rounded-xl card with:
  - Abstract circle decoration (top-right, white/5)
  - "UP NEXT" badge (white/20 bg, rounded-full, xs text, uppercase tracking-widest)
  - Notification bell icon (white/60)
  - Medicine name: 3xl (30px) bold white
  - Schedule icon + time: lg (18px) text
  - Two side-by-side buttons:
    - **DONE**: `#22C55E` bg, white text, bold, rounded-lg, with check_circle icon
    - **SNOOZE**: transparent bg, white/30 border, white text, with alarm_off icon
- **Timeline Section**:
  - "Today's Schedule" header with "View All" link
  - Vertical dotted line timeline (left-aligned, dashed border)
  - Each item: circle indicator (40px) + card
    - Done: green circle with check, grey strike-through title, "DONE" badge (green-50 bg)
    - Missed: red circle with X, red left border (4px), "TAKE NOW" button (primary bg)
    - Upcoming: grey circle with hourglass, "UPCOMING" badge (slate-100 bg)
- **FAB**: Centered floating `+` button (64px, primary bg, shadow-2xl)
- **Bottom Nav**: 5 items (Home, Schedule, spacer for FAB, Meds, Profile)

#### CURRENT APP Layout

- Standard `AppBar` with "MemoCare" title, centered: false
- `NextPendingHeroCard`: Material Card with primaryContainer bg
  - "NEXT UP" label (labelLarge, primary color)
  - Medicine name with pill emoji prefix (headlineSmall, ~24px)
  - Dosage + time text
  - Two horizontal buttons: "I Took It" (FilledButton, dark green) and "Skip" (OutlinedButton, red)
- Flat list of `ReminderListTile` rows with `StatusBadge` chips
  - Simple row: time | name + dosage | status badge
  - No timeline visualization, no dotted lines, no circle indicators
- `MissedRemindersSheet` modal bottom sheet for missed items
- No FAB, no bottom navigation bar, no user avatar, no progress ring

#### KEY DIFFERENCES

| Feature                  | Design                                | Current                                      |
| ------------------------ | ------------------------------------- | -------------------------------------------- |
| User avatar + greeting   | ✅ Personalized with photo            | ❌ Missing                                   |
| Progress ring (x/y done) | ✅ SVG circular progress              | ❌ Missing                                   |
| Hero card style          | Navy bg, gradient look, SNOOZE button | Material Card, primaryContainer, SKIP button |
| Timeline visualization   | ✅ Dotted line + circle indicators    | ❌ Flat list with dividers                   |
| Status indicators        | Colored circles + badges in timeline  | Simple StatusBadge chips                     |
| "TAKE NOW" for missed    | ✅ Inline button                      | ❌ Handled via MissedRemindersSheet          |
| FAB (+) button           | ✅ Centered, 64px                     | ❌ Missing                                   |
| Bottom navigation bar    | ✅ 5-item fixed bar                   | ❌ Missing                                   |
| "View All" schedule link | ✅ Present                            | ❌ Missing                                   |

---

### 2.2 Today's Full Schedule

**Design file**: `todays-full-schedule.html`
**Current code**: `lib/features/daily_schedule/presentation/home_screen.dart` (same screen, no separate full schedule)

#### NEW DESIGN Layout

- **Header**:
  - "Today" in 28pt bold primary color
  - Date badge: "8 Mar" in blue bg pill (`#EAF2FB`)
  - Summary chips row (scrollable): "5 Done" (green), "2 Upcoming" (blue), "1 Missed" (rose)
    - Each chip: 36pt height, rounded-full, colored bg, icon + count text
- **Timeline**:
  - Vertical solid line (2px, left side, `#E0E0E0`)
  - Time labels on left ("8 AM", "9 AM", etc.)
  - Cards with colored left border strip (2px wide):
    - Green strip = done, with green check_circle icon
    - Rose strip = missed, with rose cancel icon
    - Amber strip = upcoming pending, with amber schedule icon
    - Blue strip = upcoming, with blue schedule icon
  - Each card: 100px min-height, white bg, rounded-xl, shadow-sm, border
  - Card content: title (18pt semibold), time (14pt), italic instructions
  - **Chain group**: "Lunch Chain" label with link icon, grouped in blue bg (`#EAF2FB`) rounded container
    - Locked downstream items shown with lock icon and reduced opacity
- **FAB**: Primary bg, bottom-right, 64px
- **Bottom Nav**: 4 items (Schedule active, Meds, Care, Profile)

#### CURRENT APP

- No separate "full schedule" screen
- Home screen shows flat list without time-grouped timeline
- No summary chips, no chain grouping visualization

#### KEY DIFFERENCES

| Feature                       | Design                              | Current                             |
| ----------------------------- | ----------------------------------- | ----------------------------------- |
| Separate full schedule view   | ✅ Dedicated screen                 | ❌ Only home screen list            |
| Summary status chips          | ✅ Done/Upcoming/Missed count chips | ❌ Missing                          |
| Timeline with time labels     | ✅ Hourly timeline layout           | ❌ Flat list                        |
| Color-coded left border strip | ✅ Per-status colored strip         | ❌ Missing                          |
| Chain grouping UI             | ✅ Blue bg container, lock icons    | ❌ Chain context is separate screen |
| Italic instruction text       | ✅ Per-reminder notes               | ❌ Not shown in list                |
| "View All" → this screen      | ✅ Navigated from home              | ❌ No navigation                    |

---

### 2.3 Onboarding Flow

**Design file**: `onboarding-flow.html`
**Current code**: `lib/features/onboarding/presentation/` (6 step files + flow shell)

#### NEW DESIGN (5 slides, horizontal swipe)

1. **Welcome Slide**:
   - Full gradient background: `linear-gradient(180°, #1A3C5B → #7DB9E8)`
   - "MemoCare" centered header (lg bold white)
   - Large circle (256px, white/10, backdrop-blur, white/20 border) with schedule icon (120px)
   - "Never miss what matters" (4xl / 36px bold)
   - Subtitle: "The simple way to manage medications and appointments" (lg, white/80)
   - "Get Started" button (white bg, primary text, rounded-xl, h-14, bold)
   - Page dots: 5 dots, active = wide pill (w-8, h-2), inactive = circle (w-2, h-2)

2. **Profile Selection** (Step 1 of 4):
   - 3 profile cards: Elderly, Adult, Parent
   - Each: p-5, white bg, rounded-xl, border, icon in circle (48px)
   - Selected card: `border-2 border-primary`, check_circle icon
   - "Continue" button (primary bg, h-14, rounded-xl)

3. **Accessibility** (Step 2 of 4):
   - Toggle rows in white card (rounded-xl):
     - Large Text: toggle ON (primary bg)
     - High Contrast: toggle OFF (slate-200 bg)
   - Preview text in primary/5 bg area
   - "Apply Settings" button

4. **Caregiver Link** (Step 3 of 4):
   - Centered icon (volunteer_activism, 80px, primary/10 circle)
   - Phone number text field with call icon
   - "Send Invitation" + "Maybe Later" buttons

5. **Celebration** (Success):
   - Green check circle (128px, green-100 bg) with celebration icon overlay
   - "All set!" (4xl bold)
   - Setup summary card (white bg, rounded-2xl): Profile, Accessibility, Caregiver status
   - "Go to Dashboard" button

#### CURRENT APP (6 steps, linear progress)

1. **Condition Step**: "What do you need help with?" — 4 condition cards (Diabetes, BP, School Morning, Other)
2. **Template Step**: Template pack picker with condition filtering
3. **Anchor Step**: Meal time configuration (Breakfast, Lunch, Dinner pickers)
4. **Medicine Step**: Medicine entry manual form
5. **Review Step**: Summary before saving
6. **Permission Step**: OS permission requests (Notifications, Exact Alarm, Battery)

Shell: `OnboardingFlow` — `Scaffold` with `AppBar`, linear `LinearProgressIndicator`, step counter text

#### KEY DIFFERENCES

| Feature                                  | Design                                | Current                                        |
| ---------------------------------------- | ------------------------------------- | ---------------------------------------------- |
| Navigation model                         | Horizontal swipe PageView (5 slides)  | Linear step-by-step push navigation (6 steps)  |
| Welcome/splash slide                     | ✅ Gradient hero with icon            | ❌ Missing, jumps straight to condition        |
| Profile selection                        | ✅ Elderly/Adult/Parent picker        | ❌ Condition picker (Diabetes/BP/School/Other) |
| Accessibility settings                   | ✅ Large Text + High Contrast toggles | ❌ Not in onboarding (only in settings?)       |
| Caregiver link                           | ✅ Phone number input + SMS invite    | ❌ Missing entirely                            |
| Celebration screen                       | ✅ Green check + summary card         | ❌ Missing, goes straight to home              |
| Progress indicator                       | Dot indicators (5 dots)               | Linear progress bar + "Step X of Y"            |
| Steps count                              | 5 slides (Welcome + 4 steps)          | 6 steps (no welcome, no celebration)           |
| Page transition                          | Snap horizontal scroll                | Route-based page push                          |
| Condition/Template/Anchor/Medicine steps | ❌ Not in design                      | ✅ Current has detailed medical setup          |

> **Note**: The design's onboarding is focused on profile/accessibility/caregiver setup whereas the current app focuses on medical condition/template/medicine setup. These may need to be merged.

---

### 2.4 Settings & Profile

**Design file**: `settings-profile.html`
**Current code**: `lib/features/settings/presentation/settings_screen.dart`

#### NEW DESIGN Layout

- **Header**: Back arrow + "Settings & Profile" title + more_horiz menu
- **Profile Section**:
  - Avatar: 80px circle with initials "AR" (primary bg, white text, 32px bold)
  - Name: "Abdul Rahman" (22px bold)
  - "Elderly Mode Active" badge (success/10 bg, success text, rounded-full, border)
  - "Edit Profile" outlined button (rounded-full)
- **Settings Groups** (iOS-style grouped list):
  1. **Display**: Text Size (→ "Large"), High Contrast (toggle), Dark Mode (toggle)
     - Each row: 56px height, icon in 40px rounded-lg bg (primary/10), 17px text
  2. **Notifications**: Alert Volume (slider), Snooze Duration (→ "10 min"), Escalation Delay (→ "20 min"), Caregiver SMS Alerts (toggle + phone number)
  3. **Fasting Mode**: Ramadan/Fasting Mode toggle (gold accent icon)
  4. **My Caregivers**: Caregiver card (avatar, name, relationship, Remove button), Add Caregiver (teal accent)
  5. **Data**: Export My Data (PDF/CSV), Backup to Cloud (toggle), Delete All Reminders (danger red)
- **Bottom Nav**: 4 items (Home, Schedule, Care, Settings active)

#### CURRENT APP Layout

- Simple `AppBar` with "Settings" title
- Two sections only:
  1. **Notification Preferences**: Notifications toggle, Sound toggle, Vibration toggle (SwitchListTile)
  2. **Snooze & Escalation**: Snooze Duration slider, Silent→Audible Timeout slider, Audible→Full-Screen Timeout slider
- "MemoCare v1.0" footer text
- No profile section, no avatar, no display settings, no fasting mode, no caregiver management, no data export

#### KEY DIFFERENCES

| Feature                                                | Design                             | Current                                    |
| ------------------------------------------------------ | ---------------------------------- | ------------------------------------------ |
| Profile section with avatar                            | ✅ Initials avatar + name + badge  | ❌ Missing                                 |
| Edit Profile button                                    | ✅                                 | ❌                                         |
| Elderly Mode badge                                     | ✅                                 | ❌                                         |
| Display settings (Text Size, High Contrast, Dark Mode) | ✅                                 | ❌                                         |
| Alert Volume slider                                    | ✅                                 | ❌ (has Sound toggle instead)              |
| Snooze Duration                                        | ✅ Picker (→ "10 min")             | ✅ Slider (1-15 min)                       |
| Escalation Delay                                       | ✅ Picker ("20 min")               | ✅ Two separate sliders (silent + audible) |
| Caregiver SMS Alerts                                   | ✅ Toggle + phone number           | ❌                                         |
| Fasting Mode toggle                                    | ✅ Gold accent                     | ❌                                         |
| Caregiver management                                   | ✅ List + Add/Remove               | ❌                                         |
| Data Export (PDF/CSV)                                  | ✅                                 | ❌                                         |
| Cloud Backup toggle                                    | ✅                                 | ❌                                         |
| Delete All Reminders                                   | ✅ Danger action                   | ❌                                         |
| Section style                                          | iOS grouped with bg headers        | Simple ListView with section headers       |
| Icon treatment                                         | 40px rounded-lg with primary/10 bg | No icons next to settings                  |
| Row height                                             | 56px consistent                    | Variable                                   |
| Bottom nav                                             | ✅                                 | ❌                                         |

---

### 2.5 Template Library

**Design file**: `template-library.html`
**Current code**: `lib/features/templates/presentation/template_picker_screen.dart`

#### NEW DESIGN Layout

- **Header**: Back arrow → "Quick Start Templates" (22pt bold primary), subtitle "Pick a pack and we'll build your chain"
- **Search Bar**: 48pt height, rounded-xl, `#F0F4F8` bg, search icon, placeholder text
- **Category Filter Chips**: Scrollable row — All (primary bg selected), Medical, Meals, Fasting, Kids, Fitness (grey bg unselected), h-10, rounded-full
- **Template Cards**: Vertical scrollable list, each card:
  - 120pt height, white bg, rounded-xl, shadow-sm, border
  - Icon circle (40pt, colored bg per category: blue/red/teal/purple/cyan)
  - Title (17pt semibold primary)
  - Description (13pt slate-500)
  - Tag pills: "3 medicines", "2 checks" (11px, grey bg, rounded-full)
  - Chevron right arrow (`#4A90D9`)
- **5 Template Cards**: Diabetic Daily Pack, Blood Pressure Pack, Ramadan Medicine Pack, School Morning Routine, Hydration Booster
- **Bottom Nav**: 4 items (Home, Templates active, History, Profile)

#### CURRENT APP Layout

- Shows during onboarding Step 2 only
- "Choose a template" (titleLarge) + description text
- Simple `ListView.builder` with `_TemplateCard`:
  - Material `Card` with `InkWell`
  - `Icons.playlist_add_check` icon (32px, primary)
  - Pack name (titleSmall), description (bodyMedium)
  - Medicine `Chip` wraps
  - "Select" `ElevatedButton`
- "Skip — I'll add medicines manually" `TextButton`
- Only shows filtered by condition, no search, no categories

#### KEY DIFFERENCES

| Feature                | Design                                       | Current                                     |
| ---------------------- | -------------------------------------------- | ------------------------------------------- |
| Access                 | Standalone browseable library                | Onboarding step only                        |
| Search bar             | ✅ Text search                               | ❌                                          |
| Category filter chips  | ✅ All/Medical/Meals/Fasting/Kids/Fitness    | ❌ Condition-filtered only                  |
| Card style             | 120pt tall, icon circles, tag pills, chevron | Simple card with chip wraps + Select button |
| Card count variety     | 5 diverse templates                          | Condition-dependent list                    |
| Ramadan/Kids templates | ✅                                           | ❌                                          |
| Standalone nav         | ✅ Bottom nav entry                          | ❌ Onboarding-only                          |

---

### 2.6 Template Detail Sheet

**Design file**: `template-detail-sheet.html`
**Current code**: None (no detail sheet exists)

#### NEW DESIGN Layout

- **Background**: Dimmed template library (40% opacity, greyscale)
- **Bottom Sheet**: 80vh height, rounded-t-[24px], white bg, shadow-2xl
  - Drag handle: 1.5px × 48px, rounded-full, slate-200
  - Title: "Diabetic Daily Pack" (22pt bold primary)
  - Description: "Manage insulin and glucose checks around your main meals" (17pt, slate-600)
  - **Included Reminders list**: "INCLUDED REMINDERS" section label (sm bold uppercase tracking-wider)
    - Each item: slate-50 bg, rounded-xl, p-4, 3px gap
      - 48px circle icon (primary/10 bg, primary color icon)
      - Medicine name (17pt medium), subtitle (sm slate-500)
      - Time on right (17pt semibold primary) or chevron
    - 4 items: Fasting Glucose Check 7:00 AM, Morning Insulin, Lunch Insulin, Evening Glucose Check
  - **Info banner**: primary/5 bg, primary/10 border, rounded-xl, info icon + message text (15pt)
  - **Sticky footer**: white/80 backdrop-blur bg, border-t, "Use This Template" button (primary bg, lg bold, rounded-xl, py-4)

#### CURRENT APP

- No template detail sheet exists
- Template selection is direct tap → apply in onboarding

#### STATUS: **COMPLETELY NEW SCREEN**

---

### 2.7 History & Compliance

**Design file**: `history-compliance.html`
**Current code**: `lib/features/history/presentation/history_screen.dart` + widgets

#### NEW DESIGN Layout

- **Header**: Sticky, backdrop-blur bg
  - "History" (28px bold primary)
  - "Export PDF" button (outlined, secondary blue, rounded-full, with pdf icon)
  - Medicine filter chips: scrollable row (All active + Paracetamol, Dolo, Omega-3, Vitamin D)
- **Week Selector Strip**:
  - White card, rounded-xl, 7 day columns
  - Each day: name (xs), date number, colored dot (green/amber/red/grey)
  - Active day: primary bg circle with white number
- **Compliance Ring**:
  - Large donut chart (160×160px SVG)
  - Center: "87%" (22px bold) + "this week" label
  - Legend grid (2×2): Taken 24 (green), Late 3 (amber), Missed 2 (red), Skipped 1 (grey)
  - Color squares: `3×3px rounded-sm`
- **Daily Log Section**:
  - Day group headers: "Friday, 8 Mar" with horizontal rule
  - Log rows (h-12, rounded-lg, shadow-sm):
    - Status dot (2.5×2.5px colored circle)
    - Medicine name (sm bold), scheduled time (10px)
    - Status text + icon (colored, xs semibold)
    - Green check_circle/Red notifications_active icons (filled)
- **Bottom Nav**: 4 items (Home, History active, Meds, Profile)

#### CURRENT APP Layout

- `AppBar` with "Medication History"
- `MedicationFilterBar`: horizontal `FilterChip` list (All + per-medicine)
- `ListView.builder` with infinite scroll pagination
- `HistoryCard`: Material `Card`, simple row layout
  - Medicine name (bodyLarge bold), date + time + dosage text, "Confirmed at..." text
  - `_StatusChip` (colored bg + text)
- Pull-to-refresh + load-more indicator
- No week view, no compliance ring/chart, no export, no day grouping

#### KEY DIFFERENCES

| Feature                     | Design                             | Current                       |
| --------------------------- | ---------------------------------- | ----------------------------- |
| Week selector strip         | ✅ 7-day view with status dots     | ❌                            |
| Compliance ring/donut chart | ✅ SVG with % and legend           | ❌                            |
| Export PDF button           | ✅ Header action                   | ❌                            |
| Day-grouped logs            | ✅ Date headers with HR separator  | ❌ Flat list                  |
| Log row style               | Compact h-12 with status dots      | Taller Card with full details |
| Status indicators           | Colored dots + text + filled icons | Chip badges                   |
| Pagination                  | Not shown (daily view)             | ✅ Infinite scroll            |
| Time range view             | Weekly focus                       | All-time paginated            |
| "Late" status               | ✅ Amber for late-taken            | ❌ Not tracked separately     |

---

### 2.8 Full-Screen Alert

**Design file**: `full-screen-alert.html`
**Current code**: `lib/features/escalation/presentation/fullscreen_alarm_screen.dart`

#### NEW DESIGN Layout

- **Background**: Radial gradient pulsing glow (`#1A3C5B` → `#0D1E2E`)
  - Decorative blur circles (top-left, bottom-right, 40% size, white, blur-120px, 20% opacity)
- **Header**:
  - "REMINDER" badge (white/10 bg, backdrop-blur, rounded-full, white/20 border)
  - Time: **64px extrabold** white
  - Date: xl (20px) medium, slate-300
- **Content Card**: White bg, rounded-xl, p-8, shadow-2xl, centered
  - Teal circle icon (80px, teal-500 bg, medication icon 5xl white, shadow-lg)
  - Step indicator: 3 dots + "Step 1 of 3 today" text
  - Medicine name: **32px extrabold** slate-900
  - Instruction: lg (18px) slate-600
  - Warning banner: warning/10 bg, warning/20 border, rounded-lg
    - Warning icon + bold text: "Your lunch window closes in 8 minutes"
- **Action Buttons**:
  - "I've Done It": **88px height**, success green bg, rounded-xl, shadow-xl, 28px bold + check_circle 3xl
  - "Remind me in 10 min": **88px height**, transparent bg, white/40 border, 24px semibold + snooze 3xl
  - "Skip this reminder": text-only link, slate-300, lg
  - Escalation warning: "No response in 20 min will notify your caregiver" (xs, center, white/20 divider above)

#### CURRENT APP Layout

- Solid dark background (`#1A1A2E`)
- `SafeArea` + `CustomScrollView` centered layout
- Medication icon (80px, white)
- "Time to take your medicine" (20px white70)
- Medicine name: **36px bold white**
- Dosage text (22px white70)
- "Due at [time]" (18px white54)
- "I TOOK IT" button: **80px height**, FilledButton, dark green `#1B5E20`, 24px bold
- "SKIP" button: **80px height**, OutlinedButton, red `#FF8A80` border, 24px bold
- No SNOOZE option (by design — the escalation's final tier)

#### KEY DIFFERENCES

| Feature           | Design                              | Current                   |
| ----------------- | ----------------------------------- | ------------------------- |
| Background        | Pulsing radial gradient + blur orbs | Solid dark color          |
| Time display      | 64px extrabold, prominent           | Not shown as hero         |
| Content card      | White rounded card island           | No card, inline text      |
| Step indicator    | "Step 1 of 3 today" dots            | Not shown                 |
| Warning banner    | ✅ Lunch window warning             | ❌                        |
| SNOOZE button     | ✅ "Remind me in 10 min" (88px)     | ❌ No snooze at this tier |
| Skip option       | Text link below buttons             | Full 80px OutlinedButton  |
| Button height     | 88px                                | 80px                      |
| Caregiver warning | ✅ Small text at bottom             | ❌                        |
| Button text       | "I've Done It"                      | "I TOOK IT"               |
| Icon style        | Teal circle with shadow             | Simple white icon         |
| Date/time         | Prominent in header                 | "Due at..." inline text   |

---

### 2.9 Add Reminder (Manual)

**Design file**: `add-reminder-manual.html`
**Current code**: `lib/features/reminders/presentation/reminder_list_screen.dart` (just a TODO stub)

#### NEW DESIGN Layout

- **Header**: Back arrow + "New Reminder" (22px bold) + "Templates" link (accent blue)
- **Input Mode Toggle**: Segmented control (h-12, rounded-xl, grey bg)
  - "Say It" (mic icon) — unselected
  - "Build It" (tune icon) — selected (primary bg, white text, shadow)
- **Reminder Name**: Label (sm semibold uppercase tracking-wider), input (h-14, rounded-xl, shadow-sm)
- **Reminder Type**: 2×2 grid of type buttons
  - Medicine (selected: accent blue bg, white text, filled pill icon)
  - Meal (restaurant icon)
  - Activity (directions_run icon)
  - Call (phone_in_talk icon)
  - Each: p-4, rounded-xl, icon 3xl, mt-2 font-bold label
- **Time Setting**: Segmented control
  - "Fixed Time" (schedule icon)
  - "Linked to Event" (selected: white bg, shadow, calendar icon)
  - Event dropdown: "Lunch" with expand_more chevron
  - Before/After toggle pills (rounded-full)
  - Offset input: number field (5 min)
- **Notes**: Textarea (h-20, rounded-xl, placeholder "e.g. 1 tablet with water")
- **Repeat Section**: White card (rounded-2xl, shadow-sm)
  - "Daily Repeat" toggle switch
  - Day-of-week pills: M T W T F S S (each 36px circle, primary bg when selected)
- **Sticky Bottom**: "Add to My Day" button (h-14, primary bg, rounded-[14px], shadow-lg)

#### CURRENT APP

- `reminder_list_screen.dart` contains only: `// TODO(memo-care): Implement in Phase 07`
- No add-reminder UI exists

#### STATUS: **COMPLETELY NEW SCREEN** (current is just a stub)

---

### 2.10 Add Reminder (Voice) — NEW

**Design file**: `add-reminder-voice.html`
**Current code**: None

#### NEW DESIGN Layout

- Same header and mode toggle as manual, but "Say It" is selected
- **Voice Input Area**:
  - Soft grey bg (rounded-xl, min-h-120pt)
  - Placeholder text: "e.g. Take Paracetamol 5 minutes before lunch..."
  - Waveform visualizer (5 animated bars, 3px width, primary color)
  - Mic button (white circle shadow, primary mic icon)
- **Example Phrases**: Scrollable chips ("Before meal medicine", "After Iftar", "Call my son weekly")
- **Parsed Chain Preview Panel**:
  - Primary/5 bg, primary/10 border, rounded-2xl
  - "I'll remind you:" heading (16pt semibold primary)
  - Dotted connector line with teal-accent dots
  - Parsed rows: time (lg bold primary) + medicine name (slate-600 medium)
  - "Looks right?" prompt with Edit + Confirm buttons
- **Sticky Bottom**: "Add to My Day" button (h-56pt, primary bg, rounded-[14px], 20pt bold)

#### STATUS: **COMPLETELY NEW SCREEN**

- No voice input, NLP parsing, or waveform visualization exists
- No parsed chain preview UI exists
- Unique colors: `#2DD4BF` (teal-accent for dots)

---

### 2.11 Visual Chain Builder — NEW

**Design file**: `visual-chain-builder.html`
**Current code**: `lib/features/chain_engine/` has domain + data, no visual builder UI

#### NEW DESIGN Layout

- **Header**: Fixed top, backdrop-blur, back button + "Chain Builder" title + subtitle "Lunch Medicine Chain"
  - "Save Chain" (accent-blue text button)
  - "Test Run" button (outlined, primary border, play_arrow icon)
- **Canvas**: Dot-grid background (radial-gradient dots, 24px spacing), scrollable
- **Anchor Node**:
  - Gold `#F0A500` pill shape (rounded-full, px-8 py-4, white border-4)
  - Schedule icon + "Lunch Anchor" label + "1:00 PM" (xl bold), edit icon
- **Chain Nodes**: Connected with lines + arrows
  - Each: 320px wide, rounded-xl, shadow-md, colored left strip (3px)
    - Blue strip = medication, Green strip = meal, Grey strip = activity
  - Title (17pt semibold), type icon, offset badge ("5 min BEFORE" / "30 min AFTER")
  - Connector labels: "After Done" / "Always" (on the line between nodes)
  - Dashed connector = "regardless of completion"
- **Add Step Button**: Dashed border, accent-blue/5 bg, add_circle icon
- **Mini-Map**: Fixed bottom-right (128×160px), simplified node preview
- **Zoom Controls**: Fixed bottom-left (3 circular buttons: +, -, center focus)
- **Timeline Simulation Sheet**: Bottom sheet (hidden by default)
  - Drag handle, "Timeline Simulation" title, pause button
  - Timeline items with colored dots + times
- **Bottom Nav**: 4 items (Chains active, Schedule, Patients, Settings)

#### CURRENT APP

- `chain_engine/` has domain models (`ChainContext`) and data layer
- `ChainContextScreen`: Simple upstream/downstream text list view, no visual builder
- No canvas, no drag-and-drop, no node editor, no connectors, no mini-map

#### STATUS: **COMPLETELY NEW SCREEN**

- Unique colors: `#F0A500` (accent-gold), `#4A90D9` (accent-blue)

---

### 2.12 Kids Mode Dashboard — NEW

**Design file**: `kids-mode-dashboard.html`
**Current code**: None

#### NEW DESIGN Layout — **Entirely different design language**

- **Color palette override**: Primary `#7C3AED` (purple), green `#22C55E`, yellow `#FBBF24`, coral `#F87171`
- **Border radius**: Default `1rem`, large `1.5rem`, xl `2rem` (bigger, rounder)
- **Background**: `#FDFCFE` (very light pink-white)
- **Parent View Toggle**: purple/10 bg, purple text, lock icon, rounded-full
- **Points Display**: yellow/20 bg, yellow/40 border, star icon + "125 pts"
- **Header**: "Good Morning, Aryan! 🌟" (26pt bold purple), star rating (3/5 gold stars)
- **Mascot**: smart_toy icon (5xl) in purple/10 circle (80px, white border-4, shadow-lg)
- **Progress Bar**: "Your Morning Quest 🎯" title
  - Full-width bar (h-6): gradient-to-r from purple to green (40% filled)
  - Bordered + inner shadow
  - "Aryan has done 2 out of 5 tasks" with green check icon
- **Daily Checklist**: 5 task cards (72pt height each)
  - Done tasks: green circle check + strikethrough text + grey time
  - Active task: coral bottom border (4px), ring-4 coral/10, empty circle, bold text
  - Future tasks: slate-100 border, empty circle, normal text
  - Each card: white bg, rounded-xl, shadow-sm/md, px-6
- **Decorative**: auto_awesome sparkle icon (9xl, warm-yellow, 20% opacity, rotated)
- **Kids Bottom Nav**: Unique design
  - Primary/10 border-t-4, rounded-t-xl, shadow-2xl
  - Quest (rocket_launch, filled, with purple/20 bg pill), Prizes (emoji_events), Me (face_6)
  - Bold uppercase tracking-wider labels

#### STATUS: **COMPLETELY NEW SCREEN** — entirely new feature module needed

---

### 2.13 Kids Mode Reward (Mascot) — NEW

**Design file**: `kids-mode-reward-mascot.html`
**Current code**: None

#### NEW DESIGN Layout

- **Full-screen celebration**: White bg, centered, overflow-hidden
- **Confetti Animation**: 50 falling circles (12px, random colors from purple/green/yellow/coral)
  - `confetti-fall` keyframe: translateY -100vh → 100vh + rotate 720deg, 4s linear infinite
- **Completion Card**: White bg, yellow border-4, rounded-3xl (24px), p-8
  - Shadow: `0 20px 25px -5px rgba(124,58,237,0.1)`
  - Decorative background stars (★ characters, yellow, 20% opacity)
  - **Big Gold Star**: SVG star (180px), `#FBBF24` fill, `#D97706` stroke
    - `star-pop` animation: scale 0.5→1.1→1, cubic-bezier bounce
    - Dashed spinning border circle overlay (30% opacity)
  - **Mascot Robot** (SVG, animated):
    - Purple body with pink antenna, white eyes, yellow belly screen
    - Waving arm animation (rotating -10° to 20°)
    - Bobbing animation (translateY 0 → -5px)
    - Positioned top-right of card
  - **Text**: "Amazing! You did everything!" (28pt bold purple)
  - **Points**: "You earned **50** bonus stars today!" (18pt semibold slate-600, yellow bold number)
  - **Sound note**: "[Cheerful Fanfare & Sparkle Sounds Play]" (sm italic, purple/60)
  - **Button**: "Back to Dashboard" (h-64px, purple bg, white text, xl bold, rounded-full, shadow-lg)

#### STATUS: **COMPLETELY NEW SCREEN**

---

### 2.14 Kids Mode Reward (Sound) — NEW

**Design file**: `kids-mode-reward-sound.html`
**Current code**: None

#### NEW DESIGN Layout

- **Identical to Mascot variant** EXCEPT:
  - No mascot robot SVG (the waving robot is absent)
  - No "[Cheerful Fanfare & Sparkle Sounds Play]" sound note italic text
  - Same confetti, star, card, text, button
  - This appears to be the "simpler" reward variant without mascot character

#### STATUS: **COMPLETELY NEW SCREEN** (variant of reward celebration)

---

### 2.15 Ramadan / Fasting Mode — NEW

**Design file**: `ramadan-fasting.html`
**Current code**: None

#### NEW DESIGN Layout — **Entirely different visual theme**

- **Dark mode forced**: `class="dark"` on html element
- **Background**: `#0D1B2A` (deep navy), star-dot pattern overlay (radial-gradient dots, 40px spacing, 10% white)
- **Primary override**: `#F0A500` (gold — replaces navy primary)
- **Header**: Backdrop-blur, sticky
  - Moon icon (brightness_3) in gold/10 circle
  - "Ramadan Mode" (lg bold white) + "Day 14 of 30" (xs white/50)
  - Notification + Settings icon buttons (white/5 bg)
- **Location Button**: "Delhi, India" with gold location pin, expand_more chevron
- **Twin Time Cards** (side by side, flex):
  - **Sehri**: Card bg `#1A2E44`, sehri-blue top border (2px), nights_stay icon
    - "SEHRI ENDS" (13px uppercase tracking-wider, white/70)
    - "4:28 AM" (3xl bold white)
    - "in 1h 12m" countdown (13px amber/90)
  - **Iftar**: Card bg `#1A2E44`, iftar-gold top border (2px), wb_twilight icon
    - "IFTAR TODAY" (13px uppercase tracking-wider, white/70)
    - "7:30 PM" (3xl bold white)
    - "in 14h 3m" countdown (13px gold)
- **Progress Bar**:
  - Labels: "Sehri 4:28 AM" left, "44% of fast completed" center (gold), "Iftar 7:30 PM" right
  - Bar: h-3, white/5 bg, border, gradient fill (sehri-blue → iftar-gold)
  - Current position dot: 2px white with glow shadow
- **Sehri Medicines Section**:
  - bedtime icon (sehri-blue) + "Sehri Medicines" header
  - Vertical gradient line (sehri-blue/50 → sehri-blue/10)
  - Medicine cards: `#1A2E44` bg, white/5 border, rounded-xl
    - Icon in colored circle (40px), name, instruction, status badge
    - "Taken" badge: sehri-blue text, sehri-blue/10 bg
- **Iftar Medicines Section**:
  - wb_twilight icon (iftar-gold) + "Iftar Medicines" header
  - Vertical gradient line (iftar-gold/50 → iftar-gold/10)
  - Medicine cards similar, with offset labels ("-1 min", "+30 min")
  - Future items: 70% opacity
- **FAB**: Gold bg, 56px circle, shadow, elevated (-top-6 from nav), add icon
- **Bottom Nav**: 5 items (Home, Fast active with filled moon, FAB space, Meds, Profile)
  - White/5 border-t, deep navy bg/90, backdrop-blur-xl

#### STATUS: **COMPLETELY NEW SCREEN** — entirely new feature module + theme needed

---

### 2.16 Generated Screen — NEW

**Design file**: `generated-screen.html`
**Current code**: None

#### NEW DESIGN Layout

- **Identical to kids-mode-reward-sound.html** in this export
  - Same celebration card, confetti, gold star, text, button
  - Appears to be a generated celebration screen variant
  - No mascot, no sound note text
  - Likely a template/placeholder for dynamically generated reward screens

#### STATUS: **COMPLETELY NEW SCREEN** (or variant of celebration template)

---

## 3. Complete New Screens Summary

| #   | Screen                    | Design File                    | Current Status     | Complexity                      |
| --- | ------------------------- | ------------------------------ | ------------------ | ------------------------------- |
| 1   | Template Detail Sheet     | `template-detail-sheet.html`   | No code            | Medium                          |
| 2   | Add Reminder (Manual)     | `add-reminder-manual.html`     | TODO stub only     | High                            |
| 3   | Add Reminder (Voice)      | `add-reminder-voice.html`      | No code            | Very High (NLP + speech)        |
| 4   | Visual Chain Builder      | `visual-chain-builder.html`    | Domain only, no UI | Very High (canvas + drag)       |
| 5   | Kids Mode Dashboard       | `kids-mode-dashboard.html`     | No code            | High (new theme system)         |
| 6   | Kids Mode Reward (Mascot) | `kids-mode-reward-mascot.html` | No code            | Medium (animations)             |
| 7   | Kids Mode Reward (Sound)  | `kids-mode-reward-sound.html`  | No code            | Medium                          |
| 8   | Ramadan / Fasting Mode    | `ramadan-fasting.html`         | No code            | High (new theme + prayer times) |
| 9   | Generated Screen          | `generated-screen.html`        | No code            | Low (variant)                   |

---

## 4. Full Design Token Reference

### 4.1 Colors (All hex values found across designs)

#### Main Theme

| Token            | Hex                    | Usage                                     |
| ---------------- | ---------------------- | ----------------------------------------- |
| primary          | `#1A3C5B`              | Headers, buttons, text, backgrounds       |
| accent           | `#4A90D9`              | Links, selected states, secondary actions |
| background-light | `#F6F7F8` or `#F7F9FC` | Page backgrounds                          |
| background-dark  | `#13191F`              | Dark mode page backgrounds                |
| soft-grey        | `#F0F4F8`              | Input backgrounds, chips                  |
| success          | `#22C55E`              | Done buttons, confirmed states            |
| success-dark     | `#27AE60`              | Alternate success (alert screen)          |
| danger           | `#EF4444`              | Delete actions, missed states             |
| warning          | `#F39C12` / `#F59E0B`  | Late/amber states, warning banners        |
| accent-gold      | `#D4AF37`              | Fasting mode accent (settings)            |
| accent-teal      | `#0D9488`              | Caregiver actions                         |

#### Status Colors

| Token            | Hex       | Usage          |
| ---------------- | --------- | -------------- |
| compliance-green | `#22C55E` | Taken status   |
| compliance-amber | `#F59E0B` | Late status    |
| compliance-red   | `#EF4444` | Missed status  |
| compliance-grey  | `#94A3B8` | Skipped status |

#### Ramadan/Fasting Theme

| Token              | Hex       | Usage                        |
| ------------------ | --------- | ---------------------------- |
| primary (override) | `#F0A500` | Gold primary for Ramadan     |
| background         | `#0D1B2A` | Deep navy background         |
| card-bg            | `#1A2E44` | Card backgrounds             |
| sehri-blue         | `#4A90E2` | Sehri time cards, indicators |
| iftar-gold         | `#F0A500` | Iftar time cards, indicators |

#### Kids Mode Theme

| Token                      | Hex                   | Usage                    |
| -------------------------- | --------------------- | ------------------------ |
| brandPurple                | `#7C3AED`             | Primary for kids mode    |
| brandLightPurple           | `#F5F3FF`             | Light purple backgrounds |
| brandYellow / warm-yellow  | `#FBBF24`             | Stars, points, rewards   |
| brandGreen / playful-green | `#22C55E` / `#10B981` | Done states, progress    |
| brandCoral / coral-pink    | `#FB7185` / `#F87171` | Active task highlights   |
| background-light (kids)    | `#FDFCFE`             | Kids page background     |

#### Chain Builder

| Token       | Hex       | Usage                    |
| ----------- | --------- | ------------------------ |
| accent-gold | `#F0A500` | Anchor nodes             |
| accent-blue | `#4A90D9` | Action buttons, add step |
| blue-500    | Standard  | Medication node strip    |
| green-500   | Standard  | Meal node strip          |
| slate-400   | Standard  | Activity node strip      |

#### Voice Mode

| Token       | Hex       | Usage                     |
| ----------- | --------- | ------------------------- |
| teal-accent | `#2DD4BF` | Parsed chain preview dots |
| soft-grey   | `#F0F4F8` | Input area background     |

### 4.2 Typography (All sizes found)

| Size        | Tailwind Class | Pixel Equivalent | Usage                                      |
| ----------- | -------------- | ---------------- | ------------------------------------------ |
| text-[64px] | —              | 64px             | Alarm clock time                           |
| text-4xl    | text-4xl       | 36px             | Welcome heading, celebration               |
| text-3xl    | text-3xl       | 30px             | Hero card medicine name, Sehri/Iftar times |
| text-[32px] | —              | 32px             | Alert medicine name                        |
| text-[28pt] | —              | 28pt / 37px      | Screen titles ("Today", "History")         |
| text-[26pt] | —              | 26pt / 35px      | Kids greeting                              |
| text-[28px] | —              | 28px             | Alert header                               |
| text-[24px] | text-2xl       | 24px             | Snooze button text                         |
| text-[22pt] | —              | 22pt / 29px      | Section titles, profile name               |
| text-[22px] | —              | 22px             | Compliance ring percentage                 |
| text-[20pt] | —              | 20pt / 27px      | Kids task text, bottom button              |
| text-xl     | text-xl        | 20px             | Date text, instruction text                |
| text-[18pt] | —              | 18pt / 24px      | Card titles, medicine names                |
| text-lg     | text-lg        | 18px             | Hero time, descriptions                    |
| text-[17pt] | —              | 17pt / 23px      | Settings rows, card items                  |
| text-[16pt] | —              | 16pt / 21px      | Kids time labels, chain preview            |
| text-[15pt] | —              | 15pt / 20px      | Template subtitle, info text               |
| text-base   | text-base      | 16px             | Filter chips, category pills               |
| text-[14pt] | —              | 14pt / 19px      | Schedule card time, notes                  |
| text-sm     | text-sm        | 14px             | Badges, tags, subtitles                    |
| text-[13pt] | —              | 13pt / 17px      | Timeline time labels, Ramadan labels       |
| text-xs     | text-xs        | 12px             | Progress labels, nav labels, chips         |
| text-[11px] | —              | 11px             | Template card tags                         |
| text-[10px] | —              | 10px             | Nav labels, log timestamps                 |
| text-[8px]  | —              | 8px              | "DONE" label in progress ring              |

### 4.3 Spacing / Sizing

| Element               | Size                  | Usage                       |
| --------------------- | --------------------- | --------------------------- |
| User avatar           | 56px (size-14)        | Home header                 |
| Progress ring         | 64px (size-16)        | Home header                 |
| Hero icon circle      | 256px                 | Onboarding welcome          |
| Mascot container      | 80px                  | Kids header                 |
| Profile avatar        | 80px                  | Settings profile            |
| Alert icon            | 80px                  | Full-screen alert           |
| Celebration star      | 180px                 | Kids reward                 |
| Timeline circle       | 40px (size-10)        | Home timeline               |
| Icon bg square        | 40px (w-10 h-10)      | Settings rows               |
| Template icon circle  | 40pt                  | Template cards              |
| Status dot            | 2.5px (w-2.5 h-2.5)   | History logs                |
| Week dot              | 1.5px (w-1.5 h-1.5)   | History week strip          |
| Card left strip       | 2-3px width           | Schedule cards, chain nodes |
| Day pill              | 36px (w-9 h-9)        | Reminder repeat section     |
| Filter chip height    | 36pt (h-[36pt])       | Schedule summary            |
| Search bar height     | 48pt (h-[48pt])       | Template search             |
| Input height          | 56px (h-14)           | Form inputs                 |
| Button height         | 56px (h-14) standard  | Most buttons                |
| Alert button height   | 88px (h-[88px])       | Full-screen alert           |
| Kids button height    | 64px (h-[64px])       | Reward screen               |
| Kids task card height | 72pt (h-[72pt])       | Dashboard tasks             |
| Template card height  | 120pt (h-[120pt])     | Template library            |
| Chain node width      | 320px (w-[320px])     | Chain builder               |
| Mini map              | 128×160px (w-32 h-40) | Chain builder               |
| Bottom nav padding    | pb-6 (24px)           | All screens                 |

### 4.4 Border Radius Values

| Value  | Tailwind                       | Usage                            |
| ------ | ------------------------------ | -------------------------------- |
| 8px    | rounded (DEFAULT)              | Standard rounding                |
| 12px   | rounded-lg (in some configs)   | Cards, buttons                   |
| 14px   | rounded-[14px]                 | Add reminder button              |
| 16px   | rounded-xl                     | Cards, sections                  |
| 24px   | rounded-t-[24px] / rounded-3xl | Bottom sheets, celebration cards |
| 32px   | rounded-2xl                    | Summary cards, repeat sections   |
| 9999px | rounded-full                   | Pills, avatars, circles, chips   |

### 4.5 Shadow Values

| Level            | CSS                                     | Usage                     |
| ---------------- | --------------------------------------- | ------------------------- |
| shadow-sm        | `0 1px 2px rgba(0,0,0,0.05)`            | Cards, inputs             |
| shadow-md        | `0 4px 6px -1px rgba(0,0,0,0.1)`        | Active cards, chain nodes |
| shadow-lg        | `0 10px 15px -3px rgba(0,0,0,0.1)`      | Buttons, FAB              |
| shadow-xl        | `0 20px 25px -5px rgba(0,0,0,0.1)`      | Hero cards, alert         |
| shadow-2xl       | `0 25px 50px -12px rgba(0,0,0,0.25)`    | FAB, bottom sheets        |
| Kids card shadow | `0 20px 25px -5px rgba(124,58,237,0.1)` | Celebration card          |
| Ramadan glow     | `0 0 8px rgba(255,255,255,0.8)`         | Progress dot              |

### 4.6 Icons Used (Material Symbols Outlined)

| Icon Name                       | Screen(s)                 | Filled?    |
| ------------------------------- | ------------------------- | ---------- |
| `home`                          | All navs                  | Yes (home) |
| `calendar_month`                | Home nav                  |            |
| `calendar_today`                | Schedule nav              | Yes        |
| `pill`                          | Home nav, reminder type   | Yes        |
| `person`                        | Nav, settings             |            |
| `settings`                      | Settings nav              | Yes        |
| `schedule`                      | Timeline, onboarding      |            |
| `check_circle`                  | Done states, alert        | Yes        |
| `check`                         | Timeline done             |            |
| `close`                         | Timeline missed           |            |
| `cancel`                        | Schedule missed           | Yes        |
| `hourglass_empty`               | Timeline upcoming         |            |
| `notifications_active`          | Hero card, alert, history | Yes        |
| `alarm_off`                     | Snooze button             |            |
| `add`                           | FAB buttons               |            |
| `arrow_back` / `arrow_back_ios` | Headers                   |            |
| `more_horiz`                    | Settings menu             |            |
| `format_size`                   | Text size setting         |            |
| `contrast`                      | High contrast setting     |            |
| `dark_mode`                     | Dark mode setting         |            |
| `volume_up` / `volume_mute`     | Volume slider             |            |
| `snooze`                        | Snooze setting            |            |
| `priority_high`                 | Escalation delay          |            |
| `sms`                           | Caregiver SMS             |            |
| `light_mode`                    | Fasting mode toggle       | Yes        |
| `person_add`                    | Add caregiver             |            |
| `file_export`                   | Export data               |            |
| `cloud_upload`                  | Backup                    |            |
| `delete_forever`                | Delete data               |            |
| `search`                        | Template search           |            |
| `chevron_right`                 | Template cards, nav       |            |
| `analytics`                     | Glucose check             |            |
| `medication`                    | Medicine items            |            |
| `info`                          | Info banner               |            |
| `picture_as_pdf`                | Export PDF                |            |
| `history`                       | History nav               | Yes        |
| `favorite`                      | Care nav, BP pack         |            |
| `elderly`                       | Profile type              |            |
| `family_restroom`               | Parent profile            |            |
| `volunteer_activism`            | Caregiver link            |            |
| `celebration`                   | Onboarding success        |            |
| `done`                          | Setup summary             |            |
| `call`                          | Phone input               |            |
| `warning`                       | Alert warning             |            |
| `mic`                           | Voice input               |            |
| `tune`                          | Manual Build input        |            |
| `restaurant`                    | Meal type                 |            |
| `directions_run`                | Activity type             |            |
| `phone_in_talk`                 | Call type                 |            |
| `event_note`                    | Event dropdown            |            |
| `expand_more`                   | Dropdowns                 |            |
| `repeat`                        | Repeat section            |            |
| `account_tree`                  | Chain nav                 | Yes        |
| `play_arrow`                    | Test Run                  |            |
| `edit`                          | Anchor edit               |            |
| `directions_walk`               | Walk activity             |            |
| `add_circle`                    | Add step                  |            |
| `filter_center_focus`           | Canvas center             |            |
| `pause`                         | Simulation pause          |            |
| `group`                         | Patients nav              |            |
| `lock`                          | Parent view, locked items |            |
| `stars`                         | Points display            | Yes        |
| `star`                          | Rating                    | Yes        |
| `smart_toy`                     | Mascot                    |            |
| `rocket_launch`                 | Quest nav                 | Yes        |
| `emoji_events`                  | Prizes nav                |            |
| `face_6`                        | Me nav                    |            |
| `auto_awesome`                  | Decorative sparkle        |            |
| `brightness_3`                  | Ramadan moon              | Yes        |
| `nights_stay`                   | Sehri                     |            |
| `wb_twilight`                   | Iftar                     |            |
| `location_on`                   | Location                  |            |
| `bedtime`                       | Sehri section             |            |
| `vaccines`                      | Vitamin                   |            |
| `syringe`                       | Diabetic pack             |            |
| `water_drop`                    | Hydration                 |            |
| `school`                        | School pack               |            |

### 4.7 Animations (Design Specifications)

| Animation        | Screen      | Properties                                                   |
| ---------------- | ----------- | ------------------------------------------------------------ |
| `confetti-fall`  | Kids Reward | translateY -100vh→100vh, rotate 720deg, 4s linear infinite   |
| `star-pop`       | Kids Reward | scale 0.5→1.1→1.0, 0.8s cubic-bezier(0.175,0.885,0.32,1.275) |
| `shimmer-effect` | Kids Reward | background-position 0→200%, 2s linear infinite               |
| `waving`         | Kids Mascot | rotate -10deg→20deg, 1.5s ease-in-out infinite               |
| `bobbing`        | Kids Mascot | translateY 0→-5px, 3s ease-in-out infinite                   |
| `pulsing-glow`   | Alert       | Radial gradient background effect                            |
| `spin-slow`      | Kids Reward | Dashed border circle rotation                                |

### 4.8 Gradients

| Gradient           | Screen            | CSS                                                            |
| ------------------ | ----------------- | -------------------------------------------------------------- |
| Onboarding welcome | Onboarding        | `linear-gradient(180deg, #1A3C5B 0%, #7DB9E8 100%)`            |
| Kids progress      | Kids Dashboard    | `linear-gradient(to right, #7C3AED, #22C55E)`                  |
| Alert pulsing      | Full-screen Alert | `radial-gradient(circle at 50% 50%, #1A3C5B 0%, #0D1E2E 100%)` |
| Ramadan progress   | Ramadan           | `linear-gradient(to right, sehri-blue/60, iftar-gold)`         |
| Sehri timeline     | Ramadan           | `linear-gradient(to bottom, sehri-blue/50, sehri-blue/10)`     |
| Iftar timeline     | Ramadan           | `linear-gradient(to bottom, iftar-gold/50, iftar-gold/10)`     |
| Shimmer            | Kids Reward       | `linear-gradient(90deg, #FBBF24 0%, #FFF 50%, #FBBF24 100%)`   |

---

_End of comparison report._
