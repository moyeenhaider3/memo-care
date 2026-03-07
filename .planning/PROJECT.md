# MemoCare

## What This Is

MemoCare is a context-aware, chain-triggered smart reminder app for Android. It helps users (primarily elderly, but also young professionals and students) manage medication schedules, meals, hydration, and daily routines through Linked Reminder Chains — where completing one step automatically triggers the next. Unlike generic alarm apps, MemoCare understands task relationships: a pill reminder is linked to whether the user has eaten, and confirming a meal cascades into the correct medicine timing.

## Core Value

**Linked Reminder Chains that fire based on user confirmation, not just clock time.** If everything else fails, the chain engine — where confirming step N schedules step N+1 — must work reliably offline on Android.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Linked Reminder Chain engine with anchor events, pre/post/conditional/escalation/skip triggers
- [ ] Before-meal, after-meal, empty-stomach, fixed-time, and dose-gap medicine reminder types
- [ ] Three confirmation states: DONE (fires next in chain), SNOOZED (re-fires in N min), SKIPPED (suspends downstream)
- [ ] Escalation stack: silent notification → sound+vibration → full-screen takeover with loud ringtone
- [ ] Hydration reminders with configurable interval and daily glass counter
- [ ] Conversational setup via on-device NLP (TensorFlow Lite) — user speaks/types routine in Hindi or English, app parses into structured chain (all UI in English)
- [ ] 3 built-in template packs: Diabetic Pack, Blood Pressure Pack, School Morning Pack
- [ ] Guided onboarding: condition picker → template suggestion → meal anchor setup → medicine entry (template or NLP) → hydration → day review
- [ ] Large-text (18pt+ min), high-contrast, accessibility-first UI
- [ ] Voice command support for confirming/snoozing reminders
- [ ] Text-to-speech alert readout ("Time to take Paracetamol, one tablet, before your meal")
- [ ] Offline-first: all data and reminders local on device (SQLite or Hive), no network dependency
- [ ] Course tracker with progress bar (e.g., Day 3 of 7 antibiotic course)
- [ ] Smart pattern detection: suggest anchor time adjustments when user consistently confirms at different times

### Out of Scope

- Caregiver/family portal (remote monitoring, remote edit) — deferred to v2, single-user only for v1
- Caregiver SMS alerts / auto-call escalation — requires third-party services, v2
- Ramadan/fasting mode — complex rewiring of chains around Sehri/Iftar, deferred to v2
- Social/communication reminders (call relatives, appointments) — v2
- iOS, web, desktop support — Android-only for v1
- Cloud backend / cross-device sync — offline-only for v1
- Kids dashboard with parent monitoring — requires multi-user, v2
- Visual timeline builder (drag-and-drop) — v2, template + NLP is sufficient for v1
- OAuth / multi-auth methods — not needed for single-user local app
- Multilingual UI — English-only UI for v1 (NLP input accepts Hindi + English)

## Context

- **Origin:** Built to solve a real family member's medication routine falling through the cracks — multiple medicines with complex timing relationships (before/after meals, dose gaps) that generic alarm apps can't handle
- **Tech stack:** Flutter (Dart) for Android, existing fresh scaffold in place
- **Local storage:** SQLite or Hive for all reminder data, chain definitions, confirmation history
- **NLP engine:** TensorFlow Lite for on-device natural language parsing of Hindi and English input into structured reminder chains
- **Notification system:** Android-native — WorkManager + AlarmManager for reliable offline scheduling, full-screen intent for critical escalation alerts
- **Architecture:** DAG-based chain engine where each node has trigger conditions, confirmation states, and escalation rules. Anchor Time Resolver converts fuzzy input into precise scheduled times.

## Constraints

- **Platform:** Android-only for v1 — focus all effort on one platform doing it well
- **Offline:** Zero network dependency for core reminder functionality — all processing, storage, and alerts are on-device
- **NLP model size:** TensorFlow Lite model must be small enough to ship in APK without excessive bloat — target < 50MB
- **Accessibility:** All UI elements minimum 18pt text, high contrast mode, single-tap confirmation on alerts — elderly users are primary persona
- **Battery:** Chain engine and alarm scheduling must be battery-efficient — no constant polling, use Android's native scheduling APIs
- **Languages:** NLP parses Hindi + English natural language input; all UI, notifications, and output are English-only

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter for Android | Existing scaffold in place, cross-platform potential for v2 iOS | — Pending |
| TensorFlow Lite for NLP | On-device processing, no cloud dependency, supports Hindi + English | — Pending |
| SQLite/Hive for storage | Offline-first requirement, no backend needed for single-user v1 | — Pending |
| No caregiver features in v1 | Simplify scope — single user manages own reminders, caregiver deferred to v2 | — Pending |
| Escalation tops at full-screen takeover | No third-party SMS/call services — app-level notification escalation only | — Pending |
| Template + NLP for setup | Covers both quick setup (templates) and flexible setup (speak your routine) without visual builder complexity | — Pending |
| Onboarding flow: condition → template → anchors → medicines → hydration → review | Gets elderly users set up in under 3 minutes with caregiver assistance or independently | — Pending |

---
*Last updated: 2026-03-07 after initialization*
