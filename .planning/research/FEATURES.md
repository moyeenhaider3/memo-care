# Feature Research

**Domain:** Smart medication reminder / health reminder apps (Android)
**Researched:** 2026-03-07
**Confidence:** MEDIUM-HIGH (based on extensive competitor analysis; no live web verification available — competitor features are from training data, which is reliable for established apps but may miss very recent updates)

---

## Competitor Landscape Summary

Before categorizing features, here's what the major players actually ship:

| Feature Area                             | Medisafe     | MyTherapy | Round Health | Pill Reminder (generic) | Google Calendar |
| ---------------------------------------- | ------------ | --------- | ------------ | ----------------------- | --------------- |
| Add medications with name/dose/frequency | ✅           | ✅        | ✅           | ✅                      | ❌ (manual)     |
| Time-based notifications                 | ✅           | ✅        | ✅           | ✅                      | ✅              |
| Taken/Skipped/Snoozed confirmation       | ✅           | ✅        | ✅           | ✅ (partial)            | ❌              |
| Escalation (multiple alert tiers)        | ✅ (2 tiers) | ❌        | ❌           | ❌                      | ❌              |
| Caregiver alerts ("Medfriend")           | ✅           | ❌        | ❌           | ❌                      | ❌              |
| Drug interaction checker                 | ✅ (premium) | ❌        | ❌           | ❌                      | ❌              |
| Refill reminders                         | ✅           | ✅        | ❌           | ❌                      | ❌              |
| Adherence reports/history                | ✅           | ✅        | ✅ (basic)   | ❌                      | ❌              |
| Vitals tracking (BP, glucose)            | ✅           | ✅        | ❌           | ❌                      | ❌              |
| Meal-anchored timing                     | ❌           | ❌        | ❌           | ❌                      | ❌              |
| Linked chain logic                       | ❌           | ❌        | ❌           | ❌                      | ❌              |
| NLP/voice setup                          | ❌           | ❌        | ❌           | ❌                      | ❌              |
| Full-screen takeover alert               | ❌           | ❌        | ❌           | ❌                      | ❌              |
| Offline-first (zero network)             | Partial      | Partial   | ✅           | ✅                      | ❌              |
| Accessibility-first design               | ❌           | ❌        | ❌           | ❌                      | ❌              |
| Template packs                           | ❌           | ❌        | ❌           | ❌                      | ❌              |
| Hydration tracking                       | ❌           | ❌        | ❌           | ❌                      | ❌              |

**Key insight:** No existing app has chain logic. Meal-anchored timing, linked reminder chains, escalation stacks, and accessibility-first design for elderly users are genuinely unoccupied territory. This validates MemoCare's core thesis.

---

## Feature Landscape

### Table Stakes (Users Expect These)

These are non-negotiable for a v1 launch. Users will uninstall within 24 hours if any of these are missing or broken.

| #     | Feature                                                       | Why Expected                                                                                                                       | Complexity | Notes                                                                                                                                                                                                                                                                                                  |
| ----- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| TS-1  | **Add/edit/delete medications** (name, dose, form, frequency) | Every medication app does this. Users need to manage their meds list.                                                              | LOW        | Keep form simple: name, dose amount, dose unit (tablet/ml/drop), frequency (daily/specific days/interval). Don't over-engineer the data model — but design it to support chain linking from day 1.                                                                                                     |
| TS-2  | **Time-based notification alerts that reliably fire**         | The entire value proposition is reminding people. If notifications are late, silent, or lost, the app is worthless.                | HIGH       | This is deceptively complex on Android. Doze mode, battery optimization, OEM-specific kill behaviors (Xiaomi, Samsung, Huawei all aggressively kill background processes). Must use AlarmManager with exact alarms + foreground service fallback. **This is the #1 technical risk in the entire app.** |
| TS-3  | **Confirmation states (DONE / SNOOZED / SKIPPED)**            | Users need to record what they did. Without this, there's no tracking value — it's just an alarm clock.                            | MEDIUM     | Three states is right for v1. Action buttons directly on notification (no need to open app). Snooze needs configurable interval (5/10/15 min).                                                                                                                                                         |
| TS-4  | **Daily schedule view**                                       | Users need to see "what's coming today" at a glance. Every competitor has this.                                                    | MEDIUM     | Show timeline of today's reminders with status indicators (pending/done/skipped/missed). Must be the home screen. Elderly users need this to feel in control.                                                                                                                                          |
| TS-5  | **Multiple medications per day**                              | Real users take 3-10+ medications daily. An app that handles only one is useless.                                                  | LOW        | Data model handles this naturally. UI challenge is keeping the daily view clean with many items.                                                                                                                                                                                                       |
| TS-6  | **Persistent notifications**                                  | Medication notifications that disappear after a few seconds are dangerous — users miss them.                                       | LOW        | Use ongoing notification channel with high priority. Don't auto-dismiss. Only dismiss on user action (DONE/SKIP).                                                                                                                                                                                      |
| TS-7  | **Sound and vibration alerts**                                | Silent-only notifications are missed. Users expect audible alerts for medication.                                                  | LOW        | Use Android notification channels with configurable sound. Allow custom sounds later, but default to a distinctive, non-jarring tone.                                                                                                                                                                  |
| TS-8  | **Medication history/log**                                    | Users (and their doctors) want to see adherence over time. "Did I take my morning pill?" is a daily question for elderly users.    | MEDIUM     | Simple list: date, medication, status (taken/skipped/missed), time confirmed. Calendar heat-map is nice but not v1 — a scrollable list suffices.                                                                                                                                                       |
| TS-9  | **Offline functionality**                                     | Elderly users may have unreliable internet. Medication reminders MUST work without connectivity.                                   | MEDIUM     | Already in PROJECT.md as a constraint. All data local (SQLite/Hive). No network calls for core reminder flow. This is a strength over Medisafe which requires account creation.                                                                                                                        |
| TS-10 | **Basic onboarding flow**                                     | Users need to add at least one medication and set a time before the app provides value. An empty app with no guidance = uninstall. | MEDIUM     | PROJECT.md already specifies: condition picker → template → meal anchors → medicine entry → hydration → review. Good flow. Keep it under 3 minutes.                                                                                                                                                    |
| TS-11 | **Settings: notification preferences**                        | Users need control over alert sounds, vibration, quiet hours.                                                                      | LOW        | Basic settings screen. Don't over-build — notification channel, quiet hours toggle, snooze duration default.                                                                                                                                                                                           |

### Differentiators (Competitive Advantage)

These are where MemoCare wins. Not required by users on day 1 (they don't know to expect them), but once experienced, these become the reason users stay.

| #     | Feature                                                                                      | Value Proposition                                                                                                                                                                                                                         | Complexity | Notes                                                                                                                                                                                                                                                            |
| ----- | -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DF-1  | **Linked Reminder Chains** (anchor → pre/post triggers, confirmation-dependent firing)       | **THE core differentiator.** No competitor does this. Users with complex medication schedules (before meal, after meal, dose gaps) currently manage this manually in their heads. Automating the sequencing is a genuine 10x improvement. | HIGH       | This is the chain engine — the DAG-based task graph. Anchor events (meals, wakeup) with pre-triggers, post-triggers, conditional triggers, and skip propagation. Must be rock-solid. If this is buggy, nothing else matters.                                     |
| DF-2  | **Meal-anchored medication timing** (before-meal, after-meal, empty-stomach, dose-gap types) | Bridges the gap between "take at 1 PM" and "take 30 minutes after lunch." Real medication schedules are meal-relative, not clock-relative. No competitor models this.                                                                     | HIGH       | Tightly coupled with DF-1. Medicine types define their relationship to anchors. The Anchor Time Resolver converts "lunch ~1 PM" into precise trigger times. Meal confirmation is what fires post-meal chains.                                                    |
| DF-3  | **Escalation stack** (silent → sound+vibration → full-screen takeover)                       | Elderly users miss notifications. A single notification tier is insufficient. Progressive escalation ensures critical medications aren't missed. Medisafe has 2 tiers; MemoCare has 3 (v1) with v2 expansion to caregiver SMS.            | HIGH       | Full-screen intent is Android-specific and requires special permissions (SYSTEM_ALERT_WINDOW or USE_FULL_SCREEN_INTENT). Must handle gracefully when permission denied. Tier timing must be configurable.                                                        |
| DF-4  | **Template packs** (Diabetic Pack, BP Pack, School Morning Pack)                             | Eliminates the cold-start problem. Instead of manually adding 6 medicines one by one, user picks "I'm diabetic" and gets a pre-configured chain. Dramatically reduces setup friction for the target elderly audience.                     | MEDIUM     | 3 templates for v1 is right. Each template is a pre-built chain definition with placeholder medicine names. User customizes names/doses/times. Keep templates hardcoded in v1, don't build a template editor.                                                    |
| DF-5  | **Conversational NLP setup** (speak/type routine in Hindi+English, app parses into chain)    | The "wow" factor. Instead of navigating forms, user says "I take Paracetamol 5 min before lunch." Dramatically lowers the barrier for users who find form-based input intimidating.                                                       | VERY HIGH  | TensorFlow Lite on-device. Intent extraction: medicine name, dose, timing keyword (before/after/with), anchor event, time offset, recurrence. Hindi+English. **This is the highest-risk, highest-reward feature.** Fallback to manual entry is essential.        |
| DF-6  | **Accessibility-first design** (18pt+ text, high contrast, voice commands, TTS alerts)       | The primary audience is elderly users with reduced vision, dexterity, and tech literacy. Most health apps bolt on accessibility as an afterthought. Making it foundational is a genuine competitive advantage.                            | MEDIUM     | Not complex per feature, but requires discipline across every screen. Single-tap confirmation on alerts. Large touch targets (min 48dp, prefer 64dp). High contrast as default, not option. Voice commands for hands-free confirmation.                          |
| DF-7  | **Text-to-speech alert readout** ("Time to take Paracetamol, one tablet, before your meal")  | Elderly users may not read notifications. Hearing the reminder spoken aloud is dramatically more effective. No major competitor does this for medication alerts.                                                                          | LOW-MEDIUM | Android TTS engine is built-in. Compose the utterance from medication data: name + dose + context. Support English TTS. Hindi TTS is possible but quality varies — English-only TTS for v1 is fine since UI is English-only.                                     |
| DF-8  | **Course tracker with progress bar** (Day 3 of 7 antibiotic course)                          | Antibiotics and short courses are commonly abandoned mid-way. Visual progress ("Day 5 of 7 — almost done!") motivates completion. Simple but no competitor does it well.                                                                  | LOW        | Add start_date and course_duration_days to medication model. Progress = (today - start_date) / duration. Show progress bar on daily view and in notification. Auto-complete course when done.                                                                    |
| DF-9  | **Smart pattern detection** (suggest time adjustments based on actual behavior)              | If user consistently confirms lunch at 1:15 PM instead of 1:00 PM, the app should suggest adjusting. Reduces friction and snooze fatigue over time.                                                                                       | MEDIUM     | Requires confirmation timestamp logging (which TS-8 provides). Analysis logic: if median confirmation time for an anchor differs from set time by >10 min over 5+ days, suggest adjustment. Keep suggestions non-intrusive — a card on home screen, not a popup. |
| DF-10 | **Hydration reminders with daily counter**                                                   | Complementary to medication tracking. Elderly users and the health-conscious both value water tracking. Integrated into the same app reduces app-switching.                                                                               | LOW        | Simple interval-based reminder (every 45/60/90 min during waking hours). Daily counter with target (e.g., 8 glasses). Reset daily. Not chain-linked — independent parallel track.                                                                                |

### Anti-Features (Deliberately NOT Building in v1)

Features that seem good but would hurt MemoCare v1 by adding scope, complexity, or maintenance burden disproportionate to their value at this stage.

| #     | Feature                                                            | Why Requested                                                                     | Why Problematic for v1                                                                                                                                                                                                                   | Alternative                                                                                                                                                                 |
| ----- | ------------------------------------------------------------------ | --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AF-1  | **Caregiver/family portal** (remote monitoring, remote edit)       | Product blueprint envisions it. Real need exists. Medisafe has "Medfriend."       | Requires: user accounts, authentication, cloud backend, real-time sync, permission model, second UI surface. Doubles the app's complexity. v1 is single-user, offline-only. Adding this violates both constraints.                       | Defer to v2. v1 focuses on the single user doing it right. Caregiver can physically set up the phone during onboarding.                                                     |
| AF-2  | **Cloud sync / cross-device**                                      | Users expect data backup. What if phone is lost?                                  | Requires backend infrastructure, auth, conflict resolution. Contradicts offline-first single-user v1 scope.                                                                                                                              | Offer local backup/restore (export to file). Cloud sync in v2 when caregiver portal arrives.                                                                                |
| AF-3  | **Drug interaction checker**                                       | Medisafe has it (premium). Seems valuable for users on multiple medications.      | Requires licensed medical database (e.g., First Databank, Cerner Multum). Expensive, legally sensitive, and a massive maintenance burden. Not MemoCare's core value — chain logic is.                                                    | Don't build. Link to external resources if asked. Explicitly state: "MemoCare is a reminder app, not medical advice."                                                       |
| AF-4  | **Pill identification** (camera-based)                             | Cool tech demo. Helps users identify pills.                                       | Complex ML model, large training dataset needed, accuracy concerns with liability implications. Completely orthogonal to chain logic.                                                                                                    | Not needed. Users know what their pills look like. If needed later, integrate a third-party API in v2+.                                                                     |
| AF-5  | **Ramadan/fasting mode**                                           | In the product blueprint. Real user need for Muslim-majority markets.             | Requires prayer time calculation (location-based, date-dependent), complete chain rewiring around Sehri/Iftar anchors, daylight suspension logic. Adds significant complexity to the chain engine that is already the hardest component. | Defer to v2. v1 chain engine should be solid before adding temporal mode-switching. Users can manually set Sehri/Iftar as meal anchors as a workaround.                     |
| AF-6  | **Social/communication reminders** ("Call Mom every Sunday")       | In the product blueprint. Nice lifestyle feature.                                 | Scope creep. MemoCare's value is medication chain logic, not being a general-purpose reminder app. Social reminders dilute the core proposition and add UI complexity.                                                                   | Defer to v2. Users have Google Calendar for social reminders.                                                                                                               |
| AF-7  | **Kids dashboard with parent monitoring**                          | In the product blueprint. School Morning Pack implies kid users.                  | Requires multi-user model, permission system, child-friendly UI variant, parent dashboard. All of this is essentially a second app.                                                                                                      | Defer to v2. v1 School Morning Pack works fine as a single-user template — parent sets it up on kid's phone. No dashboard needed.                                           |
| AF-8  | **Visual timeline builder** (drag-and-drop)                        | In the product blueprint. Appealing for caregivers setting up chains.             | Complex UI component (drag-and-drop, visual linking, zoom/pan). Huge development effort for a feature used once during setup. Templates + NLP + manual forms cover the same need more efficiently.                                       | Defer to v2. Templates and conversational setup are the v1 setup mechanisms.                                                                                                |
| AF-9  | **Gamification** (streaks, badges, rewards)                        | Popular in health apps. MyTherapy has "wellbeing score." Drives engagement.       | Elderly primary audience may find gamification patronizing or confusing. Adds UI complexity. Can be added later without architectural changes.                                                                                           | Defer. If added later, keep subtle — a simple streak counter on the home screen, not badges and leaderboards.                                                               |
| AF-10 | **Vitals logging** (weight, BP readings, blood sugar, temperature) | In the product blueprint. Pairs well with medication tracking.                    | Separate data model, input UI, history/charting, trend analysis. Not core to the chain logic value proposition. Adds significant scope.                                                                                                  | Defer to v1.x or v2. Focus v1 on reminders, not data logging. Vitals tracking is a feature category that quickly becomes its own app.                                       |
| AF-11 | **Refill reminders**                                               | Medisafe and MyTherapy have them. Users run out of pills.                         | Requires tracking pill count (inventory), pharmacy info, refill lead time calculation. Adds data entry burden to every medication.                                                                                                       | Defer. Users can set a simple fixed-time reminder manually if needed. Not worth the data model complexity in v1.                                                            |
| AF-12 | **Multilingual UI**                                                | Product blueprint mentions Urdu, Hindi, Tamil, Arabic. Huge market need in India. | i18n is best done early architecturally (string externalization) but the translation effort and RTL support for Urdu/Arabic is significant.                                                                                              | Externalize all strings from day 1 (use Flutter's `intl` package). Ship v1 in English only. Add Hindi UI in v1.x. This is an architecture decision, not a feature decision. |
| AF-13 | **Caregiver SMS / auto-call escalation**                           | In the product blueprint (escalation layers 4 and 5).                             | Requires telephony permissions, SMS gateway integration (cost), voice call APIs. Legally sensitive in many jurisdictions. Massive scope increase.                                                                                        | v1 escalation stops at full-screen takeover (layer 3). Layers 4-5 are v2 with caregiver portal.                                                                             |

---

## Feature Dependencies

```
[Medication Data Model (TS-1)]
    ├──requires──> [Local Storage Engine (TS-9)]
    ├──enables───> [Daily Schedule View (TS-4)]
    ├──enables───> [Medication History (TS-8)]
    └──enables───> [Course Tracker (DF-8)]

[Notification Engine (TS-2)]
    ├──requires──> [Medication Data Model (TS-1)]
    ├──enables───> [Confirmation States (TS-3)]
    ├──enables───> [Persistent Notifications (TS-6)]
    ├──enables───> [Sound/Vibration (TS-7)]
    └──enables───> [Escalation Stack (DF-3)]

[Chain Engine (DF-1)]
    ├──requires──> [Notification Engine (TS-2)]
    ├──requires──> [Confirmation States (TS-3)]
    ├──requires──> [Medication Data Model (TS-1)]
    └──enables───> [Meal-Anchored Timing (DF-2)]

[Meal-Anchored Timing (DF-2)]
    └──requires──> [Chain Engine (DF-1)]

[Escalation Stack (DF-3)]
    └──requires──> [Notification Engine (TS-2)]

[Template Packs (DF-4)]
    ├──requires──> [Chain Engine (DF-1)]
    └──requires──> [Onboarding Flow (TS-10)]

[Conversational NLP Setup (DF-5)]
    ├──requires──> [Chain Engine (DF-1)]
    ├──requires──> [Medication Data Model (TS-1)]
    └──enhances──> [Onboarding Flow (TS-10)]

[Accessibility Features (DF-6)]
    └──parallel───> [All UI Components] (not a dependency — a cross-cutting concern)

[TTS Alert Readout (DF-7)]
    └──requires──> [Notification Engine (TS-2)]

[Smart Pattern Detection (DF-9)]
    └──requires──> [Medication History (TS-8)]

[Hydration Reminders (DF-10)]
    └──requires──> [Notification Engine (TS-2)]
    (independent of chain engine — parallel track)
```

### Dependency Notes

- **Chain Engine (DF-1) requires Notification Engine (TS-2) + Confirmation States (TS-3):** The chain engine's entire value is that confirming step N schedules step N+1. Without reliable notifications and confirmation capture, the chain engine has nothing to orchestrate.
- **Meal-Anchored Timing (DF-2) requires Chain Engine (DF-1):** Meal anchoring IS chain logic — "take pill 30 min after meal confirmation" is a post-trigger in a chain. These are not separable.
- **Template Packs (DF-4) require Chain Engine (DF-1):** Templates are pre-built chain definitions. They instantiate chains. Without the chain engine, templates are just lists of independent alarms.
- **NLP Setup (DF-5) requires Chain Engine (DF-1):** NLP output is a structured chain definition. The parser's job is to convert natural language into chain nodes. Without the chain engine, NLP has nowhere to output to.
- **Smart Pattern Detection (DF-9) requires Medication History (TS-8):** Pattern detection analyzes historical confirmation timestamps. Need several days of history before patterns emerge.
- **Hydration (DF-10) is independent:** Simple interval-based reminders with counter. No chain logic needed. Can be built in parallel.
- **Accessibility (DF-6) is cross-cutting:** Not a feature to "add" — it's a quality attribute of every screen and interaction. Must be baked into UI development from day 1, not bolted on later.

### Critical Build Order Implication

The dependency graph reveals a clear critical path:

```
Storage → Data Model → Notification Engine → Confirmation States → Chain Engine → Meal Anchoring → Templates
                                                                                                  → NLP Setup
```

Everything flows through the chain engine. It is the architectural spine. Build and validate it early.

---

## MVP Definition

### Launch With (v1.0 — "Chain Engine Works")

The minimum viable product that validates the core thesis: linked chains are better than disconnected alarms.

- [x] **Medication data model** (TS-1) — Foundation for everything
- [x] **Reliable notification engine** (TS-2) — Without this, app is useless. Includes handling Doze, battery optimization, OEM kill behaviors
- [x] **DONE / SNOOZED / SKIPPED confirmation** (TS-3) — Core interaction model
- [x] **Daily schedule view** (TS-4) — Home screen showing today's chain
- [x] **Persistent notifications with sound/vibration** (TS-6, TS-7) — Basic alert reliability
- [x] **Linked Reminder Chain engine** (DF-1) — THE differentiator. Anchor events, pre/post triggers, confirmation-dependent firing, skip propagation
- [x] **Meal-anchored medication timing** (DF-2) — Before-meal, after-meal, empty-stomach, fixed-time, dose-gap types
- [x] **Escalation stack** (DF-3) — Silent → sound+vibration → full-screen takeover
- [x] **3 template packs** (DF-4) — Diabetic, BP, School Morning. Cold-start solution
- [x] **Onboarding flow** (TS-10) — Condition → template → anchors → medicines → review
- [x] **Medication history log** (TS-8) — Simple list of what was taken/skipped/missed
- [x] **Accessibility-first UI** (DF-6) — 18pt+ text, high contrast, large touch targets, single-tap confirm
- [x] **TTS alert readout** (DF-7) — Read medication name and instruction aloud
- [x] **Offline-first storage** (TS-9) — All data local, zero network dependency
- [x] **Basic settings** (TS-11) — Notification preferences, snooze defaults

### Add After Validation (v1.x — "Polish and Expand")

Features to add once chain engine is proven and users validate the concept.

- [ ] **Conversational NLP setup** (DF-5) — Trigger: users struggle with form-based input or we want the "wow factor" for marketing. HIGH effort, HIGH reward.
- [ ] **Hydration reminders with daily counter** (DF-10) — Trigger: users request it. LOW effort, easy win.
- [ ] **Course tracker with progress bar** (DF-8) — Trigger: users on antibiotic courses want completion tracking. LOW effort.
- [ ] **Smart pattern detection** (DF-9) — Trigger: enough usage data exists (2+ weeks per user). MEDIUM effort.
- [ ] **Voice command support** — Trigger: accessibility feedback from elderly users shows hands-free confirmation is needed. MEDIUM effort.
- [ ] **String externalization for i18n** — Trigger: preparing for Hindi UI. LOW effort if done early (should arguably be in v1 architecture).

### Future Consideration (v2+)

Features to defer until product-market fit is established.

- [ ] **Caregiver/family portal** — Requires cloud backend, auth, permission model. Only when single-user is proven.
- [ ] **Ramadan/fasting mode** — Complex chain rewiring. Only when chain engine is battle-tested.
- [ ] **Social/communication reminders** — Scope expansion beyond medication focus.
- [ ] **Kids dashboard** — Multi-user model required.
- [ ] **Visual timeline builder** — Complex UI, low frequency of use.
- [ ] **Vitals tracking** — Separate product category.
- [ ] **Cloud sync** — When caregiver portal arrives.
- [ ] **Caregiver SMS / auto-call** — When caregiver portal arrives.

---

## Feature Prioritization Matrix

| Feature                         | User Value | Implementation Cost | Technical Risk                    | Priority                           |
| ------------------------------- | ---------- | ------------------- | --------------------------------- | ---------------------------------- |
| Reliable notifications (TS-2)   | HIGH       | HIGH                | **VERY HIGH** (OEM fragmentation) | **P0** — Ship-blocker              |
| Chain engine (DF-1)             | HIGH       | HIGH                | HIGH                              | **P0** — Core differentiator       |
| Meal-anchored timing (DF-2)     | HIGH       | HIGH                | MEDIUM                            | **P0** — Inseparable from chains   |
| Confirmation states (TS-3)      | HIGH       | LOW                 | LOW                               | **P1** — Essential interaction     |
| Medication data model (TS-1)    | HIGH       | LOW                 | LOW                               | **P1** — Foundation                |
| Daily schedule view (TS-4)      | HIGH       | MEDIUM              | LOW                               | **P1** — Primary UI                |
| Escalation stack (DF-3)         | HIGH       | MEDIUM              | MEDIUM                            | **P1** — Key differentiator        |
| Template packs (DF-4)           | HIGH       | LOW                 | LOW                               | **P1** — Onboarding enabler        |
| Onboarding flow (TS-10)         | HIGH       | MEDIUM              | LOW                               | **P1** — First-run experience      |
| Accessibility-first UI (DF-6)   | HIGH       | MEDIUM              | LOW                               | **P1** — Primary audience need     |
| TTS readout (DF-7)              | MEDIUM     | LOW                 | LOW                               | **P1** — Accessibility complement  |
| Offline storage (TS-9)          | HIGH       | LOW                 | LOW                               | **P1** — Constraint                |
| Medication history (TS-8)       | MEDIUM     | LOW                 | LOW                               | **P1** — Adherence tracking        |
| Persistent notifications (TS-6) | HIGH       | LOW                 | LOW                               | **P1** — Reliability               |
| Sound/vibration (TS-7)          | HIGH       | LOW                 | LOW                               | **P1** — Reliability               |
| Settings (TS-11)                | MEDIUM     | LOW                 | LOW                               | **P2** — Can ship minimal          |
| Hydration reminders (DF-10)     | MEDIUM     | LOW                 | LOW                               | **P2** — Easy addition             |
| Course tracker (DF-8)           | MEDIUM     | LOW                 | LOW                               | **P2** — Easy addition             |
| NLP setup (DF-5)                | HIGH       | VERY HIGH           | **VERY HIGH**                     | **P2** — High risk, defer to v1.x  |
| Smart pattern detection (DF-9)  | MEDIUM     | MEDIUM              | MEDIUM                            | **P2** — Needs usage data          |
| Voice commands                  | MEDIUM     | MEDIUM              | MEDIUM                            | **P2** — Accessibility enhancement |

**Priority key:**

- **P0:** Architectural spine — must build first and build right. Ship-blocking.
- **P1:** Must have for launch. App is incomplete without these.
- **P2:** Should have, add when possible. Can ship v1.0 without these and add in v1.x.
- **P3:** Nice to have, future consideration. (All P3s are in the anti-features list above.)

---

## Competitor Feature Analysis (Detailed)

| Feature                    | Medisafe                                                    | MyTherapy                           | Round Health                            | MemoCare (v1 plan)                                                                                                  |
| -------------------------- | ----------------------------------------------------------- | ----------------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Setup flow**             | Form-based, step-by-step. Add one medication at a time.     | Similar form-based.                 | Minimal — just name + time.             | Templates for common conditions + form-based entry. NLP in v1.x. Fastest setup in the category.                     |
| **Timing model**           | Fixed time ("take at 8 AM"). Interval ("every 6 hours").    | Fixed time only.                    | Fixed time only.                        | **Anchor-relative** ("30 min after lunch"). Fixed time. Dose gap. Empty stomach. Most expressive model in category. |
| **Chain/dependency logic** | None. Each reminder is independent.                         | None.                               | None.                                   | **Full DAG-based chains.** Confirming step N fires step N+1. Skipping propagates downstream. **Unique in market.**  |
| **Notifications**          | Standard Android notification. Optional repeated alert.     | Standard notification.              | Standard notification (elegant design). | **3-tier escalation.** Silent → sound+vibration → full-screen takeover. Most aggressive follow-up in category.      |
| **Confirmation UX**        | Taken / Not taken from notification.                        | Confirm from notification.          | Swipe to confirm (iOS).                 | DONE / SNOOZED / SKIPPED from notification. Large buttons. TTS readout.                                             |
| **Accessibility**          | Standard font sizes. Not accessibility-focused.             | Standard.                           | Clean but small UI.                     | **18pt+ minimum, high contrast default, TTS, voice commands, single-tap confirm.** Most accessible in category.     |
| **Offline**                | Requires account. Works offline for reminders but syncs.    | Requires account for some features. | Fully offline.                          | **Fully offline. No account. No network.** Strongest offline story in category.                                     |
| **Caregiver**              | "Medfriend" — linked accounts, missed dose alerts.          | None.                               | None.                                   | None in v1. Deferred to v2.                                                                                         |
| **Business model**         | Freemium (drug interactions, detailed reports are premium). | Free (pharma partnerships).         | Free.                                   | Free. No premium tier in v1.                                                                                        |

### Competitive Positioning Summary

MemoCare doesn't compete on breadth of features (Medisafe wins there). It competes on:

1. **Chain intelligence** — Medications understood in context of meals and each other
2. **Accessibility** — Built for elderly, not adapted for elderly
3. **Setup speed** — Templates get users running in under 3 minutes
4. **Reliability** — Offline-first, aggressive escalation, nothing gets missed

---

## Critical Implementation Notes

### The #1 Technical Risk: Android Notification Reliability

Every medication reminder app's survival depends on notifications actually firing. On Android, this is actively hostile territory:

- **Doze mode** (Android 6+): Batches alarms, delays notifications
- **App Standby Buckets** (Android 9+): Apps in "rare" bucket get severely throttled
- **Battery optimization** (all OEMs): Xiaomi (MIUI), Samsung (One UI), Huawei (EMUI), OnePlus (OxygenOS) all have aggressive background process killers that go beyond stock Android
- **Exact alarm permission** (Android 12+): `SCHEDULE_EXACT_ALARM` requires user grant or `USE_EXACT_ALARM` (for alarm/timer/calendar apps)

**MemoCare MUST:**

1. Use `AlarmManager.setExactAndAllowWhileIdle()` for critical medication reminders
2. Guide users through disabling battery optimization for the app during onboarding
3. Handle OEM-specific battery killer settings (link to https://dontkillmyapp.com patterns)
4. Use a foreground service as fallback for escalation timers
5. Test extensively on Xiaomi, Samsung, and Huawei devices (the biggest Android OEMs in India)

### The #2 Technical Risk: NLP On-Device

TensorFlow Lite for natural language intent parsing in Hindi+English is ambitious:

- Model must be <50MB to ship in APK
- Hindi NLP models are significantly less mature than English
- Intent extraction (medicine name, timing keyword, anchor, dose) is a custom NER problem
- Training data for medication-specific Hindi utterances doesn't exist publicly

**Recommendation:** Defer NLP to v1.x (it's marked P2 above). Ship v1 with templates + forms. This lets the chain engine prove its value without the NLP risk. When NLP is added, start with English-only and add Hindi incrementally.

### Architecture Decision: String Externalization

Even though multilingual UI is out of scope for v1, **externalize all user-facing strings from day 1.** Using Flutter's `intl` package or `easy_localization` is trivial at project start and extremely expensive to retrofit. This is an architecture decision, not a feature decision.

---

## Sources

- **Competitor analysis:** Based on publicly available feature sets of Medisafe, MyTherapy, Round Health, and generic pill reminder apps. Confidence: MEDIUM-HIGH (training data for established apps is reliable, but very recent feature additions may be missed).
- **Android notification reliability:** Based on Android developer documentation for AlarmManager, WorkManager, Doze mode, and App Standby Buckets. dontkillmyapp.com for OEM-specific behaviors. Confidence: HIGH (well-documented, persistent problem).
- **Product Blueprint:** MemoCare_Product_Blueprint.docx in project `/docs/` directory — comprehensive feature vision document. Used as primary source for planned feature set.
- **PROJECT.md:** v1 scope definition with validated/active/out-of-scope categorization.

---

## MVP Scope Adjustment Recommendation

The PROJECT.md lists 13 active requirements. That's a lot for v1. Based on this feature analysis, I recommend:

**Keep in v1.0 (ship-critical):**

- Chain engine + anchor events + meal-anchored timing (DF-1, DF-2)
- All 5 medicine types (before-meal, after-meal, empty-stomach, fixed-time, dose-gap)
- DONE/SNOOZED/SKIPPED confirmation (TS-3)
- Escalation stack: 3 tiers (DF-3)
- 3 template packs (DF-4)
- Daily schedule view + medication history (TS-4, TS-8)
- Accessibility-first UI + TTS readout (DF-6, DF-7)
- Offline-first storage (TS-9)
- Onboarding flow (TS-10)

**Move to v1.1 (post-launch, quick additions):**

- Hydration reminders with daily counter (DF-10) — LOW complexity, not chain-dependent
- Course tracker with progress bar (DF-8) — LOW complexity addition to data model
- Voice command support — MEDIUM complexity, can iterate based on accessibility feedback

**Move to v1.2 (needs research + iteration):**

- Conversational NLP setup (DF-5) — VERY HIGH risk, needs dedicated research phase
- Smart pattern detection (DF-9) — Needs accumulated usage data anyway

**Rationale:** This reduces v1.0 to the chain engine + essential surrounding features. Ship it, validate that chains work for real users, then layer on hydration/course tracking (easy wins) and NLP (hard but impactful).

---

_Feature research for: Smart medication reminder / health reminder apps_
_Researched: 2026-03-07_
