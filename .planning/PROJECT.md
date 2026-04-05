# MemoCare

## What This Is

MemoCare is a context-aware, chain-triggered smart reminder app for Android. It helps users (primarily elderly, but also young professionals and students) manage medication schedules, meals, hydration, and daily routines through Linked Reminder Chains — where completing one step automatically triggers the next. Unlike generic alarm apps, MemoCare understands task relationships: a pill reminder is linked to whether the user has eaten, and confirming a meal cascades into the correct medicine timing.

## Core Value

**Linked Reminder Chains that fire based on user confirmation, not just clock time.** If everything else fails, the chain engine — where confirming step N schedules step N+1 — must work reliably offline on Android.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [x] Linked Reminder Chain engine with anchor events, pre/post/conditional/escalation/skip triggers
- [x] Before-meal, after-meal, empty-stomach, fixed-time, and dose-gap medicine reminder types
- [x] Three confirmation states: DONE (fires next in chain), SNOOZED (re-fires in N min), SKIPPED (suspends downstream)
- [x] Escalation stack: silent notification → sound+vibration → full-screen takeover with loud ringtone
- [x] 7 built-in template packs: Diabetic, Blood Pressure, School Morning, Hydration Booster, Heart Patient, Elderly Wellness, Eye Care
- [x] Guided onboarding: 5-slide flow (Welcome → Profile → Accessibility → Caregiver Number → All Set)
- [x] Large-text (17pt+ min, 21pt elderly mode), high-contrast, accessibility-first UI
- [x] Text-to-speech alert readout ("Time to take Paracetamol, one tablet, before your meal")
- [x] Offline-first: all data and reminders local on device (SQLite via Drift), no network dependency
- [ ] WhatsApp caregiver alert: MISSED state opens WhatsApp with pre-filled message to stored caregiver number
- [ ] Say It tab locked as "Coming Soon" with visual placeholder (no functional voice input)
- [ ] Kids Mode: purple theme, gamified task checklist, rewards, PIN-gated parent view

### Out of Scope

- Caregiver/family portal (remote monitoring, remote edit) — deferred to v2, single-user only for v1
- Caregiver SMS alerts / auto-call escalation — requires third-party services, v2
- **Ramadan/fasting mode — REMOVED per PlayStore Readiness Plan, permanently out of v1**
- **Voice input / NLP (Say It) — Locked as Coming Soon per PlayStore Readiness Plan**
- Social/communication reminders (call relatives, appointments) — v2
- iOS, web, desktop support — Android-only for v1
- Cloud backend / cross-device sync — offline-only for v1
- Visual timeline builder (drag-and-drop) — v2, template + form is sufficient for v1
- OAuth / multi-auth methods — not needed for single-user local app
- Multilingual UI — English-only UI for v1
- Course tracker with progress bar — v2
- Hydration reminders with daily counter — v2
- Smart pattern detection — v2

## Context

- **Origin:** Built to solve a real family member's medication routine falling through the cracks — multiple medicines with complex timing relationships (before/after meals, dose gaps) that generic alarm apps can't handle
- **Tech stack:** Flutter (Dart) for Android, existing scaffold in place
- **Local storage:** SQLite via Drift for all reminder data, chain definitions, confirmation history
- **Notification system:** Android-native — WorkManager + AlarmManager for reliable offline scheduling, full-screen intent for critical escalation alerts
- **Caregiver alert:** WhatsApp deep link via `url_launcher` — no backend, no SMS
- **Architecture:** DAG-based chain engine where each node has trigger conditions, confirmation states, and escalation rules. Anchor Time Resolver converts fuzzy input into precise scheduled times.

## Constraints

- **Platform:** Android-only for v1 — focus all effort on one platform doing it well
- **Offline:** Zero network dependency for core reminder functionality — all processing, storage, and alerts are on-device
- **Accessibility:** All UI elements minimum 17pt text (21pt elderly mode), high contrast mode, single-tap confirmation on alerts — elderly users are primary persona
- **Battery:** Chain engine and alarm scheduling must be battery-efficient — no constant polling, use Android's native scheduling APIs
- **Languages:** All UI, notifications, and output are English-only

## Key Decisions

| Decision | Rationale | Outcome |
|---|---|---|
| Flutter for Android | Existing scaffold in place, cross-platform potential for v2 iOS | ✅ Decided |
| Drift (SQLite) for storage | Offline-first requirement, no backend needed, reactive streams | ✅ Decided |
| No caregiver app in v1 | WhatsApp deep link replaces complex caregiver portal | ✅ Decided |
| Escalation tops at full-screen takeover | No third-party SMS/call services — app-level notification escalation only | ✅ Decided |
| Ramadan/Fasting removed for v1 | Reduces scope, avoids complex chain rewiring — per PlayStore plan | ✅ Decided |
| Say It locked as Coming Soon | Avoids NLP/TFLite complexity — per PlayStore plan | ✅ Decided |
| Template + manual form for setup | Covers quick setup (templates) and flexible setup (Build It) | ✅ Decided |
| Source of truth: PlayStore Readiness Plan | All scope/feature decisions governed by docs/MemoCare_PlayStore_Readiness_Plan.md | ✅ Decided |

---
*Last updated: 2026-03-28 — PlayStore Readiness Plan alignment*
