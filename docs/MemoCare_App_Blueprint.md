# MemoCare — Complete App Architecture Blueprint

**Version:** 2.0 | **Date:** March 2026 | **Platform:** Flutter (iOS + Android)
**Core Value:** Linked Reminder Chains that fire based on user confirmation, not just clock time.

---

## 1. APP ARCHITECTURE

### 1.1 Architecture Pattern

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  Screens → Widgets → GoRouter → AppShell (5-tab nav)    │
├─────────────────────────────────────────────────────────┤
│                    APPLICATION                           │
│  Riverpod Notifiers → Providers → State Management      │
├─────────────────────────────────────────────────────────┤
│                      DOMAIN                              │
│  Models (Freezed) → Services → Engine → Validator        │
├─────────────────────────────────────────────────────────┤
│                       DATA                               │
│  DAOs (Drift/SQLite) → Repositories → SharedPreferences  │
├─────────────────────────────────────────────────────────┤
│                     PLATFORM                             │
│  AlarmManager → Notifications → TTS → Permissions → OEM │
└─────────────────────────────────────────────────────────┘
```

**Pattern:** Feature-first Clean Architecture with Riverpod state management.
Each feature module contains up to 4 layers: `domain/`, `data/`, `application/`, `presentation/`.

### 1.2 App Modules

| Module                      | Purpose                                                   | Layers                     |
| --------------------------- | --------------------------------------------------------- | -------------------------- |
| **core/database**           | Drift SQLite — 5 tables, local-only                       | Data                       |
| **core/platform**           | Native integrations (alarms, TTS, notifications, OEM)     | Platform                   |
| **core/router**             | GoRouter with redirect guards                             | Presentation               |
| **core/theme**              | Design tokens + 3 theme variants (default, kids, ramadan) | Presentation               |
| **core/providers**          | Global singletons (DB, notifications, alarms, TTS)        | Application                |
| **features/anchors**        | Meal anchor CRUD, time resolver for dependent reminders   | All 4                      |
| **features/chain_engine**   | DAG-based chain evaluation, edge traversal                | Domain + Data              |
| **features/confirmation**   | DONE/SNOOZE/SKIP recording, undo, snooze limiting         | All 4                      |
| **features/daily_schedule** | Home dashboard, timeline, hydration, progress ring        | Application + Presentation |
| **features/escalation**     | 3-tier FSM (silent→audible→fullscreen), audio, wakelock   | All 4                      |
| **features/fasting**        | Ramadan mode, prayer times, medicine suppression          | All 4                      |
| **features/history**        | Compliance logs, weekly stats, PDF export                 | All 4                      |
| **features/kids_mode**      | Gamified checklist, quest points, rewards, mascot         | All 4                      |
| **features/onboarding**     | 9-step PageView wizard, condition/template/anchor setup   | All 4                      |
| **features/reminders**      | Reminder CRUD, add form, type grid, scheduling            | All 4                      |
| **features/settings**       | User prefs, caregiver phone, display, fasting toggle      | All 4                      |
| **features/templates**      | Pre-built medicine packs, search, category filter         | All 4                      |

### 1.3 State Management Approach

**Framework:** Riverpod 2.x (manual providers, no code generation)

| Provider Type                | Usage                                     | Example                                                    |
| ---------------------------- | ----------------------------------------- | ---------------------------------------------------------- |
| `Provider<T>`                | Singletons, repositories, computed values | `appDatabaseProvider`, `chainEngineProvider`               |
| `NotifierProvider<N,S>`      | Synchronous mutable state                 | `fastingNotifierProvider`, `kidsModeNotifierProvider`      |
| `AsyncNotifierProvider<N,S>` | Async state with loading/error            | `dailyScheduleNotifierProvider`, `historyNotifierProvider` |
| `StreamProvider<T>`          | Reactive Drift queries                    | `appSettingsProvider`                                      |
| `FutureProvider<T>`          | One-shot async                            | `channelHealthStatusProvider`                              |

**State Flow:**

```
User Action → Widget calls ref.read(notifier).method()
  → Notifier updates state (state = newState)
    → ref.watch(provider) rebuilds dependent widgets
      → If DB write needed: Notifier calls Repository → DAO → Drift
        → Drift stream emits → StreamProvider updates → UI rebuilds
```

### 1.4 Backend / API Interaction Points

**Current:** 100% local. No remote backend.

| Data                                             | Storage                | Technology                     |
| ------------------------------------------------ | ---------------------- | ------------------------------ |
| Reminders, Chains, Edges, Confirmations, Anchors | SQLite                 | Drift ORM                      |
| Settings, Preferences, Onboarding flag           | Key-Value              | SharedPreferences              |
| Alarm scheduling                                 | Android OS             | AlarmManager via MethodChannel |
| Notifications                                    | OS notification center | flutter_local_notifications    |
| Caregiver alerts                                 | WhatsApp URL scheme    | url_launcher (internet needed) |
| Prayer times                                     | Hardcoded calculation  | Local computation (Dhaka)      |

**Future Firebase integration points (designed but not wired):**

- Caregiver sync layer (confirmation states, missed events)
- Cloud backup of reminder data
- Remote caregiver portal (add/edit reminders)
- Push notifications for caregiver alerts

---

## 2. SCREEN MAP

### 2.1 Screen Hierarchy

```
App Launch
├── Onboarding Guard (SharedPreferences check)
│   ├── NOT onboarded → /onboarding (9-step PageView)
│   └── Onboarded → /home
│
├── Main Shell (AppShell — 5-tab NavigationBar)
│   ├── Tab 0: /home → HomeScreen (dashboard)
│   ├── Tab 1: /schedule → TodaysFullScheduleScreen (hourly timeline)
│   ├── Tab 2: FAB → /add-reminder (standalone, no tab)
│   ├── Tab 3: /history → HistoryScreen (compliance logs)
│   └── Tab 4: /profile → SettingsScreen (preferences)
│
├── Standalone Routes (no bottom nav)
│   ├── /add-reminder → AddReminderScreen
│   ├── /templates → TemplateLibraryScreen
│   ├── /reminder/:id/chain → ChainContextScreen
│   ├── /kids → KidsDashboardScreen
│   ├── /kids/reward → KidsRewardScreen
│   ├── /kids/reward-sound → KidsRewardSoundScreen
│   └── /ramadan → RamadanScreen
│
└── System-Triggered (no manual navigation)
    └── FullScreenAlarmScreen (escalation Layer 3)
```

### 2.2 All Screens (18 total)

| #   | Screen                       | Route               | Purpose                                                 | Nav        |
| --- | ---------------------------- | ------------------- | ------------------------------------------------------- | ---------- |
| 1   | OnboardingPageView           | /onboarding         | 9-step first-time setup wizard                          | Standalone |
| 2   | HomeScreen                   | /home               | Dashboard: greeting, hero card, timeline, progress ring | Tab 0      |
| 3   | TodaysFullScheduleScreen     | /schedule           | Hourly timeline with chain groups and stats             | Tab 1      |
| 4   | AddReminderScreen            | /add-reminder       | Create/edit reminders (voice + manual modes)            | FAB        |
| 5   | HistoryScreen                | /history            | Compliance donut, week strip, daily logs                | Tab 3      |
| 6   | SettingsScreen               | /profile            | Preferences, caregiver, display, fasting toggle         | Tab 4      |
| 7   | TemplateLibraryScreen        | /templates          | Browse/search pre-built medicine packs                  | Push       |
| 8   | TemplatePickerScreen         | (onboarding)        | Select template during setup                            | Embedded   |
| 9   | ChainContextScreen           | /reminder/:id/chain | View chain graph for a specific reminder                | Push       |
| 10  | FullScreenAlarmScreen        | (system)            | Escalation Layer 3 fullscreen takeover                  | System     |
| 11  | RamadanScreen                | /ramadan            | Fasting mode: Sehri/Iftar cards, medicine chains        | Push       |
| 12  | KidsDashboardScreen          | /kids               | Gamified daily checklist with quest points              | Push       |
| 13  | KidsRewardScreen             | /kids/reward        | Celebration screen on quest completion                  | Push       |
| 14  | KidsRewardSoundScreen        | /kids/reward-sound  | Sound selection for reward celebration                  | Push       |
| 15  | MissedRemindersSheet         | (bottom sheet)      | Shows missed reminders on dashboard                     | Modal      |
| 16  | TemplateDetailSheet          | (bottom sheet)      | Template preview with activator                         | Modal      |
| 17  | OemBatteryGuidancePage       | (onboarding)        | OEM-specific battery optimization instructions          | Embedded   |
| 18  | WelcomePage..CelebrationPage | (onboarding)        | 9 individual onboarding step pages                      | Embedded   |

---

## 3. NAVIGATION STRUCTURE

### 3.1 Router Configuration

```dart
GoRouter(
  redirect: (context, state) {
    final prefs = ref.read(sharedPreferencesProvider);
    final onboarded = prefs.getBool('onboarding_complete') ?? false;
    final isOnboardingPath = state.uri.path.startsWith('/onboarding');

    if (!onboarded && !isOnboardingPath) return '/onboarding';
    if (onboarded && isOnboardingPath) return '/home';
    return null; // no redirect
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => AppShell(shell),
      branches: [
        // Branch 0: /home → HomeScreen
        // Branch 1: /schedule → TodaysFullScheduleScreen
        // Branch 2: /history → HistoryScreen
        // Branch 3: /profile → SettingsScreen
      ],
    ),
    // Standalone: /onboarding, /add-reminder, /templates,
    //             /reminder/:id/chain, /kids/*, /ramadan
  ],
)
```

### 3.2 Bottom Navigation

```
┌──────────────────────────────────────────┐
│  🏠 Home  │  📋 Schedule  │  ➕  │  📊 History  │  👤 Profile  │
│  (Tab 0)  │  (Tab 1)      │ FAB  │  (Tab 2)     │  (Tab 3)     │
└──────────────────────────────────────────┘
         Tab index 2 is intercepted → navigates to /add-reminder
         Tabs 3-4 in UI map to branches 2-3 in GoRouter
```

---

## 4. DATABASE SCHEMA

### 4.1 Entity Relationship

```
ReminderChains (1) ──< (N) Reminders
Reminders (1) ──< (N) Confirmations
ReminderChains (1) ──< (N) ChainEdges
MealAnchors (standalone, linked by mealType)

ChainEdges: sourceId ──→ targetId (DAG edges within a chain)
```

### 4.2 Tables

**ReminderChains**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| name | TEXT | Chain name (e.g., "Lunch Medicine Chain") |
| isActive | BOOLEAN | Soft delete flag |
| createdAt | INTEGER | UTC epoch millis |

**Reminders**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| chainId | INTEGER FK | References ReminderChains |
| medicineName | TEXT | Display label |
| medicineType | TEXT | Enum: before_meal/after_meal/empty_stomach/fixed_time/dose_gap |
| dosage | TEXT? | e.g., "500mg, 1 tablet" |
| scheduledAt | INTEGER? | UTC epoch millis, null = not yet resolved |
| isActive | BOOLEAN | Whether alarm is armed |
| gapHours | INTEGER? | For dose_gap type only |

**ChainEdges**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| chainId | INTEGER FK | References ReminderChains |
| sourceId | INTEGER FK | Parent reminder ID |
| targetId | INTEGER FK | Child reminder ID |

**Confirmations**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| reminderId | INTEGER FK | References Reminders |
| state | TEXT | Enum: done/snoozed/skipped |
| confirmedAt | INTEGER | UTC epoch millis |
| snoozeUntil | INTEGER? | UTC epoch millis, only for snoozed |

**MealAnchors**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| mealType | TEXT | breakfast/lunch/dinner |
| defaultTime | INTEGER | Minutes from midnight (e.g., 780 = 1:00 PM) |
| confirmedAt | INTEGER? | UTC epoch millis of today's meal confirmation |

---

## 5. FLOW DIAGRAMS

### 5.1 Core Reminder Lifecycle

```
[User Creates Reminder] → ChainEngine validates → DB insert → AlarmScheduler.schedule()
         │
         ▼
[Alarm Fires at scheduledAt] → Background Isolate callback
         │
         ▼
[EscalationFSM starts] → Silent notification (Layer 1)
         │                          │
         │ (2 min timeout)          │ User taps DONE/SNOOZE/SKIP
         ▼                          ▼
[Audible notification]      [ConfirmationService.confirm()]
         │                          │
         │ (3 min timeout)          ├─ DONE → Persist → ChainEngine evaluates
         ▼                          │         → Activate downstream reminders
[Fullscreen takeover]               │         → Schedule next alarm
         │                          │
         │ (20 min timeout)         ├─ SNOOZE → Check snooze limit (max 3)
         ▼                          │           → Reschedule at +5/10/15 min
[Caregiver WhatsApp alert]          │           → Or auto-skip if limit reached
                                    │
                                    └─ SKIP → Persist → ChainEngine evaluates
                                              → Suspend all downstream (EAGER)
                                              → Cancel downstream alarms
```

### 5.2 Chain Engine Evaluation

```
On DONE confirmation for Reminder X:
  1. Find all edges where sourceId == X
  2. For each edge → get targetId reminder (LAZY: immediate children only)
  3. Resolve scheduled time based on anchor + offset
  4. Return list of reminders to activate

On SKIP confirmation for Reminder X:
  1. BFS/DFS from X through all edges (EAGER: full transitive closure)
  2. Collect all reachable descendants
  3. Return list of reminders to suspend
  4. Cancel all their alarms

On SNOOZE:
  1. Return the snoozed reminder itself
  2. Caller reschedules alarm at current_time + snooze_duration
```

### 5.3 Escalation Pipeline

```
┌─────────────────────────────────────────────────┐
│              EscalationFSM                       │
│                                                  │
│  SILENT ──(2 min)──▶ AUDIBLE ──(3 min)──▶ FULLSCREEN  │
│    │                    │                    │    │
│    │ Notification       │ Sound + Vibration  │ Wakelock     │
│    │ Banner             │ + Updated notif    │ + Volume max │
│    │                    │                    │ + FullScreen │
│    │                    │                    │ Intent       │
│    │                    │                    │              │
│    └──── User taps DONE/SNOOZE/SKIP at any tier ─────────┘ │
│              │                                              │
│              ▼                                              │
│    acknowledge() → stop timers → stop audio → release wake  │
│    → persist confirmation → evaluate chain                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. STEP-BY-STEP USER FLOWS

---

### FLOW A: ELDERLY USER (Primary Persona — "Abdul", 68)

**Profile:** Diabetic, hypertensive, fasting in Ramadan. Son set up app for him.
**UX Principles:** Maximum simplicity, large text, single-tap actions, voice feedback.

---

#### A.1 — First Launch & Onboarding

**Entry Point:** App installed, first open.

| Step   | User Action                                        | UI Response                                         | System Logic                                                                                                                                                                                                                                                                      | State Change                                              | Data                             |
| ------ | -------------------------------------------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | -------------------------------- |
| A.1.1  | Opens app                                          | Splash → Welcome page                               | Router redirect: `onboarding_complete == false` → `/onboarding`                                                                                                                                                                                                                   | Route: /onboarding, page: 0                               | Read SharedPrefs                 |
| A.1.2  | Taps "Get Started"                                 | Slide to Profile Type page (Step 1/7)               | PageController.animateToPage(1)                                                                                                                                                                                                                                                   | OnboardingState.currentStep = profileType                 | —                                |
| A.1.3  | Selects "Elderly / Senior" card                    | Card highlights with blue border + soft blue fill   | `onboardingNotifier.setProfileType('elderly')`                                                                                                                                                                                                                                    | profileType = 'elderly'                                   | In-memory                        |
| A.1.4  | Taps "Continue"                                    | Slide to Condition page (Step 2/7)                  | PageController.animateToPage(2)                                                                                                                                                                                                                                                   | currentStep = condition                                   | —                                |
| A.1.5  | Selects "Diabetes" chip                            | Chip fills with accent color, others deselect       | `onboardingNotifier.selectCondition('diabetes')`                                                                                                                                                                                                                                  | selectedCondition = 'diabetes'                            | In-memory                        |
| A.1.6  | Taps "Continue"                                    | Slide to Template page (Step 3/7)                   | PageController.animateToPage(3), shows diabetes-relevant templates                                                                                                                                                                                                                | currentStep = template                                    | —                                |
| A.1.7  | Selects "Diabetic Daily Pack"                      | Template card highlights, preview shows 4 reminders | `onboardingNotifier.selectTemplate('diabetic_daily')`                                                                                                                                                                                                                             | selectedTemplateId = 'diabetic_daily', useTemplate = true | In-memory                        |
| A.1.8  | Taps "Continue"                                    | Slide to Anchors page (Step 4/7)                    | Shows 3 meal anchor time pickers pre-filled                                                                                                                                                                                                                                       | currentStep = anchors                                     | —                                |
| A.1.9  | Sets Breakfast=7:30AM, Lunch=1:00PM, Dinner=8:00PM | Time pickers update                                 | `onboardingNotifier.setMealAnchor('breakfast', 450)` (minutes from midnight)                                                                                                                                                                                                      | mealAnchorDefaults updated for each meal                  | In-memory                        |
| A.1.10 | Taps "Continue"                                    | Slide to Medicines page (Step 5/7)                  | Template medicines shown; user can add custom ones                                                                                                                                                                                                                                | currentStep = medicines                                   | —                                |
| A.1.11 | Adds "Amlodipine 5mg" as custom medicine           | Medicine appears in list with remove button         | `onboardingNotifier.addCustomMedicine(entry)`                                                                                                                                                                                                                                     | customMedicines list grows                                | In-memory                        |
| A.1.12 | Taps "Continue"                                    | Slide to Accessibility page (Step 6/7)              | Shows Large Text toggle + High Contrast toggle                                                                                                                                                                                                                                    | currentStep = accessibility                               | —                                |
| A.1.13 | Enables "Large Text" toggle                        | Preview text below enlarges in real-time            | `settingsRepository.setLargeText(true)`                                                                                                                                                                                                                                           | AppSettings.largeText = true                              | SharedPreferences                |
| A.1.14 | Taps "Continue"                                    | Slide to Caregiver page (Step 7/7)                  | Phone number input with country code picker                                                                                                                                                                                                                                       | currentStep = caregiver                                   | —                                |
| A.1.15 | Enters son's phone "+91XXXXXXXXXX"                 | Green tick inline validation                        | `onboardingNotifier.setCaregiverPhone(phone)` → `settingsRepository.setCaregiverPhone(phone)`                                                                                                                                                                                     | caregiverPhone stored                                     | SharedPreferences                |
| A.1.16 | Taps "Continue"                                    | Slide to Celebration page                           | Gentle confetti animation + checkmark                                                                                                                                                                                                                                             | —                                                         | —                                |
| A.1.17 | Taps "Go to Dashboard"                             | Navigate to /home                                   | `onboardingNotifier.completeOnboarding()` → writes `onboarding_complete=true` to SharedPreferences. Template medicines → DB insert via TemplateService. Anchor times → DB insert via AnchorRepository. Chain edges → DB insert via ChainDao. Alarms scheduled via AlarmScheduler. | isComplete = true, DB populated                           | SQLite + SharedPrefs + OS alarms |

**Flow Complete When:** `onboarding_complete == true` in SharedPreferences AND at least 1 reminder chain exists in DB.
**Incomplete Flow:** User closes app mid-wizard → next launch restarts from page 0 (state is in-memory only).
**Error Recovery:** If permission denied on Android → guidance page shown. If DB write fails → error snackbar + retry.

---

#### A.2 — Daily Dashboard Interaction

**Entry Point:** App opens or user taps Home tab.

| Step  | User Action              | UI Response                                                                       | System Logic                                                                                                                                                                                        | State Change                                                        | Data                     |
| ----- | ------------------------ | --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------ |
| A.2.1 | Opens app                | HomeScreen loads                                                                  | `dailyScheduleNotifierProvider` builds → watches `repo.watchToday()`, `repo.watchMissed()`, `repo.watchConfirmedIds()` streams                                                                      | DailyScheduleState populated                                        | SQLite streams           |
| A.2.2 | Sees greeting            | "Good Morning, Abdul" + date + progress ring (3/8 done)                           | `confirmedCount = todayReminders.where(r => confirmedIds.contains(r.id)).length`                                                                                                                    | —                                                                   | Read from state          |
| A.2.3 | Sees hero card           | Navy card: "UP NEXT · Paracetamol 500mg · 12:55 PM · Take 5 minutes before lunch" | `nextPending` = first future unconfirmed reminder                                                                                                                                                   | —                                                                   | Read from state          |
| A.2.4 | Taps "DONE" on hero card | Card animates out, next reminder slides in, progress ring updates                 | `confirmationNotifier.confirm(reminderId, ConfirmationState.done)` → `ConfirmationService.confirm()` → DB insert → ChainEngine evaluates DONE → activate downstream → AlarmScheduler schedules next | confirmedIds grows, nextPending updates, missedReminders may shrink | SQLite insert + OS alarm |
| A.2.5 | Taps "SNOOZE"            | Toast: "Snoozed for 5 min"                                                        | `confirmationNotifier.confirm(reminderId, ConfirmationState.snoozed)` → SnoozeLimiter checks count ≤ 3 → DB insert snooze → AlarmScheduler reschedules at now+5min                                  | snoozeUntil set                                                     | SQLite + OS alarm        |
| A.2.6 | Scrolls timeline         | Vertical list of today's reminders with colored dots                              | Each tile shows status badge (Done ✓, Missed ✗, Pending ○, Upcoming ◷)                                                                                                                              | —                                                                   | Read from state          |
| A.2.7 | Red banner appears       | "1 missed reminder" tappable banner                                               | `hasMissedRemindersProvider == true` triggers banner                                                                                                                                                | —                                                                   | —                        |
| A.2.8 | Taps banner              | Bottom sheet slides up with missed reminders                                      | MissedRemindersSheet shows list with DONE/SKIP actions                                                                                                                                              | —                                                                   | Read missedReminders     |
| A.2.9 | Pull-to-refresh          | Spinner → data reloads                                                            | `ref.invalidate(dailyScheduleNotifierProvider)`                                                                                                                                                     | Full state rebuild                                                  | Re-query SQLite          |

**Hydration Tracker (sub-flow):**

| Step   | User Action                | UI Response                                          | System Logic                                                     | State Change             | Data              |
| ------ | -------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------- | ------------------------ | ----------------- |
| A.2.H1 | Taps "+" on water counter  | Glass count increments (4/8 → 5/8), glass icon fills | `hydrationNotifier.addGlass()` → SharedPrefs write               | HydrationState.glasses++ | SharedPreferences |
| A.2.H2 | Counter resets at midnight | Shows 0/8 on new day                                 | `build()` checks date token vs stored date → resets if different | glasses = 0              | SharedPreferences |

---

#### A.3 — Alarm Escalation Flow (Background)

**Entry Point:** AlarmManager fires at scheduledAt time. App may be closed.

| Step   | Trigger                         | System Action                                                                  | User Sees                                                                                                                                         | State Change                                     | Data                     |
| ------ | ------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ | ------------------------ |
| A.3.1  | AlarmManager callback           | Background isolate starts. `alarmFiredCallback()` reads reminderId from extras | — (app may be in background)                                                                                                                      | Escalation starts                                | —                        |
| A.3.2  | Escalation starts               | EscalationController.startEscalation() → FSM enters SILENT                     | Silent notification banner: "Paracetamol 500mg · 12:55 PM · DONE / SNOOZE / SKIP"                                                                 | EscalationLevel = silent                         | Notification shown       |
| A.3.3  | 2 min, no response              | FSM timer fires → level = AUDIBLE                                              | Updated notification + alarm sound loops + vibration                                                                                              | EscalationLevel = audible                        | AudioService.startLoop() |
| A.3.4  | 3 more min, no response         | FSM timer fires → level = FULLSCREEN                                           | Full-screen takeover: pulsing navy bg, large white text, 3 huge buttons (DONE/SNOOZE/SKIP)                                                        | EscalationLevel = fullscreen                     | Wakelock + volume max    |
| A.3.5a | User taps "I've Done It"        | Screen dismisses, sound stops                                                  | `EscalationController.acknowledge()` → stop FSM → stop audio → release wakelock → cancel notification → `_handleDone()` writes confirmation to DB | Confirmation(state: done)                        | SQLite insert            |
| A.3.5b | User taps "Remind me in 10 min" | Screen dismisses                                                               | acknowledge() + `_handleSnooze()` writes snoozed confirmation → reschedule alarm at now+5min                                                      | Confirmation(state: snoozed, snoozeUntil: +5min) | SQLite + OS alarm        |
| A.3.5c | User taps "Skip"                | Screen dismisses                                                               | acknowledge() + `_handleSkip()` writes skipped confirmation                                                                                       | Confirmation(state: skipped)                     | SQLite insert            |
| A.3.6  | No response for 20+ min         | Missed state detected                                                          | DailyScheduleNotifier detects new missed reminder → reads caregiverPhone from settings → `CaregiverService.sendMissedReminderAlert()`             | WhatsApp URL opened                              | url_launcher             |

**Caregiver Notification:**

```
WhatsApp message: "MemoCare Alert: Your loved one missed their
Paracetamol 500mg (500mg, 1 tablet) reminder scheduled at 12:55.
Please check on them."
→ Sent via https://wa.me/{phone}?text={encoded_message}
→ Requires internet. If offline, URL launch fails silently.
```

---

#### A.4 — Ramadan/Fasting Mode (Elderly)

**Entry Point:** Settings → enable "Ramadan / Fasting Mode" toggle.

| Step  | User Action                    | UI Response                               | System Logic                                                                                                      | State Change                                                 | Data              |
| ----- | ------------------------------ | ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ | ----------------- |
| A.4.1 | Toggles fasting ON in Settings | Row tints gold, location selector appears | `fastingNotifier.toggleFasting(true)` → load prayer times → compute Sehri/Iftar → suppress daytime meal reminders | FastingState.isActive = true, sehriTime + iftarTime computed | SharedPreferences |
| A.4.2 | Navigates to /ramadan          | Dark navy screen with star pattern        | Screen shows: Sehri/Iftar countdown cards, fasting progress bar, Sehri medicines section, Iftar medicines section | —                                                            | Read FastingState |
| A.4.3 | Sees Sehri countdown           | "Sehri Ends · 4:28 AM · in 1h 12m"        | Timer recalculates every minute                                                                                   | —                                                            | Local computation |
| A.4.4 | Pre-Sehri alarm fires          | Escalation for Sehri medicine chain       | Medicines tagged beforeMeal/emptyStomach linked to Sehri anchor fire in sequence                                  | Normal escalation flow                                       | Alarms + DB       |
| A.4.5 | Taps DONE on Sehri medicine    | Next Sehri chain item fires               | Standard chain DONE evaluation                                                                                    | Downstream activated                                         | SQLite            |
| A.4.6 | Daytime (fasting hours)        | No meal-linked reminders fire             | `isSuppressedDuringFast()` returns true for meal-linked types during fast hours                                   | Reminders skipped silently                                   | —                 |
| A.4.7 | Iftar countdown reaches 0      | Gold Iftar card pulses                    | Iftar anchor time reached → Iftar medicine chain begins                                                           | Post-Iftar chain activates                                   | Alarms            |

---

### FLOW B: YOUNG ADULT (Secondary Persona — "Priya", 32)

**Profile:** Software engineer, skips lunch, forgets hydration. Uses voice setup.
**UX Principles:** Efficient setup, minimal friction, smart defaults.

---

#### B.1 — Quick Onboarding (Template-Based)

| Step  | User Action                             | UI Response                                           | System Logic                                       | State Change                   | Data            |
| ----- | --------------------------------------- | ----------------------------------------------------- | -------------------------------------------------- | ------------------------------ | --------------- |
| B.1.1 | Opens app first time                    | Welcome page                                          | Router redirect → /onboarding                      | —                              | —               |
| B.1.2 | Selects "Adult / Professional"          | Card highlights                                       | setProfileType('adult')                            | profileType = 'adult'          | In-memory       |
| B.1.3 | Selects "General Wellness" condition    | Chip fills                                            | selectCondition('wellness')                        | selectedCondition = 'wellness' | In-memory       |
| B.1.4 | Selects "Hydration Booster" template    | Preview: 8 water reminders spread across waking hours | selectTemplate('hydration_booster')                | selectedTemplateId set         | In-memory       |
| B.1.5 | Keeps default anchor times              | Pre-filled: 8AM/1PM/7PM                               | Already default                                    | No change                      | —               |
| B.1.6 | Adds "Vitamin D" and "Omega-3" manually | Each appears in medicine list                         | addCustomMedicine(entry) for each                  | customMedicines grows          | In-memory       |
| B.1.7 | Skips caregiver setup                   | Taps "Skip for now" link                              | setCaregiverPhone('')                              | caregiverPhone = ''            | —               |
| B.1.8 | Completes onboarding                    | Dashboard loads with hydration + vitamin schedule     | Template + custom medicines → DB, alarms scheduled | Full DB population             | SQLite + alarms |

**Time:** ~2 minutes for a professional user.

---

#### B.2 — Add Custom Reminder (Manual)

**Entry Point:** Taps FAB (+) on any screen.

| Step  | User Action                               | UI Response                                             | System Logic                                                                                                                                                                           | State Change                      | Data              |
| ----- | ----------------------------------------- | ------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- | ----------------- |
| B.2.1 | Taps FAB                                  | AddReminderScreen opens (slides up)                     | GoRouter navigates to /add-reminder                                                                                                                                                    | Route: /add-reminder              | —                 |
| B.2.2 | Types "Omega-3" in name field             | Text input fills                                        | `addReminderNotifier.setName('Omega-3')`                                                                                                                                               | AddReminderState.name = 'Omega-3' | In-memory         |
| B.2.3 | Selects "Medicine" type chip              | Chip fills blue, dose fields appear                     | setReminderType(ReminderType.medicine)                                                                                                                                                 | reminderType = medicine           | In-memory         |
| B.2.4 | Enters "1000mg" dose                      | Dose field fills                                        | setDose('1000mg')                                                                                                                                                                      | dose = '1000mg'                   | In-memory         |
| B.2.5 | Toggles "Linked to Event" mode            | Anchor dropdown appears                                 | setTimeMode(TimeMode.linked)                                                                                                                                                           | timeMode = linked                 | In-memory         |
| B.2.6 | Selects "Lunch" from dropdown             | Offset input appears                                    | setLinkedEvent('lunch')                                                                                                                                                                | linkedEvent = 'lunch'             | In-memory         |
| B.2.7 | Selects "After" pill, enters "30" minutes | Preview: "30 min after Lunch"                           | setOffsetMinutes(30), setOffsetDirection('after')                                                                                                                                      | offsetMinutes = 30                | In-memory         |
| B.2.8 | Taps "Add to My Day"                      | Button animates, screen closes, toast: "Reminder added" | `addReminderNotifier.save()` → validate → create Reminder model → ReminderDao.insert() → if linked: create ChainEdge → AnchorResolver resolves scheduledAt → AlarmScheduler.schedule() | New Reminder in DB, alarm set     | SQLite + OS alarm |

**Validation errors:** Name empty → inline red text. Type not selected → type grid shakes. Save fails → snackbar with retry.

---

#### B.3 — Weekly Call Reminder (Social)

| Step  | User Action                      | UI Response                                      | System Logic                                       | State Change                 | Data           |
| ----- | -------------------------------- | ------------------------------------------------ | -------------------------------------------------- | ---------------------------- | -------------- |
| B.3.1 | Taps FAB                         | AddReminderScreen                                | —                                                  | —                            | —              |
| B.3.2 | Selects "Call" type chip         | Phone icon, name + notes fields                  | setReminderType(ReminderType.call)                 | reminderType = call          | In-memory      |
| B.3.3 | Types "Call Mom"                 | Name fills                                       | setName('Call Mom')                                | name = 'Call Mom'            | In-memory      |
| B.3.4 | Sets fixed time: Sunday 11:00 AM | Time picker + day selector (only 'Sun' selected) | setFixedTime(11:00), selectDays({DateTime.sunday}) | fixedTime + selectedDays set | In-memory      |
| B.3.5 | Saves                            | Reminder created with weekly Sunday recurrence   | DB insert + alarm for next Sunday 11:00 AM         | Reminder in DB               | SQLite + alarm |

---

### FLOW C: KIDS MODE (Secondary Persona — "Aryan", 9, set up by parent)

**Profile:** School-age child with morning routine. Parent configures, child interacts.
**UX Principles:** Gamified, colorful, emoji-rich, reward-driven, parent oversight.

---

#### C.1 — Parent Configures Kids Mode

**Entry Point:** Settings → enable "Kids Mode" toggle (requires PIN in future).

| Step  | User Action (Parent)       | UI Response                               | System Logic                                                                        | State Change                  | Data      |
| ----- | -------------------------- | ----------------------------------------- | ----------------------------------------------------------------------------------- | ----------------------------- | --------- |
| C.1.1 | Navigates to Settings      | SettingsScreen                            | —                                                                                   | —                             | —         |
| C.1.2 | Enables "Kids Mode" toggle | Theme shifts to purple/green palette      | `kidsModeNotifier.setActive(true)`                                                  | KidsModeState.isActive = true | In-memory |
| C.1.3 | Enters child name "Aryan"  | Input field                               | setChildName('Aryan')                                                               | childName = 'Aryan'           | In-memory |
| C.1.4 | Navigates to /kids         | KidsDashboardScreen with default 5 quests | Default quests loaded: Wake up, Brush teeth, Have breakfast, Take vitamin, Pack bag | dailyQuests = 5 defaults      | In-memory |
| C.1.5 | Customizes quest times     | Each quest card has editable time         | Parent adjusts each time slot                                                       | Quest times updated           | In-memory |

**Note:** Kids mode quests are currently in-memory only (not persisted to DB). Points reset on app restart. This is a known limitation for Phase 12+.

---

#### C.2 — Child's Daily Interaction

**Entry Point:** App opens directly to Kids Dashboard (when kids mode is active).

| Step  | User Action (Child)          | UI Response                                                                                    | System Logic                                                                              | State Change                               | Data               |
| ----- | ---------------------------- | ---------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------ | ------------------ |
| C.2.1 | Opens app                    | Animated greeting: "Good Morning, Aryan! 🌟" + mascot waving                                   | KidsDashboardScreen renders with purple theme                                             | —                                          | Read KidsModeState |
| C.2.2 | Sees quest list              | 5 tasks with big checkmark circles, colorful cards                                             | dailyQuests mapped to task cards                                                          | —                                          | Read state         |
| C.2.3 | Taps "Wake up and stretch" ✓ | Card turns green, checkmark animates with spring bounce, +10 points                            | `kidsModeNotifier.completeQuest('quest_1')` → quest.isCompleted = true, dailyPoints += 10 | points.dailyPoints = 10, quest marked done | In-memory          |
| C.2.4 | Completes "Brush teeth"      | Same animation, +10 points                                                                     | completeQuest('quest_2')                                                                  | dailyPoints = 20                           | In-memory          |
| C.2.5 | Sees progress bar update     | Bar fills: "Aryan has done 2 out of 5 tasks" with star icons                                   | Computed from quests list                                                                 | —                                          | —                  |
| C.2.6 | Completes remaining 3 quests | Each animates, points accumulate                                                               | completeQuest() called 3 more times                                                       | dailyPoints = 50 + 50 bonus = 100          | In-memory          |
| C.2.7 | ALL QUESTS DONE              | 🎉 Reward banner: confetti burst + gold star explosion + "Amazing! You did everything! ⭐⭐⭐" | `allQuestsComplete = true` → navigate to /kids/reward                                     | allQuestsComplete = true, starRating = 5   | In-memory          |
| C.2.8 | Reward screen                | Big star animation, celebration sound, total points display                                    | KidsRewardScreen with gold_star_animation + confetti                                      | —                                          | Read state         |
| C.2.9 | Taps "Choose a Sound"        | Navigate to /kids/reward-sound                                                                 | KidsRewardSoundScreen with sound list                                                     | —                                          | —                  |

**Parent View Toggle:**

| Step   | User Action                          | UI Response                                               | System Logic                             |
| ------ | ------------------------------------ | --------------------------------------------------------- | ---------------------------------------- |
| C.2.P1 | Taps "Parent View" button (top-left) | PIN prompt (future), switches to standard adult dashboard | Theme reverts, SettingsScreen accessible |
| C.2.P2 | Views completion status              | Standard home shows which quests child completed          | Same data, different presentation        |

---

## 7. DATA FLOW DIAGRAMS

### 7.1 Reminder Creation → Alarm Fire → Confirmation

```
[AddReminderScreen]
    │ save()
    ▼
[AddReminderNotifier]
    │ validate + build Reminder model
    ▼
[ReminderRepository.insertReminder()]
    │ returns reminderId
    ▼
[ChainDao.insertEdge()] (if linked)
    │
    ▼
[AnchorResolver.resolve()] (if meal-linked)
    │ computes scheduledAt from anchor + offset
    ▼
[AlarmScheduler.schedule(reminderId, fireAt)]
    │ Android AlarmManager set
    ▼
... time passes ...
    │
[AlarmManager fires → background isolate]
    │ alarmFiredCallback(reminderId)
    ▼
[Open fresh AppDatabase in isolate]
    │ query reminder details
    ▼
[EscalationController.startEscalation()]
    │ → NotificationService.show()
    │ → FSM starts: SILENT → AUDIBLE → FULLSCREEN
    ▼
[User interacts with notification/fullscreen]
    │ DONE / SNOOZE / SKIP
    ▼
[ConfirmationDao.insertConfirmation()]
    │
    ├─ DONE → ChainEngine.evaluate(DONE) → activate children
    │         → AlarmScheduler.schedule() for each child
    │
    ├─ SNOOZE → AlarmScheduler.schedule(reminderId, now + 5min)
    │
    └─ SKIP → ChainEngine.evaluate(SKIP) → suspend all descendants
              → AlarmScheduler.cancel() for each descendant
```

### 7.2 Caregiver Alert Flow

```
[DailyScheduleNotifier._missedSub fires with new missed list]
    │ compare with previous _missed → find freshly missed
    ▼
[Read settingsRepository.getCaregiverPhone()]
    │ if null or empty → abort
    ▼
[CaregiverService.sendMissedReminderAlert()]
    │ Build WhatsApp URL: wa.me/{phone}?text={encoded_message}
    ▼
[url_launcher.launchUrl()]
    │ Opens WhatsApp (if installed) or browser fallback
    │ ⚠️ Requires internet connection
    ▼
[Message sent to caregiver's WhatsApp]
```

### 7.3 Boot Rescheduler

```
[Device reboots → BOOT_COMPLETED broadcast]
    │
    ▼
[alarm_rescheduler.dart → rescheduleAlarmsOnBoot()]
    │ Opens fresh AppDatabase in isolate
    ▼
[Query all active reminders with future scheduledAt]
    │
    ▼
[For each: AlarmScheduler.schedule(id, fireAt)]
    │ Re-arm all alarms that were lost on reboot
    ▼
[Close database]
```

---

## 8. EDGE CASES

### 8.1 Reminder Edge Cases

| Edge Case                                  | Current Behavior                                                       | Notes                                   |
| ------------------------------------------ | ---------------------------------------------------------------------- | --------------------------------------- |
| User creates reminder with no chain        | Standalone fixed-time alarm, no chain evaluation                       | Works independently                     |
| All chain children confirmed before parent | No re-fire; children stay confirmed                                    | Validation prevents this scenario       |
| Snooze limit reached (3x)                  | Auto-converts to SKIPPED, downstream suspended                         | SnoozeLimiter enforces max count        |
| Alarm fires while phone is DND             | Depends on notification channel priority (HIGH for audible/fullscreen) | Android DND exceptions configured       |
| Two reminders fire simultaneously          | Each gets independent escalation                                       | Concurrent escalation supported         |
| User reinstalls app                        | All data lost (SQLite local only)                                      | Future: cloud backup restore            |
| Device timezone changes                    | Existing alarms may fire at wrong time                                 | Known limitation: no timezone migration |

### 8.2 Chain Engine Edge Cases

| Edge Case                       | Behavior                                                   |
| ------------------------------- | ---------------------------------------------------------- |
| Circular chain (A→B→A)          | ChainValidator rejects with `ChainError.cycle` before save |
| Orphaned node (no edges)        | Treated as standalone; fires independently                 |
| Chain with 0 reminders          | Empty chain exists in DB but has no alarms                 |
| DONE on leaf node (no children) | Confirmation recorded, no downstream to activate           |
| SKIP on root node               | All descendants suspended via EAGER traversal              |

### 8.3 Fasting Edge Cases

| Edge Case                                      | Behavior                                                            |
| ---------------------------------------------- | ------------------------------------------------------------------- |
| Fasting mode enabled mid-day                   | Daytime reminders already fired; suppression applies to future only |
| Prayer time calculation for non-supported city | Hardcoded Dhaka times used as fallback                              |
| User breaks fast early                         | Manual Iftar confirmation triggers post-Iftar chain                 |
| Sehri medicine chain incomplete at Fajr        | Remaining chain items marked as missed                              |

### 8.4 Kids Mode Edge Cases

| Edge Case                          | Behavior                                                |
| ---------------------------------- | ------------------------------------------------------- |
| App restarted mid-day              | Quest progress lost (in-memory only) — known limitation |
| Child completes quest out of order | Allowed — no sequential enforcement                     |
| Parent modifies quests mid-day     | State updates immediately; completed quests stay done   |
| 100% completion triggered twice    | Reward screen can be revisited; no duplicate bonus      |

---

## 9. COMPLETION & FAILURE STATES

### 9.1 Flow Completion Conditions

| Flow                  | Complete When                                                                      |
| --------------------- | ---------------------------------------------------------------------------------- |
| Onboarding            | `onboarding_complete == true` in SharedPreferences + ≥1 chain in DB                |
| Add Reminder          | Reminder inserted in DB + alarm scheduled (or immediately resolved for past times) |
| Confirmation (DONE)   | Confirmation row in DB + downstream chain evaluated + new alarms set               |
| Confirmation (SNOOZE) | Confirmation row in DB + alarm rescheduled at snoozeUntil                          |
| Confirmation (SKIP)   | Confirmation row in DB + all descendants suspended + their alarms cancelled        |
| Escalation            | User responds at any tier OR caregiver alert sent at terminal tier                 |
| Kids Quest            | Quest.isCompleted = true + points awarded                                          |
| Full Day              | All todayReminders have a terminal confirmation (done/skipped) OR day ends         |

### 9.2 Incomplete Flow Conditions

| Flow                          | Incomplete When                         | Recovery                                    |
| ----------------------------- | --------------------------------------- | ------------------------------------------- |
| Onboarding interrupted        | App closed mid-wizard                   | Restart from page 0 on next launch          |
| Add Reminder abandoned        | User navigates away before save         | State lost (in-memory); no draft system     |
| Alarm fires, no response      | Escalation reaches fullscreen           | Caregiver WhatsApp alert sent after 20+ min |
| DB write fails                | SQLite error during insert              | Error logged, snackbar with retry           |
| Alarm not rescheduled on boot | BOOT_COMPLETED not received (some OEMs) | OEM battery guidance during onboarding      |

### 9.3 Error States & Recovery

| Error                              | Detection                    | Recovery Path                                      |
| ---------------------------------- | ---------------------------- | -------------------------------------------------- |
| Notification permission denied     | PermissionService check      | Guidance page → Settings deep link                 |
| Exact alarm permission denied      | PermissionService check      | Degrade to inexact alarms (less reliable)          |
| Battery optimization kills alarms  | OEM-specific behavior        | OEM guidance page in onboarding                    |
| Database corruption                | Drift throws on query        | App shows error screen; user can clear data        |
| WhatsApp not installed             | canLaunchUrl() returns false | URL falls back to browser (wa.me works in browser) |
| TTS initialization fails           | TTSService catches exception | Silent fallback; voice reminders disabled          |
| Background isolate DB access fails | try/catch in alarm_callback  | Confirmation lost; alarm re-fires on next cycle    |

---

## 10. COMPONENT INTERACTION MAP

```
┌─────────────┐     ┌──────────────┐     ┌───────────────┐
│ HomeScreen   │────▶│ DailySchedule│────▶│ ReminderRepo  │
│ (dashboard)  │     │ Notifier     │     │ (Drift DAO)   │
└─────────────┘     └──────────────┘     └───────────────┘
       │                    │                     │
       │                    ▼                     │
       │            ┌──────────────┐              │
       │            │ Confirmation │              │
       │            │ Notifier     │              │
       │            └──────┬───────┘              │
       │                   │                      │
       │                   ▼                      │
       │            ┌──────────────┐     ┌────────▼────────┐
       │            │ Confirmation │────▶│ ChainEngine     │
       │            │ Service      │     │ (DAG evaluator) │
       │            └──────────────┘     └────────┬────────┘
       │                                          │
       │                                          ▼
       │                                 ┌────────────────┐
       │                                 │ AlarmScheduler  │
       │                                 │ (OS integration)│
       │                                 └────────┬────────┘
       │                                          │
       ▼                                          ▼
┌──────────────┐                         ┌────────────────┐
│ Escalation   │◀────────────────────────│ AlarmCallback  │
│ Controller   │                         │ (bg isolate)   │
└──────┬───────┘                         └────────────────┘
       │
       ▼
┌──────────────┐     ┌──────────────┐
│ Notification │     │ Caregiver    │
│ Service      │     │ Service      │
└──────────────┘     └──────────────┘
```

---

## 11. TECHNOLOGY STACK

| Layer            | Technology                  | Version                |
| ---------------- | --------------------------- | ---------------------- |
| Framework        | Flutter                     | 3.x (Dart 3.10.0)      |
| State Management | Riverpod                    | 2.x (manual providers) |
| Navigation       | GoRouter                    | Latest                 |
| Database         | Drift (SQLite)              | 2.31.0                 |
| Models           | Freezed + json_serializable | Latest                 |
| Notifications    | flutter_local_notifications | Latest                 |
| Alarms           | android_alarm_manager_plus  | Latest                 |
| Audio            | just_audio                  | Latest                 |
| TTS              | flutter_tts                 | Latest                 |
| URLs             | url_launcher                | 6.3.1                  |
| Permissions      | permission_handler          | Latest                 |
| Wakelock         | wakelock_plus               | Latest                 |
| Volume           | volume_controller           | Latest                 |
| Linting          | very_good_analysis          | 10.1.0                 |
| Testing          | flutter_test + mocktail     | Built-in               |

---

## 12. IMPLEMENTATION STATUS

| Phase | Feature                                      | Status               | Tests            |
| ----- | -------------------------------------------- | -------------------- | ---------------- |
| 01    | Dependencies + Scaffold                      | ✅ Done              | ✅               |
| 02    | Models + DAOs + Repos                        | ✅ Done              | ✅               |
| 03    | Platform (Alarms, Notifications, Escalation) | ✅ Done              | ✅               |
| 04    | Chain Engine + Validation                    | ✅ Done              | ✅ TDD           |
| 05    | Anchor Resolver                              | ✅ Done              | ✅ TDD           |
| 06    | Templates + Onboarding                       | ✅ Done              | ✅               |
| 07    | Router + Core Screens                        | ✅ Done              | ✅               |
| 08    | Accessibility (TTS, Undo, Font, Semantics)   | ✅ Done              | ✅               |
| 09    | Integration Tests (Patrol)                   | ✅ Done              | ✅               |
| 10    | Design System + UI Revamp                    | ✅ Done              | ✅               |
| 11    | Kids Mode + Ramadan                          | 🔧 In Progress (50%) | Partial          |
| 12    | Chain Builder + Voice NLP                    | ❌ Not Started       | —                |
| Audit | Critical bug fixes + feature wiring          | ✅ Done              | 212 pass, 0 fail |

---

_MemoCare — Never Miss What Matters_
