# ARCHITECTURE.md — MemoCare

| Field      | Value                                                                     |
| ---------- | ------------------------------------------------------------------------- |
| Domain     | Offline-first medication reminder (Android/Flutter)                       |
| Date       | 2026-03-07                                                                |
| Confidence | HIGH — patterns validated against Drift, Riverpod, and Android alarm APIs |

---

## 1. System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                         │
│  Screens · Widgets · GoRouter · Accessibility (18pt+, TTS)     │
├─────────────────────────────────────────────────────────────────┤
│                  APPLICATION / STATE LAYER                     │
│  Riverpod Providers · AsyncNotifiers · StreamProviders         │
│  ┌──────────────┐ ┌───────────────┐ ┌────────────────────┐    │
│  │ ChainNotifier│ │ReminderNotif. │ │ TemplateNotifier   │    │
│  └──────┬───────┘ └──────┬────────┘ └────────┬───────────┘    │
├─────────┼────────────────┼───────────────────┼─────────────────┤
│         │        DOMAIN LAYER (pure Dart)     │                │
│  ┌──────▼───────┐ ┌──────▼────────┐ ┌────────▼───────────┐    │
│  │ Chain Engine │ │Anchor Resolver│ │ Escalation FSM     │    │
│  │  (DAG eval)  │ │ (time calc)   │ │ (SILENT→FULL)      │    │
│  └──────┬───────┘ └──────┬────────┘ └────────┬───────────┘    │
│         │                │                    │                │
│  ┌──────▼────────────────▼────────────────────▼───────────┐    │
│  │              Domain Models (Freezed)                    │    │
│  │  ReminderChain · Reminder · Confirmation · Anchor       │    │
│  └─────────────────────────┬──────────────────────────────┘    │
├─────────────────────────────┼──────────────────────────────────┤
│                    DATA LAYER                                  │
│  ┌──────────┐ ┌────────────▼──────────┐ ┌─────────────────┐   │
│  │ ChainDao │ │    ReminderDao        │ │ ConfirmationDao │   │
│  └────┬─────┘ └────────────┬──────────┘ └────────┬────────┘   │
│       └────────────────────┼─────────────────────┘            │
│                    ┌───────▼────────┐                          │
│                    │  Drift DB      │                          │
│                    │  (SQLite)      │                          │
│                    └───────┬────────┘                          │
├─────────────────────────────┼──────────────────────────────────┤
│                 PLATFORM SERVICES LAYER                        │
│  ┌──────────────┐ ┌────────▼───────┐ ┌────────────────────┐   │
│  │ AlarmService │ │NotificationSvc │ │ TTSService         │   │
│  │ (exact alarm)│ │(local notif.)  │ │ (flutter_tts)      │   │
│  └──────────────┘ └────────────────┘ └────────────────────┘   │
│  android_alarm_manager  flutter_local_notifications            │
└─────────────────────────────────────────────────────────────────┘
```

The domain layer is **pure Dart** — no Flutter imports. This enables:

- Unit-testing without widget test harness
- Running chain evaluation inside a Dart isolate for background processing
- Sharing logic between `workmanager` background tasks and foreground UI

---

## 2. Component Responsibilities

| Component           | Responsibility                                                       | Key Dependency              |
| ------------------- | -------------------------------------------------------------------- | --------------------------- |
| **ChainEngine**     | Evaluate DAG edges, fire next node on DONE, suspend on SKIP          | Pure Dart, fpdart           |
| **AnchorResolver**  | Convert fuzzy anchors ("after lunch") to DateTime; recalc dependents | Pure Dart                   |
| **EscalationFSM**   | Drive SILENT → AUDIBLE → FULLSCREEN per reminder                     | Pure Dart, rxdart           |
| **ChainDao**        | CRUD for `reminder_chains`, `chain_edges` tables                     | Drift                       |
| **ReminderDao**     | CRUD for `reminders`, `reminder_schedules`; reactive streams         | Drift                       |
| **ConfirmationDao** | Log confirmations (DONE/SNOOZED/SKIPPED) with timestamps             | Drift                       |
| **AlarmScheduler**  | Schedule/cancel exact Android alarms via platform channel            | android_alarm_manager_plus  |
| **NotificationSvc** | Build and display tiered notifications (silent, sound, fullscreen)   | flutter_local_notifications |
| **TemplateService** | Load/apply template packs (Diabetic, BP, School Morning)             | Pure Dart + Drift           |
| **OnboardingOrch.** | Orchestrate onboarding flow: condition→template→anchors→meds→review  | Riverpod, GoRouter          |
| **TTSService**      | Read reminder text aloud, respect user language/speed prefs          | flutter_tts                 |
| **VoiceCommandSvc** | Parse spoken confirmations ("done", "skip", "snooze 10 min")         | speech_to_text              |

---

## 3. Recommended Project Structure

```
lib/
├── app.dart                          # MaterialApp, GoRouter setup
├── main.dart                         # bootstrap, ProviderScope
│
├── core/                             # Shared infrastructure
│   ├── database/
│   │   ├── app_database.dart         # Drift @DriftDatabase definition
│   │   ├── app_database.g.dart
│   │   └── type_converters.dart      # TimeOfDay, Duration, enum converters
│   ├── extensions/
│   │   ├── datetime_ext.dart
│   │   └── either_ext.dart           # fpdart helpers
│   ├── platform/
│   │   ├── alarm_scheduler.dart      # android_alarm_manager_plus wrapper
│   │   ├── notification_service.dart # flutter_local_notifications wrapper
│   │   └── tts_service.dart
│   ├── constants/
│   │   ├── durations.dart            # snooze defaults, escalation intervals
│   │   └── medicine_types.dart
│   └── providers/
│       └── database_provider.dart    # Riverpod provider for AppDatabase
│
├── features/
│   ├── chain_engine/                 # DAG-based chain evaluation
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── reminder_chain.dart       # @freezed
│   │   │   │   ├── chain_edge.dart           # @freezed
│   │   │   │   └── chain_eval_result.dart    # @freezed Either<ChainError, List<Reminder>>
│   │   │   ├── chain_engine.dart             # Pure Dart DAG evaluator
│   │   │   └── chain_validator.dart          # Cycle detection, orphan check
│   │   ├── data/
│   │   │   ├── chain_dao.dart                # Drift DAO
│   │   │   └── chain_repository.dart
│   │   └── application/
│   │       └── chain_notifier.dart           # AsyncNotifier
│   │
│   ├── reminders/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── reminder.dart             # @freezed
│   │   │   │   ├── reminder_schedule.dart
│   │   │   │   └── medicine_type.dart        # enum: beforeMeal, afterMeal, etc.
│   │   │   └── reminder_service.dart
│   │   ├── data/
│   │   │   ├── reminder_dao.dart
│   │   │   └── reminder_repository.dart
│   │   ├── application/
│   │   │   ├── reminder_list_notifier.dart
│   │   │   └── providers.dart
│   │   └── presentation/
│   │       ├── reminder_list_screen.dart
│   │       └── widgets/
│   │
│   ├── confirmation/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── confirmation.dart         # @freezed
│   │   │   │   └── confirmation_state.dart   # enum: done, snoozed, skipped
│   │   │   └── confirmation_service.dart     # Triggers chain engine on state change
│   │   ├── data/
│   │   │   ├── confirmation_dao.dart
│   │   │   └── confirmation_repository.dart
│   │   └── application/
│   │       └── confirmation_notifier.dart
│   │
│   ├── anchors/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── meal_anchor.dart          # @freezed: breakfast, lunch, dinner
│   │   │   │   └── anchor_config.dart
│   │   │   └── anchor_resolver.dart          # Recalculates downstream times
│   │   ├── data/
│   │   │   └── anchor_repository.dart
│   │   └── application/
│   │       └── anchor_notifier.dart
│   │
│   ├── escalation/
│   │   ├── domain/
│   │   │   ├── escalation_fsm.dart           # State machine
│   │   │   └── escalation_level.dart         # enum: silent, audible, fullscreen
│   │   └── application/
│   │       └── escalation_controller.dart
│   │
│   ├── templates/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── template_pack.dart
│   │   │   └── template_service.dart
│   │   ├── data/
│   │   │   └── template_repository.dart
│   │   └── presentation/
│   │       └── template_picker_screen.dart
│   │
│   ├── onboarding/
│   │   ├── presentation/
│   │   │   ├── onboarding_flow.dart
│   │   │   ├── condition_step.dart
│   │   │   ├── anchor_step.dart
│   │   │   ├── medicine_step.dart
│   │   │   └── review_step.dart
│   │   └── application/
│   │       └── onboarding_notifier.dart
│   │
│   └── nlp/                                  # Deferred to v1.x
│       └── domain/
│           └── nlp_parser.dart               # TFLite Hindi+English stub
│
└── l10n/                                     # Localization (Hindi + English)
    ├── app_en.arb
    └── app_hi.arb
```

**Rationale:** Feature-first at the top level keeps each bounded context cohesive. The inner layered structure (domain → data → application → presentation) enforces the dependency rule: domain has zero Flutter imports, data depends on domain, application bridges both via Riverpod.

---

## 4. Architectural Patterns

### 4.1 Chain Engine — DAG Pattern

Each medicine regimen is a **directed acyclic graph** where confirming node N activates the edges leaving N:

```
  Wake-up Pill (empty-stomach)
       │ DONE
       ▼
  ┌─── Breakfast Anchor ───┐
  │                        │
  ▼                        ▼
Before-meal Med       After-meal Med
  │ DONE                   │ DONE
  └────────┐   ┌───────────┘
           ▼   ▼
     Mid-morning Hydration
```

```dart
/// Pure Dart — no Flutter imports.
class ChainEngine {
  /// Given a confirmed reminder, returns the list of reminders to activate.
  Either<ChainError, List<Reminder>> evaluate({
    required ReminderChain chain,
    required ReminderId confirmedId,
    required ConfirmationState state,
  }) {
    return switch (state) {
      ConfirmationState.done => _activateDownstream(chain, confirmedId),
      ConfirmationState.snoozed => right([chain.reminderById(confirmedId)]),
      ConfirmationState.skipped => _suspendDownstream(chain, confirmedId),
    };
  }

  Either<ChainError, List<Reminder>> _activateDownstream(
    ReminderChain chain,
    ReminderId id,
  ) {
    final edges = chain.edgesFrom(id);
    if (edges.isEmpty) return right(const []);

    final next = edges.map((e) => chain.reminderById(e.targetId)).toList();
    return right(next);
  }

  Either<ChainError, List<Reminder>> _suspendDownstream(
    ReminderChain chain,
    ReminderId id,
  ) {
    // Recursively collect all transitive descendants
    final suspended = <Reminder>[];
    final visited = <ReminderId>{};
    void walk(ReminderId current) {
      for (final edge in chain.edgesFrom(current)) {
        if (visited.add(edge.targetId)) {
          suspended.add(chain.reminderById(edge.targetId));
          walk(edge.targetId);
        }
      }
    }
    walk(id);
    return right(suspended);
  }
}
```

**Cycle prevention:** `ChainValidator` runs a topological sort at chain creation. If a cycle is detected, the chain is rejected with `ChainError.cycleDetected`.

### 4.2 Anchor Time Resolution

Anchors are user-defined meal times. When an anchor is confirmed (e.g., "I had lunch"), all dependent reminders recalculate their exact fire times:

```dart
class AnchorResolver {
  /// Recalculates scheduled times for all reminders depending on [anchor].
  List<ReminderScheduleUpdate> resolve({
    required MealAnchor anchor,
    required DateTime confirmedAt,
    required List<Reminder> dependents,
  }) {
    return dependents.map((r) {
      final offset = switch (r.medicineType) {
        MedicineType.beforeMeal => Duration(minutes: -30),
        MedicineType.afterMeal  => Duration(minutes: 30),
        MedicineType.doseGap    => Duration(hours: r.gapHours),
        _                       => Duration.zero,
      };
      final fireAt = confirmedAt.add(offset);
      return ReminderScheduleUpdate(
        reminderId: r.id,
        scheduledAt: fireAt,
      );
    }).toList();
  }
}
```

This runs **inside the confirmation handler**: anchor confirmed → resolve dependent times → reschedule alarms → update Drift rows.

### 4.3 Escalation State Machine

Each fired reminder progresses through three escalation tiers if unacknowledged:

```
                 timeout (2 min)           timeout (3 min)
  ┌──────────┐ ──────────────► ┌──────────┐ ──────────────► ┌──────────────┐
  │  SILENT  │                 │ AUDIBLE  │                 │  FULLSCREEN  │
  │ (notif.) │                 │(sound+vib)│                 │ (takeover)   │
  └──────────┘                 └──────────┘                 └──────────────┘
       │                            │                             │
       │◄── DONE/SKIP/SNOOZE ──────┤◄── DONE/SKIP/SNOOZE ───────┤
       ▼                            ▼                             ▼
   ┌────────┐                  ┌────────┐                    ┌────────┐
   │ CLOSED │                  │ CLOSED │                    │ CLOSED │
   └────────┘                  └────────┘                    └────────┘
```

```dart
enum EscalationLevel { silent, audible, fullscreen }

class EscalationFSM {
  EscalationLevel _current = EscalationLevel.silent;
  Timer? _timer;

  static const _timeouts = {
    EscalationLevel.silent: Duration(minutes: 2),
    EscalationLevel.audible: Duration(minutes: 3),
  };

  EscalationLevel get current => _current;

  void start(void Function(EscalationLevel) onEscalate) {
    _scheduleNext(onEscalate);
  }

  void acknowledge() {
    _timer?.cancel();
    _current = EscalationLevel.silent; // reset for next use
  }

  void _scheduleNext(void Function(EscalationLevel) onEscalate) {
    final timeout = _timeouts[_current];
    if (timeout == null) return; // already at fullscreen

    _timer = Timer(timeout, () {
      _current = EscalationLevel.values[_current.index + 1];
      onEscalate(_current);
      _scheduleNext(onEscalate);
    });
  }
}
```

### 4.4 Repository Pattern with Drift

Each aggregate root gets a dedicated DAO + Repository. The repository exposes domain models (Freezed); the DAO operates on Drift table rows:

```dart
// DAO — data layer, depends on Drift
@DriftAccessor(tables: [Reminders, ReminderSchedules])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Stream<List<ReminderRow>> watchActiveReminders() {
    return (select(reminders)
      ..where((r) => r.isActive.equals(true))
      ..orderBy([(r) => OrderingTerm.asc(r.scheduledAt)]))
        .watch();
  }
}

// Repository — bridges data ↔ domain
class ReminderRepository {
  final ReminderDao _dao;
  ReminderRepository(this._dao);

  Stream<List<Reminder>> watchActive() {
    return _dao.watchActiveReminders().map(
      (rows) => rows.map(Reminder.fromRow).toList(),
    );
  }
}
```

### 4.5 Riverpod Provider Architecture

```dart
// Database singleton
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

// DAO providers
@riverpod
ReminderDao reminderDao(Ref ref) =>
    ref.watch(appDatabaseProvider).reminderDao;

// Repository providers
@riverpod
ReminderRepository reminderRepository(Ref ref) =>
    ReminderRepository(ref.watch(reminderDaoProvider));

// Reactive stream → UI
@riverpod
Stream<List<Reminder>> activeReminders(Ref ref) =>
    ref.watch(reminderRepositoryProvider).watchActive();

// Chain state — AsyncNotifier for imperative mutations
@riverpod
class ChainStateNotifier extends _$ChainStateNotifier {
  @override
  Future<ChainState> build(ChainId chainId) async {
    final repo = ref.watch(chainRepositoryProvider);
    return repo.getChainState(chainId);
  }

  Future<void> confirmReminder(ReminderId id, ConfirmationState state) async {
    final engine = ref.read(chainEngineProvider);
    final chain = await future;
    final result = engine.evaluate(
      chain: chain.chain,
      confirmedId: id,
      state: state,
    );
    await result.fold(
      (error) async => state = AsyncError(error, StackTrace.current),
      (toActivate) async {
        await ref.read(alarmSchedulerProvider).scheduleAll(toActivate);
        ref.invalidateSelf();
      },
    );
  }
}
```

---

## 5. Data Flow Diagrams

### 5.1 Chain Firing Flow (Confirmation → Cascade)

```
User taps "DONE"
       │
       ▼
┌──────────────────┐     ┌───────────────────┐
│ ConfirmationNoti │────►│ ConfirmationDao   │── persist log
│ fier.confirm()   │     └───────────────────┘
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌───────────────────┐
│  ChainEngine     │────►│ Evaluate DAG      │
│  .evaluate()     │     │ edges from node   │
└────────┬─────────┘     └───────────────────┘
         │
         ├─── DONE ──────► Collect downstream reminders
         │                        │
         │                        ▼
         │              ┌──────────────────┐
         │              │  AnchorResolver  │── recalc times if anchor
         │              └────────┬─────────┘
         │                       │
         │                       ▼
         │              ┌──────────────────┐
         │              │  AlarmScheduler  │── schedule exact alarms
         │              │  .scheduleAll()  │
         │              └──────────────────┘
         │
         ├─── SNOOZED ──► Re-schedule same alarm (now + snooze_duration)
         │
         └─── SKIPPED ──► Suspend all transitive descendants
                                 │
                                 ▼
                       ┌──────────────────┐
                       │  AlarmScheduler  │── cancel descendant alarms
                       │  .cancelAll()    │
                       └──────────────────┘
```

### 5.2 Alarm Scheduling Flow

```
AlarmScheduler.schedule(reminder)
       │
       ▼
┌─────────────────────────────────┐
│ android_alarm_manager_plus      │
│ .oneShot(exact: true,           │
│   alarmId: reminder.id.hash,    │
│   at: reminder.scheduledAt,     │
│   callback: alarmCallback)      │
└────────────┬────────────────────┘
             │  (fires at scheduledAt)
             ▼
┌─────────────────────────────────┐
│ alarmCallback (top-level fn)    │──► runs in background isolate
│  1. Open Drift DB              │
│  2. Load reminder by ID        │
│  3. EscalationFSM.start()      │
│  4. NotificationSvc.show()     │
└─────────────────────────────────┘
```

**Critical:** `alarmCallback` is a **top-level function** (not a closure) because `android_alarm_manager_plus` invokes it in a separate isolate. The Drift database must be opened fresh in that isolate.

### 5.3 Notification Tier Rendering

```
EscalationLevel.silent     →  NotificationSvc.show(
                                 channel: 'silent', priority: low,
                                 sound: none, vibration: false)

EscalationLevel.audible    →  NotificationSvc.show(
                                 channel: 'urgent', priority: high,
                                 sound: 'reminder.wav', vibration: true)

EscalationLevel.fullscreen →  NotificationSvc.show(
                                 fullScreenIntent: true,
                                 channel: 'critical', priority: max)
                              + Launch FullScreenReminderPage via deep link
```

---

## 6. State Management Approach

| Provider Type                | Use Case                                    | Example                   |
| ---------------------------- | ------------------------------------------- | ------------------------- |
| `@Riverpod(keepAlive: true)` | App-wide singletons (DB, services)          | `appDatabaseProvider`     |
| `@riverpod StreamProvider`   | Reactive Drift queries → UI lists           | `activeRemindersProvider` |
| `@riverpod AsyncNotifier`    | Chain state with imperative mutations       | `ChainStateNotifier`      |
| `@riverpod`                  | Computed/derived values                     | `nextReminderProvider`    |
| `@riverpod FutureProvider`   | One-shot loads (template packs, onboarding) | `templatePackProvider`    |

**Rules:**

1. **No global mutable state.** All mutable state lives in `AsyncNotifier` or `StateNotifier` providers.
2. **Drift streams drive UI.** Repositories expose `Stream<List<T>>`; `StreamProvider` translates to `AsyncValue<List<T>>`.
3. **Chain engine is stateless.** It receives inputs (chain, confirmed ID, state) and returns outputs. No cached state.
4. **Provider families for per-entity state.** `chainStateNotifierProvider(chainId)` — one notifier per chain.

---

## 7. Anti-Patterns to Avoid

| Anti-Pattern                         | Why It's Dangerous Here                                       | Correct Approach                                  |
| ------------------------------------ | ------------------------------------------------------------- | ------------------------------------------------- |
| **Chain logic in UI layer**          | Untestable; can't run in background isolate                   | Pure Dart domain class, no Flutter imports        |
| **Direct SQLite calls (no Drift)**   | Loses type safety, reactive streams, migration support        | Always go through Drift DAOs                      |
| **Single notification channel**      | Android groups all notifications; escalation tiers collapse   | Separate channels: `silent`, `urgent`, `critical` |
| **Timer-based alarm scheduling**     | Killed by Doze mode; unreliable after app process death       | `android_alarm_manager_plus` with exact alarms    |
| **Storing chain graph in JSON blob** | Can't query edges, validate constraints, or stream changes    | Relational tables: `chains`, `edges`, `reminders` |
| **Fat providers**                    | One provider doing data fetch + chain eval + alarm scheduling | Split: repo provider → engine → scheduler         |
| **Ignoring isolate boundary**        | Passing non-serializable objects to `alarmCallback`           | Pass only IDs; re-hydrate from Drift in isolate   |
| **Hardcoded escalation timeouts**    | Users in different contexts need different urgency            | Store timeouts in `user_preferences` table        |

---

## 8. Integration Points (Internal Boundaries)

```
┌────────────────┐         ┌──────────────────┐         ┌────────────────┐
│  Confirmation  │────────►│   Chain Engine    │────────►│ Alarm Scheduler│
│  Service       │ (state) │   (DAG eval)     │ (list)  │ (platform)     │
└────────────────┘         └────────┬─────────┘         └────────────────┘
                                    │
                           ┌────────▼─────────┐
                           │ Anchor Resolver   │
                           │ (recalc times)    │
                           └────────┬─────────┘
                                    │
                           ┌────────▼─────────┐
                           │ Notification Svc  │
                           │ (display + TTS)   │
                           └──────────────────┘
```

**Boundary contracts:**

| Boundary                         | Interface                                                 | Data Crossing                  |
| -------------------------------- | --------------------------------------------------------- | ------------------------------ |
| Confirmation → ChainEngine       | `ChainEngine.evaluate(chain, id, state)`                  | `ConfirmationState` enum       |
| ChainEngine → AlarmScheduler     | `AlarmScheduler.scheduleAll(List<Reminder>)`              | Domain `Reminder` models       |
| ChainEngine → AnchorResolver     | `AnchorResolver.resolve(anchor, confirmedAt, dependents)` | `MealAnchor` + `DateTime`      |
| AlarmScheduler → NotificationSvc | `NotificationSvc.show(reminder, escalationLevel)`         | `Reminder` + `EscalationLevel` |
| NotificationSvc → TTSService     | `TTSService.speak(reminder.displayText)`                  | `String`                       |
| Background Isolate → Drift DB    | Open fresh `AppDatabase()` instance in isolate            | Reminder ID (int)              |

**Key constraint:** The chain engine never directly calls platform services. The application layer (Riverpod notifiers) orchestrates domain → platform handoff. This keeps the domain layer testable with zero mocking of platform channels.

---

## 9. Database Schema (Key Tables)

```sql
-- Core entities
CREATE TABLE reminder_chains (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL,
  is_active   INTEGER NOT NULL DEFAULT 1,
  created_at  INTEGER NOT NULL  -- Unix ms
);

CREATE TABLE reminders (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  chain_id        INTEGER NOT NULL REFERENCES reminder_chains(id),
  medicine_name   TEXT NOT NULL,
  medicine_type   TEXT NOT NULL,  -- 'before_meal', 'after_meal', etc.
  dosage          TEXT,
  scheduled_at    INTEGER,        -- Unix ms, nullable until anchor resolves
  is_active       INTEGER NOT NULL DEFAULT 0,
  gap_hours       INTEGER         -- for dose_gap type
);

CREATE TABLE chain_edges (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  chain_id    INTEGER NOT NULL REFERENCES reminder_chains(id),
  source_id   INTEGER NOT NULL REFERENCES reminders(id),
  target_id   INTEGER NOT NULL REFERENCES reminders(id),
  UNIQUE(source_id, target_id)
);

CREATE TABLE confirmations (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  reminder_id   INTEGER NOT NULL REFERENCES reminders(id),
  state         TEXT NOT NULL,    -- 'done', 'snoozed', 'skipped'
  confirmed_at  INTEGER NOT NULL, -- Unix ms
  snooze_until  INTEGER           -- Unix ms, nullable
);

CREATE TABLE meal_anchors (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  meal_type     TEXT NOT NULL,    -- 'breakfast', 'lunch', 'dinner'
  default_time  INTEGER NOT NULL, -- minutes from midnight
  confirmed_at  INTEGER           -- today's actual confirmation time
);
```

---

## 10. Build Order Alignment

The architecture layers map directly to the `FEATURES.md` build order:

| Phase | Feature             | Architecture Layer                        |
| ----- | ------------------- | ----------------------------------------- |
| 1     | Storage             | `core/database/` — Drift DB + migrations  |
| 2     | Data Model          | `features/*/domain/models/` — Freezed     |
| 3     | Notification Engine | `core/platform/notification_service.dart` |
| 4     | Confirmation States | `features/confirmation/`                  |
| 5     | Chain Engine        | `features/chain_engine/domain/`           |
| 6     | Meal Anchoring      | `features/anchors/`                       |
| 7     | Templates           | `features/templates/`                     |
| 8     | NLP                 | `features/nlp/` (v1.x deferred)           |

Each phase only depends on layers completed in prior phases. No forward references.

---

## 11. Sources

| Source                                     | Relevance                                        |
| ------------------------------------------ | ------------------------------------------------ |
| Drift documentation (drift.simonbinder.eu) | DAO pattern, reactive streams, isolate usage     |
| Riverpod docs (riverpod.dev)               | AsyncNotifier, code-gen, provider lifecycle      |
| android_alarm_manager_plus README          | Exact alarm API, isolate callback constraints    |
| flutter_local_notifications docs           | Full-screen intent, channel config, Android 13+  |
| Android Doze/App Standby docs              | Why Timer-based scheduling fails                 |
| fpdart documentation                       | Either type for domain error handling            |
| Flutter offline-first architecture blogs   | Repository pattern, Drift + Riverpod integration |
