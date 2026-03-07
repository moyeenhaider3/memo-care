# Stack Research

**Domain:** Offline-first chain-triggered medication reminder app (Flutter/Android)
**Researched:** 2026-03-07
**Confidence:** HIGH — all versions verified against pub.dev on research date
**Flutter:** 3.38.2 (stable) · Dart 3.10.0 · SDK constraint `^3.10.0`

---

## Recommended Stack

### Core Technologies

| Technology                      | Version       | Purpose                  | Why Recommended                                                                                                                                                                                                                                                                             | Confidence |
| ------------------------------- | ------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| **Flutter**                     | 3.38.2 stable | App framework            | Already scaffolded, existing Dart 3.10 SDK. Android-only for v1 but cross-platform optionality for v2.                                                                                                                                                                                      | HIGH       |
| **Dart**                        | 3.10.0        | Language                 | Null safety, sealed classes, pattern matching — ideal for chain engine state modeling.                                                                                                                                                                                                      | HIGH       |
| **Drift**                       | ^2.32.0       | Local database (SQLite)  | Type-safe SQL with reactive streams, schema migrations, complex relational queries. The chain engine's DAG structure (nodes, edges, trigger conditions) is inherently relational. Drift compiles SQL at build time, catches schema errors early. Published 2026-02-28, actively maintained. | HIGH       |
| **sqlite3**                     | ^3.1.6        | SQLite native bindings   | Drift's native dependency. Uses Dart native assets — compiles SQLite from source during build. Replaces deprecated `sqlite3_flutter_libs` (marked EOL 2026-02-15).                                                                                                                          | HIGH       |
| **flutter_riverpod**            | ^3.2.1        | State management         | Type-safe, testable, no BuildContext dependency (critical for background isolate chain evaluation). Async providers natively handle DB streams. Code-gen API reduces boilerplate.                                                                                                           | HIGH       |
| **riverpod_annotation**         | ^4.0.2        | Riverpod code generation | Annotation-based provider declaration — `@riverpod` on functions/classes. Reduces manual provider wiring.                                                                                                                                                                                   | HIGH       |
| **flutter_local_notifications** | ^21.0.0       | Notification display     | Full-screen intent support for escalation takeover. Scheduled notifications, custom sounds, action buttons (DONE/SNOOZE/SKIP). Published 2026-03-05, requires SDK `^3.10.0` — exact match.                                                                                                  | HIGH       |
| **android_alarm_manager_plus**  | ^5.0.0        | Exact alarm scheduling   | Fires callbacks at exact times via Android's `AlarmManager.setExactAndAllowWhileIdle()`. Survives Doze mode. Essential for medication timing that can't drift.                                                                                                                              | HIGH       |
| **tflite_flutter**              | ^0.12.1       | On-device NLP inference  | TensorFlow Lite runtime for Dart. Runs intent classification + entity extraction models for Hindi/English input parsing. SDK `>=3.3.0`, compatible. Published 2025-10-28.                                                                                                                   | MEDIUM     |
| **flutter_tts**                 | ^4.2.5        | Text-to-speech           | Android TTS engine wrapper. Queue management, speech rate control, language selection. For reading aloud: "Time to take Paracetamol, one tablet, before your meal."                                                                                                                         | HIGH       |
| **speech_to_text**              | ^7.3.0        | Voice input              | Uses Android's built-in speech recognition. Supports Hindi (`hi_IN`) and English (`en_IN`) locales. For voice commands: confirm, snooze, skip.                                                                                                                                              | HIGH       |

### Data Layer & Models

| Library                | Version | Purpose                    | Why                                                                                                                                     |
| ---------------------- | ------- | -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| **drift**              | ^2.32.0 | ORM + query builder        | See above. Core data layer for chains, reminders, confirmations, courses.                                                               |
| **drift_dev**          | ^2.32.0 | Drift code generator       | Dev dependency. Generates type-safe table classes, DAOs, migration helpers.                                                             |
| **freezed**            | ^3.2.5  | Immutable data classes     | Union types for `ReminderState.done / .snoozed / .skipped`, `TriggerType.pre / .post / .conditional`. `copyWith` for state transitions. |
| **freezed_annotation** | ^3.1.0  | Freezed annotations        | Runtime annotations for freezed classes.                                                                                                |
| **json_annotation**    | ^4.11.0 | JSON serialization markers | For serializing chain definitions, template packs, NLP parse results.                                                                   |
| **json_serializable**  | ^6.13.0 | JSON code generator        | Dev dependency. Generates `fromJson`/`toJson` for transfer objects.                                                                     |

### Scheduling & Background Work

| Library                        | Version  | Purpose                   | When to Use                                                                                                                              |
| ------------------------------ | -------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **android_alarm_manager_plus** | ^5.0.0   | Exact-time alarms         | Every scheduled reminder fires through this. `setExactAndAllowWhileIdle` for medication timing.                                          |
| **workmanager**                | ^0.9.0+3 | Periodic background tasks | Daily chain recalculation, missed-dose detection, course progress updates. Not for exact timing — use for "run this logic periodically." |
| **shared_preferences**         | ^2.5.4   | Key-value settings        | User preferences: escalation timing, snooze duration, hydration interval, TTS settings, accessibility toggles.                           |

### UI & Accessibility

| Library                   | Version | Purpose            | When to Use                                                                                                  |
| ------------------------- | ------- | ------------------ | ------------------------------------------------------------------------------------------------------------ |
| **go_router**             | ^17.1.0 | Navigation/routing | Declarative routing with deep link support — notification tap → specific reminder screen.                    |
| **google_fonts**          | ^8.0.2  | Typography         | Ship accessible fonts (Noto Sans for Hindi script compatibility in input). Bundled via `assets` for offline. |
| **flutter_svg**           | ^2.2.4  | SVG rendering      | Icons, illustrations for onboarding. Vector graphics scale perfectly for accessibility zoom.                 |
| **flutter_native_splash** | ^2.4.7  | Splash screen      | Branded launch screen. Simple but polished first impression.                                                 |
| **wakelock_plus**         | ^1.4.0  | Screen wake lock   | Keep screen on during full-screen escalation alert until user confirms.                                      |

### Audio & Haptics

| Library               | Version | Purpose               | When to Use                                                                                          |
| --------------------- | ------- | --------------------- | ---------------------------------------------------------------------------------------------------- |
| **just_audio**        | ^0.10.5 | Audio playback        | Alarm ringtone playback for escalation level 3. Supports looping, volume control, asset playback.    |
| **volume_controller** | ^3.4.2  | System volume control | Override volume for critical escalation alerts — ensure alarm is audible even if phone is on silent. |

### Utilities

| Library                | Version | Purpose                | When to Use                                                                                                                                    |
| ---------------------- | ------- | ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **uuid**               | ^4.5.3  | Unique IDs             | Generate IDs for chains, reminders, confirmations. UUIDv4 for all entities.                                                                    |
| **intl**               | ^0.20.2 | Date/time formatting   | Format reminder times, course dates, relative time ("30 min after meal").                                                                      |
| **path_provider**      | ^2.1.5  | File system paths      | Locate app documents directory for TFLite model storage, audio assets.                                                                         |
| **permission_handler** | ^12.0.1 | Runtime permissions    | Request SCHEDULE_EXACT_ALARM, NOTIFICATION, MICROPHONE, SYSTEM_ALERT_WINDOW.                                                                   |
| **device_info_plus**   | ^12.3.0 | Device information     | Detect Android version for permission flow branching (Android 12+ exact alarm permissions, Android 13+ notification permissions).              |
| **equatable**          | ^2.0.8  | Value equality         | Equality for entities passed through streams and Riverpod state. Used in chain comparison and dedup.                                           |
| **fpdart**             | ^1.2.0  | Functional programming | `Either<Failure, Success>` for NLP parse results, chain validation. `Option` for nullable chain fields. Cleaner error handling than try/catch. |
| **rxdart**             | ^0.28.0 | Reactive extensions    | `combineLatest`, `debounce`, `switchMap` for combining Drift reactive queries in the chain engine. Augments Dart streams.                      |

### Development Tools

| Tool                   | Version | Purpose                | Notes                                                                                                                           |
| ---------------------- | ------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **build_runner**       | ^2.12.2 | Code generation runner | Runs drift_dev, freezed, json_serializable, riverpod_generator. Use `dart run build_runner build --delete-conflicting-outputs`. |
| **riverpod_generator** | ^4.0.3  | Riverpod code gen      | Generates providers from `@riverpod` annotations.                                                                               |
| **riverpod_lint**      | ^3.1.3  | Riverpod lint rules    | Catches common Riverpod mistakes (missing `ref.watch`, wrong provider scope).                                                   |
| **custom_lint**        | ^0.8.1  | Custom lint runner     | Required by riverpod_lint.                                                                                                      |
| **very_good_analysis** | ^10.2.0 | Lint rules             | Strict but practical lint rules from Very Good Ventures. Replace default `flutter_lints`.                                       |
| **mocktail**           | ^1.0.4  | Mocking (testing)      | No code generation needed (unlike mockito). Faster test iteration for chain engine unit tests.                                  |
| **patrol**             | ^4.3.0  | Integration testing    | Native Android interaction testing — test actual notifications, alarm behavior, permission dialogs.                             |

---

## Installation

```yaml
# pubspec.yaml
environment:
  sdk: ^3.10.0

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^3.2.1
  riverpod_annotation: ^4.0.2

  # Database
  drift: ^2.32.0
  sqlite3: ^3.1.6

  # Notifications & Scheduling
  flutter_local_notifications: ^21.0.0
  android_alarm_manager_plus: ^5.0.0
  workmanager: ^0.9.0+3

  # NLP / ML
  tflite_flutter: ^0.12.1

  # Voice & Audio
  flutter_tts: ^4.2.5
  speech_to_text: ^7.3.0
  just_audio: ^0.10.5
  volume_controller: ^3.4.2

  # Navigation & UI
  go_router: ^17.1.0
  google_fonts: ^8.0.2
  flutter_svg: ^2.2.4
  flutter_native_splash: ^2.4.7
  wakelock_plus: ^1.4.0

  # Data Models & Utilities
  freezed_annotation: ^3.1.0
  json_annotation: ^4.11.0
  uuid: ^4.5.3
  intl: ^0.20.2
  path_provider: ^2.1.5
  permission_handler: ^12.0.1
  device_info_plus: ^12.3.0
  equatable: ^2.0.8
  fpdart: ^1.2.0
  rxdart: ^0.28.0
  shared_preferences: ^2.5.4

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.12.2
  drift_dev: ^2.32.0
  freezed: ^3.2.5
  json_serializable: ^6.13.0
  riverpod_generator: ^4.0.3

  # Linting
  very_good_analysis: ^10.2.0
  riverpod_lint: ^3.1.3
  custom_lint: ^0.8.1

  # Testing
  mocktail: ^1.0.4
  patrol: ^4.3.0
```

```bash
# After updating pubspec.yaml:
flutter pub get

# Run code generation:
dart run build_runner build --delete-conflicting-outputs

# Run code generation in watch mode during development:
dart run build_runner watch --delete-conflicting-outputs
```

---

## Alternatives Considered

### Database

| Recommended        | Alternative        | Why Not                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------------ | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Drift (SQLite)** | Hive               | **Dead.** Last published 2022-06-30. SDK constraint `<3.0.0` — incompatible with Dart 3.x. Cannot use.                                                                                                                                                                                                                                                                                       |
| **Drift (SQLite)** | Hive CE            | Community fork (^2.19.3) is alive but it's a key-value store. Chain engine's DAG structure (nodes → edges → triggers → conditions) demands relational joins and complex queries. Key-value requires manual indexing and denormalization — fragile for chain validation.                                                                                                                      |
| **Drift (SQLite)** | Isar               | **Dead.** Last published 2023-04-25. SDK constraint `<3.0.0` — incompatible with Dart 3.x. Cannot use.                                                                                                                                                                                                                                                                                       |
| **Drift (SQLite)** | ObjectBox (^5.2.0) | Actively maintained NoSQL. Viable for simpler apps, but chain engine needs: (1) JOIN queries across chains/reminders/confirmations, (2) transaction-safe cascade operations when marking a chain step DONE, (3) complex WHERE clauses for "find next unconfirmed step with met trigger conditions." SQL handles this naturally; ObjectBox would require manual graph traversal in Dart code. |
| **Drift (SQLite)** | sqflite (^2.4.2)   | Raw SQL wrapper — no type safety, no reactive queries, manual migration management. Drift wraps SQLite with compile-time verification and reactive streams. sqflite is fine for simple apps; Drift is necessary for the chain engine's complexity.                                                                                                                                           |

### State Management

| Recommended    | Alternative           | When to Use Alternative                                                                                                                                                                                                                                                                                                              |
| -------------- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Riverpod 3** | flutter_bloc (^9.1.1) | Use BLoC if team has deep BLoC experience and prefers explicit event→state pattern. However: BLoC's boilerplate (Event classes, separate Bloc files) is heavy for a solo/small-team project. Riverpod's functional providers are more concise. BLoC also can't easily provide values to background isolates (WorkManager callbacks). |
| **Riverpod 3** | Provider              | Predecessor to Riverpod by the same author (Remi Rousselet). Riverpod fixes Provider's limitations: no context dependency, better testing, no runtime ProviderNotFoundExceptions. No reason to use Provider in a new 2026 project.                                                                                                   |
| **Riverpod 3** | GetX                  | **Avoid.** Anti-pattern-heavy, tightly couples state/routing/DI, makes testing difficult, community consensus is strongly against it for production apps.                                                                                                                                                                            |

### Notifications

| Recommended                     | Alternative                     | When to Use Alternative                                                                                                                                                                                                                                                         |
| ------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **flutter_local_notifications** | awesome_notifications (^0.11.0) | More feature-rich out of the box (progress bars, action buttons with payloads). But: still pre-1.0, less community adoption, heavier dependency. flutter_local_notifications is the ecosystem standard — more Stack Overflow answers, more battle-tested edge cases documented. |

### Navigation

| Recommended   | Alternative          | When to Use Alternative                                                                                                                                                                                                                                                                                                                             |
| ------------- | -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **go_router** | auto_route (^11.1.0) | Use auto_route if you prefer code-generation-based routing with type-safe route parameters. go_router is the officially recommended Flutter router, has better deep linking documentation, and is maintained by the Flutter team. For MemoCare's notification tap → specific screen flow, go_router's `redirect` + `extra` parameter is sufficient. |

### Audio

| Recommended    | Alternative           | When to Use Alternative                                                                                                                                                                                                                               |
| -------------- | --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **just_audio** | audioplayers (^6.6.0) | Both are viable. just_audio has better looping control, gapless playback, and Android audio focus handling — important for alarm ringtones that must loop until acknowledged. audioplayers is simpler but less control over audio session management. |

---

## What NOT to Use

| Avoid                            | Why                                                                                                                                                   | Use Instead                                                                         |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| **Hive / hive_flutter**          | Abandoned since 2022. SDK constraint `<3.0.0`. Will not compile with Dart 3.10.                                                                       | Drift ^2.32.0                                                                       |
| **Isar**                         | Abandoned since 2023. SDK constraint `<3.0.0`. Will not compile. Creator (Simon Leier, also Hive creator) moved on.                                   | Drift ^2.32.0                                                                       |
| **sqlite3_flutter_libs**         | Marked EOL (0.6.0+eol) as of 2026-02-15. Replaced by `sqlite3` with Dart native assets.                                                               | `sqlite3: ^3.1.6` (drift handles this dependency)                                   |
| **GetX**                         | Violates separation of concerns, couples everything, makes unit testing nearly impossible, no compile-time safety. Community consensus: anti-pattern. | Riverpod for state, go_router for navigation, get_it if you need a service locator. |
| **Provider**                     | Superseded by Riverpod (same author). Context-dependent, runtime errors for missing providers.                                                        | flutter_riverpod ^3.2.1                                                             |
| **flutter_lints**                | Ships with scaffold but is minimal.                                                                                                                   | very_good_analysis ^10.2.0 — stricter, catches more issues.                         |
| **mockito**                      | Requires code generation for each mock. Slower iteration.                                                                                             | mocktail ^1.0.4 — no codegen, same API surface.                                     |
| **dartz**                        | Last published 2021. Functional programming, but abandoned.                                                                                           | fpdart ^1.2.0 — actively maintained, Dart 3 compatible, better API.                 |
| **timezone** (for notifications) | flutter_local_notifications 21.x handles timezone internally. Adding timezone separately creates version conflicts.                                   | Let flutter_local_notifications manage its own timezone dependency.                 |

---

## Critical Android Configuration

MemoCare requires specific Android manifest permissions and configurations that go beyond `flutter pub get`. These are non-negotiable for the core features:

### Permissions Required

```xml
<!-- AndroidManifest.xml -->

<!-- Exact alarms (Android 12+) — CRITICAL for medication timing -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<!-- Android 14+ requires USE_EXACT_ALARM for health/medication apps -->
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />

<!-- Notifications (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Full-screen intent for escalation takeover -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />

<!-- Wake device for critical alerts -->
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Survive reboot — reschedule alarms after device restart -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Microphone for voice commands -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Vibration for escalation level 2 -->
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Keep foreground service for alarm playback -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### Android API Levels

| Concern                 | Minimum                          | Target                      | Why                                                                                                      |
| ----------------------- | -------------------------------- | --------------------------- | -------------------------------------------------------------------------------------------------------- |
| API Level               | 24 (Android 7.0)                 | 35 (Android 15)             | API 24 is Drift's minimum. Target 35 for Play Store compliance 2026.                                     |
| Exact Alarm             | `SCHEDULE_EXACT_ALARM` (API 31+) | `USE_EXACT_ALARM` (API 34+) | Health/medication apps qualify for `USE_EXACT_ALARM` which doesn't require user approval on Android 14+. |
| Notification Permission | Runtime request (API 33+)        | Auto-granted below API 33   | Must request at onboarding for Android 13+ devices.                                                      |
| Full-screen Intent      | Restricted (API 34+)             | Must declare in manifest    | Android 14 restricts full-screen intents; medication apps can still use them with proper declaration.    |

---

## Stack Patterns by Variant

**If NLP complexity exceeds TFLite capability (MEDIUM confidence risk):**

- Defer NLP to a later phase
- Use structured form input + template packs for v1 setup
- NLP becomes a "delighter" feature, not a blocker
- Because: TFLite model training for bilingual intent parsing is a significant ML engineering effort. The app's core value is the chain engine, not the NLP input method.

**If tflite_flutter has compatibility issues with Dart 3.10 (LOW confidence risk):**

- Fall back to platform channels calling TFLite Java API directly
- Android's native TFLite is well-documented
- Because: tflite_flutter is community-maintained (not Google-official), still at 0.12.x. The Java TFLite API is Google-maintained and guaranteed stable.

**If flutter_local_notifications full-screen intent doesn't work reliably on specific OEMs:**

- Use platform channel to invoke Android's native `FullScreenIntent` API directly
- OEM fragmentation (Xiaomi, Oppo, Vivo) often blocks notification features
- Because: Chinese OEMs have aggressive battery optimization that kills background processes. May need OEM-specific "autostart" permission guidance in onboarding.

**If WorkManager callbacks are unreliable across OEMs:**

- Rely solely on android_alarm_manager_plus for all scheduling
- Use AlarmManager for both exact-time and periodic tasks
- Because: WorkManager is a recommendation, not a hard dependency. AlarmManager with `setExactAndAllowWhileIdle` is more reliable for critical medication timing.

---

## Version Compatibility Matrix

| Package A                           | Compatible With               | Notes                                                                            |
| ----------------------------------- | ----------------------------- | -------------------------------------------------------------------------------- |
| flutter_local_notifications ^21.0.0 | SDK ^3.10.0, Flutter >=3.38.1 | **Exact match** with our project SDK. Verify after any Flutter upgrade.          |
| drift ^2.32.0                       | sqlite3 ^3.1.5                | Drift pins sqlite3 as dependency. Do not add sqlite3_flutter_libs (EOL).         |
| riverpod_annotation ^4.0.2          | riverpod_generator ^4.0.3     | Must use matching major versions. Both at v4.x.                                  |
| freezed ^3.2.5                      | freezed_annotation ^3.1.0     | Freezed 3.x requires freezed_annotation 3.x.                                     |
| tflite_flutter ^0.12.1              | Dart >=3.3.0, ffi ^2.0.1      | Compatible with Dart 3.10, but verify against Flutter 3.38 native asset changes. |
| patrol ^4.3.0                       | patrol_finders ^3.1.0         | Patrol 4.x uses separate finder package. Add both for integration tests.         |

---

## Package Count & Build Impact

| Category              | Packages | Code Gen? |
| --------------------- | -------- | --------- |
| Core runtime          | 22       | —         |
| Code generation (dev) | 5        | Yes       |
| Linting (dev)         | 3        | —         |
| Testing (dev)         | 3        | —         |
| **Total**             | **33**   | —         |

**Build time note:** 5 code generators (drift_dev, freezed, json_serializable, riverpod_generator, build_runner) will increase build times. Use `build_runner watch` during development. Expect 15-30s initial generation, 2-5s incremental.

---

## Sources

All package versions verified via `pub.dev/api/packages/{name}` on 2026-03-07:

- **drift 2.32.0** — pub.dev, published 2026-02-28 — HIGH confidence
- **sqlite3 3.1.6** — pub.dev, published 2026-02-15 — HIGH confidence
- **sqlite3_flutter_libs 0.6.0+eol** — pub.dev, marked EOL 2026-02-15 — HIGH confidence (confirmed deprecated)
- **flutter_riverpod 3.2.1** — pub.dev — HIGH confidence
- **riverpod_annotation 4.0.2 / riverpod_generator 4.0.3** — pub.dev — HIGH confidence
- **flutter_local_notifications 21.0.0** — pub.dev, published 2026-03-05, requires SDK ^3.10.0 — HIGH confidence
- **android_alarm_manager_plus 5.0.0** — pub.dev, published 2025-09-11 — HIGH confidence
- **workmanager 0.9.0+3** — pub.dev, still pre-1.0 — MEDIUM confidence (stable enough but not v1)
- **tflite_flutter 0.12.1** — pub.dev, published 2025-10-28 — MEDIUM confidence (community-maintained, pre-1.0)
- **flutter_tts 4.2.5** — pub.dev — HIGH confidence
- **speech_to_text 7.3.0** — pub.dev — HIGH confidence
- **hive 2.2.3** — pub.dev, published 2022-06-30, SDK <3.0.0 — HIGH confidence (confirmed dead)
- **isar 3.1.0+1** — pub.dev, published 2023-04-25, SDK <3.0.0 — HIGH confidence (confirmed dead)
- **hive_ce 2.19.3** — pub.dev, published 2026-02-03 — HIGH confidence (alive but wrong fit)
- **objectbox 5.2.0** — pub.dev, published 2026-01-28 — HIGH confidence (alive but wrong fit)
- **Flutter 3.38.2 / Dart 3.10.0** — verified via `flutter --version` on build machine — HIGH confidence

---

_Stack research for: MemoCare — offline-first chain-triggered medication reminder (Flutter/Android)_
_Researched: 2026-03-07_
