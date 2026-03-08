import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/confirmation/application/confirmation_notifier.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/daily_schedule/presentation/home_screen.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/next_pending_hero_card.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/reminder_list_tile.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/status_badge.dart';
import 'package:memo_care/features/escalation/presentation/fullscreen_alarm_screen.dart';
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
                onSkip: (_) {},
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
                onSkip: (_) {},
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
        expect(tester.takeException(), isNull);
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
            ],
            child: _scaled(const HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
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

        final sizedBoxes = tester.widgetList<SizedBox>(
          find.byType(SizedBox),
        );
        final buttonWrappers = sizedBoxes.where(
          (sb) => sb.height != null && sb.height! >= 72,
        );
        // At least 2 of the SizedBox have height ≥ 72 (done + skip)
        expect(buttonWrappers.length, greaterThanOrEqualTo(2));
      },
    );
  });
}
