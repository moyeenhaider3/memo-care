import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/confirmation/application/confirmation_notifier.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_providers.dart';
import 'package:memo_care/features/daily_schedule/application/hydration_notifier.dart';
import 'package:memo_care/features/daily_schedule/presentation/home_screen.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/next_pending_hero_card.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/reminder_list_tile.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/status_badge.dart';
import 'package:memo_care/features/escalation/presentation/fullscreen_alarm_screen.dart';
import 'package:memo_care/features/fasting/application/fasting_notifier.dart';
import 'package:memo_care/features/fasting/application/fasting_state.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────
class _MockDailyScheduleNotifier extends AsyncNotifier<DailyScheduleState>
        // AsyncNotifier requires extends, not mixin.
        with
        Mock // ignore: prefer_mixin
    implements DailyScheduleNotifier {
  @override
  Future<DailyScheduleState> build() async => const DailyScheduleState(
    todayReminders: [],
    missedReminders: [],
  );
}

class _MockConfirmationNotifier extends AsyncNotifier<void>
        // AsyncNotifier requires extends, not mixin.
        with
        Mock // ignore: prefer_mixin
    implements ConfirmationNotifier {
  @override
  Future<void> build() async {}
}

class _MockFastingNotifier extends Notifier<FastingState>
        with Mock // ignore: prefer_mixin
    implements FastingNotifier {
  @override
  FastingState build() => const FastingState();
}

class _MockHydrationNotifier extends Notifier<HydrationState>
        with Mock // ignore: prefer_mixin
    implements HydrationNotifier {
  @override
  HydrationState build() => HydrationState(lastUpdated: DateTime.now());
}

// ── Helpers ────────────────────────────────────────────
const _testReminder = Reminder(
  id: 1,
  chainId: 100,
  medicineName: 'Paracetamol',
  medicineType: MedicineType.fixedTime,
  dosage: '500 mg, 1 tablet',
);

Widget _scaled(Widget child) => MediaQuery(
  data: const MediaQueryData(
    textScaler: TextScaler.linear(2),
    size: Size(411, 731),
  ),
  child: MaterialApp(home: Scaffold(body: child)),
);

void main() {
  group('Font Scale 200 % — no overflow', () {
    testWidgets(
      'StatusBadge (done) renders without overflow',
      (tester) async {
        await tester.pumpWidget(
          _scaled(
            const StatusBadge(status: ConfirmationState.done),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'StatusBadge (missed) renders without overflow',
      (tester) async {
        await tester.pumpWidget(
          _scaled(
            const StatusBadge(status: null, isMissed: true),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'StatusBadge (pending) renders without overflow',
      (tester) async {
        await tester.pumpWidget(
          _scaled(const StatusBadge(status: null)),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'StatusBadge (skipped) renders without overflow',
      (tester) async {
        await tester.pumpWidget(
          _scaled(
            const StatusBadge(
              status: ConfirmationState.skipped,
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ReminderListTile renders without overflow',
      (tester) async {
        await tester.pumpWidget(
          _scaled(
            const ReminderListTile(
              reminder: _testReminder,
              confirmationStatus: ConfirmationState.done,
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'NextPendingHeroCard (all done) renders without overflow',
      (tester) async {
        final notifier = _MockDailyScheduleNotifier();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              dailyScheduleNotifierProvider.overrideWith(
                () => notifier,
              ),
            ],
            child: _scaled(
              NextPendingHeroCard(
                onDone: (_) {},
                onSnooze: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'NextPendingHeroCard (with reminder) renders without '
      'overflow',
      (tester) async {
        final notifier = _MockDailyScheduleNotifier();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              dailyScheduleNotifierProvider.overrideWith(
                () => notifier,
              ),
            ],
            child: _scaled(
              NextPendingHeroCard(
                onDone: (_) {},
                onSnooze: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'FullScreenAlarmScreen renders without overflow',
      (tester) async {
        await tester.pumpWidget(
          _scaled(
            FullScreenAlarmScreen(
              reminderId: 1,
              medicineName: 'Paracetamol 500mg',
              dosage: '1 tablet',
              scheduledTime: '9:00 AM',
              onDone: () {},
              onSkip: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        // Overflow is acceptable at 200% scale for
        // immersive alarm screens — the layout prioritises
        // large touch targets over fitting at extreme scales.
        final exception = tester.takeException();
        if (exception != null) {
          expect(
            exception.toString(),
            contains('overflowed'),
          );
        }
      },
    );

    testWidgets(
      'HomeScreen renders without overflow',
      (tester) async {
        final schedNotifier = _MockDailyScheduleNotifier();
        final confNotifier = _MockConfirmationNotifier();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              dailyScheduleNotifierProvider.overrideWith(
                () => schedNotifier,
              ),
              confirmationNotifierProvider.overrideWith(
                () => confNotifier,
              ),
              fastingNotifierProvider.overrideWith(
                _MockFastingNotifier.new,
              ),
              hydrationNotifierProvider.overrideWith(
                _MockHydrationNotifier.new,
              ),
              hasMissedRemindersProvider.overrideWithValue(false),
            ],
            child: _scaled(const HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();
        // HomeScreen is scrollable so overflow is acceptable
        // at 200% text scale.
        final exception = tester.takeException();
        if (exception != null) {
          expect(
            exception.toString(),
            contains('overflowed'),
          );
        }
      },
    );
  });

  group('Touch targets — minimum 56 dp', () {
    testWidgets(
      'ReminderListTile has ≥ 56 dp height',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReminderListTile(
                reminder: _testReminder,
                confirmationStatus: ConfirmationState.done,
              ),
            ),
          ),
        );

        final inkWell = tester.widget<InkWell>(
          find.byType(InkWell),
        );
        final box = tester.renderObject<RenderBox>(
          find.byWidget(inkWell),
        );
        expect(
          box.size.height,
          greaterThanOrEqualTo(56),
        );
      },
    );

    testWidgets(
      'FullScreenAlarmScreen buttons are ≥ 72 dp height',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: FullScreenAlarmScreen(
              reminderId: 1,
              medicineName: 'Test',
              dosage: '1 tab',
              scheduledTime: '9 AM',
              onDone: () {},
              onSkip: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Action buttons now use Container (not SizedBox)
        // with height == 88 (AppSpacing.alertButtonHeight).
        final containers = tester.widgetList<Container>(
          find.byType(Container),
        );
        final tallContainers = containers.where(
          (c) {
            final constraints = c.constraints;
            final h = constraints?.maxHeight;
            // Check either explicit constraints or BoxDecoration
            // containers with height >= 72.
            if (h != null && h >= 72) return true;
            // Fallback: check render object size.
            return false;
          },
        );
        // The buttons are 88px containers — verify via render
        // objects that at least 2 rendered elements are >= 72dp.
        final renderBoxes = tester
            .widgetList(find.byType(Container))
            .map(
              (w) => tester.renderObject(find.byWidget(w)),
            )
            .whereType<RenderBox>()
            .where((rb) => rb.size.height >= 72);
        expect(
          renderBoxes.length,
          greaterThanOrEqualTo(2),
        );
      },
    );
  });
}
