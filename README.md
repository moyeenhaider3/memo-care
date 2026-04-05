# MemoCare

**Smart, chain-aware reminders for medication and daily routines — built for clarity, reliability, and accessibility.**

MemoCare is a [Flutter](https://flutter.dev) app (Android-focused for the current milestone) that goes beyond fixed-time alarms. It models **Linked Reminder Chains**: the next step is scheduled when you confirm the previous one, so reminders follow real life (meals, sequences, and dose gaps) instead of a flat list of clocks.

---

## What problem it solves

- **Generic alarms** fire at a time with no notion of “only after breakfast” or “30 minutes after lunch.”
- **Complex regimens** (before/after meals, spacing, sequences) are hard to express in simple calendar apps.
- **Elderly users** need large type, simple actions, and alerts that escalate instead of disappearing.
- **Family** often want a lightweight signal when something was missed — without a full remote “caregiver portal” in early releases.

MemoCare’s answer: a **DAG-based chain engine**, **meal anchors**, **DONE / SNOOZE / SKIP** confirmations, and an **escalation stack** (quiet → audible → full-screen) with optional **caregiver WhatsApp** handoff on missed reminders (see scope below).

---

## Core ideas

### Linked Reminder Chains

Reminders belong to **chains**. Edges connect a **source** reminder to a **target** reminder. When you mark a step **DONE**, the engine activates the appropriate **next** steps (lazy evaluation). When you **SKIP**, downstream reminders for that branch can be **suspended** (eager traversal). **SNOOZE** reschedules the same reminder with limits enforced by app logic.

### Anchor events

**Meal anchors** (e.g. breakfast / lunch / dinner) store default times and support resolving “X minutes before/after lunch” into concrete `scheduledAt` times.

### Confirmations

Actions are recorded (e.g. done, snoozed, skipped) and drive both **UI state** (history, compliance) and **chain progression** (what fires next).

### Escalation

If the user does not respond, reminders **escalate** through layers (e.g. silent notification → sound/vibration → full-screen takeover with large controls). Deep product and UX detail live in `docs/MemoCare_App_Blueprint.md` and `docs/MemoCare_PlayStore_Readiness_Plan.md`.

---

## Who it’s for (use cases)

| Persona | Needs | How MemoCare helps |
|--------|--------|---------------------|
| **Older adult on multiple meds** | Simple UI, loud/clear alerts, family loop | Large text / contrast, TTS-friendly flows, escalation, caregiver WhatsApp on miss (when configured) |
| **Busy professional** | Hydration, meals, vitamins, recurring tasks | Templates + manual “Build It” flows, schedule and history |
| **Child + parent** | Routine checklist, rewards | Kids Mode (gamified checklist, rewards; see implementation status in repo) |
| **Anyone with sequential care** | “After I do A, remind me of B” | Chain engine + anchors instead of unrelated alarms |

---

## Feature map (product vs implementation)

**Implemented or in active development in this repo** (feature-first under `lib/features/`):

- **Onboarding** — guided setup (profile, condition, templates, anchors, medicines, permissions, review).
- **Reminders** — CRUD, types (medicine, meal-linked, fixed time, dose gap, etc.), add flow with **Build It**; **Say It** / voice setup may be locked or “coming soon” per release plan.
- **Chain engine** — validation (e.g. cycle detection), evaluation on confirmation.
- **Daily schedule** — home dashboard, full-day timeline, hydration-style helpers where wired.
- **Escalation** — fullscreen alarm UI, audio, wakelock, notification actions.
- **History** — compliance views, weekly selection, **PDF export** (see `pdf` / `printing` in `pubspec.yaml`).
- **Templates** — library of packs (diabetes, BP, school morning, hydration, etc.).
- **Kids Mode** — dashboard, rewards, sounds (Riverpod notifiers / theme).
- **Settings** — display, notifications, caregiver phone, data-related actions.

**Scope notes (read the docs):**

- **`.planning/PROJECT.md`** — single source for *current* requirements: what is validated, in progress, or explicitly **out of scope** for v1 (e.g. no cloud backend, Android-first; fasting mode and voice/NLP called out per plan).
- **`docs/MemoCare_PlayStore_Readiness_Plan.md`** — release checklist: dependency hygiene, Android manifest expectations, UI audit, E2E scenarios, store listing. It also records **scope decisions** (e.g. simplifying caregiver to WhatsApp deep links, locking voice tab as “Coming Soon,” and removing or deferring fasting-specific product surface where applicable). **If the codebase and this plan disagree, treat the plan + `PROJECT.md` as the intended ship target** and align implementation deliberately.

**`docs/MemoCare_App_Blueprint.md`** — full architecture blueprint: module table, ER diagram, flows, Riverpod patterns, and implementation status table. Use it for deep dives.

**`docs/MemoCare_Product_Blueprint.txt`** — product vision, personas, and long-term ideas (some items are roadmap, not guaranteed in the current binary).

---

## Architecture (short)

Typical layering:

1. **Presentation** — `Material` screens, `go_router`, `AppShell` (bottom nav + FAB).
2. **Application** — `flutter_riverpod` notifiers/providers for each feature.
3. **Domain** — Freezed models, chain rules, validators.
4. **Data** — Drift (SQLite) DAOs/repositories, `shared_preferences` for settings flags.
5. **Platform** — `android_alarm_manager_plus`, `flutter_local_notifications`, `workmanager`, TTS, permissions, OEM/battery hints.

Data is **offline-first**: reminders, chains, edges, confirmations, and anchors live in SQLite; scheduling uses OS alarms and background entry points (see `lib/core/platform/`).

---

## Tech stack

| Area | Choice |
|------|--------|
| UI | Flutter |
| State | Riverpod |
| Navigation | go_router |
| Persistence | Drift + SQLite (`sqlite3_flutter_libs`) |
| Models | Freezed + json_serializable |
| Alarms / background | `android_alarm_manager_plus`, `workmanager` |
| Notifications | `flutter_local_notifications` |
| Audio / escalation | `just_audio`, `volume_controller`, `wakelock_plus` |
| Other | `permission_handler`, `url_launcher`, `flutter_tts`, `connectivity_plus`, PDF export via `pdf` + `printing` |

---

## Repository layout (high level)

```text
lib/
  app.dart                 # App root / theme wiring
  main.dart                # Initialization, notifications, alarms
  core/                    # DB, platform, router, theme, shared providers
  features/                # Feature modules (anchors, chain_engine, reminders, …)
docs/                      # Product & architecture docs (see below)
.planning/                 # PROJECT, REQUIREMENTS, ROADMAP, STATE
test/                      # Unit/widget tests (accessibility, platform, …)
```

---

## Documentation index

| Document | Contents |
|----------|----------|
| [`.planning/PROJECT.md`](.planning/PROJECT.md) | Living requirements, scope, decisions |
| [`docs/MemoCare_App_Blueprint.md`](docs/MemoCare_App_Blueprint.md) | Full app architecture, schema, flows, components |
| [`docs/MemoCare_Product_Blueprint.txt`](docs/MemoCare_Product_Blueprint.txt) | Vision, personas, long-range features |
| [`docs/MemoCare_PlayStore_Readiness_Plan.md`](docs/MemoCare_PlayStore_Readiness_Plan.md) | Pre-ship verification, Android checklist, UX gates |
| [`docs/MemoCare_UI_UX_Prompts.txt`](docs/MemoCare_UI_UX_Prompts.txt) | UI/UX prompt notes for design assistance |

---

## Getting started

**Prerequisites:** Flutter SDK compatible with `pubspec.yaml` (Dart `^3.10.0`), Android toolchain for mobile builds.

```bash
cd memo_care
flutter pub get
flutter analyze
flutter test
flutter run
```

For a release build (after configuring signing in `android/`):

```bash
flutter build apk --release
# or
flutter build appbundle
```

---

## Testing

- `flutter test` — unit and widget tests under `test/`.
- Integration / device tests may use **Patrol** (`patrol` in dev_dependencies); see project scripts and CI if present.

---

## Legal & safety

MemoCare is a **scheduling and reminder tool**. It does not replace professional medical advice, diagnosis, or treatment. Always follow your clinician’s instructions for medications and care.

---

## Tagline

*MemoCare — Never Miss What Matters*
