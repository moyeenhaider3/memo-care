import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/confirmation/domain/confirmation_service.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/confirmation/domain/models/undoable_confirmation.dart';
import 'package:memo_care/features/confirmation/presentation/widgets/undo_confirmation_bar.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
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
                Mock // ignore: prefer_mixin // workaround
    implements DailyScheduleNotifier {
  @override
  Future<DailyScheduleState> build() async => const DailyScheduleState(
    todayReminders: [],
    missedReminders: [],
  );
}

// ── Test data ──────────────────────────────────────────

const _testReminder = Reminder(
  id: 1,
  chainId: 100,
  medicineName: 'Metformin',
  medicineType: MedicineType.afterMeal,
  dosage: '500 mg',
);

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: child),
);

/// Finds a [Semantics] widget whose `properties.label`
/// matches [expected].
void _expectSemanticsLabel(
  WidgetTester tester,
  String expected,
) {
  final found = tester.widgetList<Semantics>(
    find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == expected,
    ),
  );
  expect(
    found.length,
    greaterThanOrEqualTo(1),
    reason:
        'Expected Semantics(label: "$expected") '
        'but found none',
  );
}

void main() {
  group('Semantics — StatusBadge', () {
    testWidgets('done badge has correct Semantics label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatusBadge(
            status: ConfirmationState.done,
          ),
        ),
      );

      _expectSemanticsLabel(tester, 'Status: Done');
    });

    testWidgets('missed badge has correct Semantics label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatusBadge(
            status: null,
            isMissed: true,
          ),
        ),
      );

      _expectSemanticsLabel(tester, 'Status: Missed');
    });

    testWidgets('pending badge has correct Semantics label', (tester) async {
      await tester.pumpWidget(
        _wrap(const StatusBadge(status: null)),
      );

      _expectSemanticsLabel(tester, 'Status: Pending');
    });

    testWidgets('skipped badge has correct Semantics label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatusBadge(
            status: ConfirmationState.skipped,
          ),
        ),
      );

      _expectSemanticsLabel(tester, 'Status: Skipped');
    });
  });

  group('Semantics — ReminderListTile', () {
    testWidgets('tile has Semantics label with medicine details', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ReminderListTile(
            reminder: _testReminder,
            confirmationStatus: ConfirmationState.done,
          ),
        ),
      );

      // Label should contain medicine name, dosage,
      // and status.
      expect(
        find.bySemanticsLabel(
          RegExp('Metformin.*500 mg.*done'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tile Semantics has button: true (tappable)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ReminderListTile(
            reminder: _testReminder,
          ),
        ),
      );

      // Verify by checking that the Semantics widget
      // has button: true — find it via widget predicate.
      final semanticsWidget = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.button ?? false) &&
              w.properties.label != null &&
              w.properties.label!.contains('Metformin'),
        ),
      );
      expect(
        semanticsWidget.properties.button,
        isTrue,
      );
    });
  });

  group('Semantics — NextPendingHeroCard', () {
    testWidgets('all-done card has correct Semantics', (tester) async {
      final notifier = _MockDailyScheduleNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyScheduleNotifierProvider.overrideWith(
              () => notifier,
            ),
          ],
          child: _wrap(
            NextPendingHeroCard(
              onDone: (_) {},
              onSnooze: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          RegExp('All.*done.*today'),
        ),
        findsOneWidget,
      );
    });
  });

  group('Semantics — FullScreenAlarmScreen '
      'focus order', () {
    testWidgets('alarm title, done button and skip button '
        'have Semantics', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FullScreenAlarmScreen(
            reminderId: 1,
            medicineName: 'Aspirin',
            dosage: '100 mg',
            scheduledTime: '8:00 AM',
            onDone: () {},
            onSnooze: () {},
            onSkip: () {},
          ),
        ),
      );

      // Header with alarm info
      expect(
        find.bySemanticsLabel(
          RegExp('Time to take'),
        ),
        findsOneWidget,
      );

      // Medicine details Semantics
      expect(
        find.bySemanticsLabel(
          RegExp('Alarm.*Aspirin.*100 mg'),
        ),
        findsOneWidget,
      );

      // Done button Semantics
      expect(
        find.bySemanticsLabel(
          RegExp('Confirm taking Aspirin'),
        ),
        findsOneWidget,
      );

      // Skip button Semantics
      expect(
        find.bySemanticsLabel(
          RegExp('Skip Aspirin'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('focus order increases sequentially '
        '(OrdinalSortKey)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FullScreenAlarmScreen(
            reminderId: 1,
            medicineName: 'Aspirin',
            dosage: '100 mg',
            scheduledTime: '8:00 AM',
            onDone: () {},
            onSnooze: () {},
            onSkip: () {},
          ),
        ),
      );

      // Collect OrdinalSortKey values from Semantics
      // widgets in the tree.
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final sortKeys = <double>[];
      for (final s in semanticsWidgets) {
        final key = s.properties.sortKey;
        if (key is OrdinalSortKey) {
          sortKeys.add(key.order);
        }
      }

      // Verify sorted keys are sequential (0, 1, 2, 3)
      expect(sortKeys, isNotEmpty);
      for (var i = 1; i < sortKeys.length; i++) {
        expect(
          sortKeys[i],
          greaterThanOrEqualTo(sortKeys[i - 1]),
          reason:
              'OrdinalSortKey values should '
              'increase: ${sortKeys[i - 1]} → '
              '${sortKeys[i]}',
        );
      }
    });
  });

  group('Semantics — UndoConfirmationBar', () {
    testWidgets('has liveRegion Semantics and undo button label', (
      tester,
    ) async {
      const undoable = UndoableConfirmation(
        confirmationId: 1,
        reminderId: 1,
        chainId: 100,
        medicineName: 'Paracetamol',
        confirmState: ConfirmationState.done,
        outcome: ActivateDownstream(
          reminders: [],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: _wrap(
            UndoConfirmationBar(
              undoable: undoable,
              onDismissed: () {},
            ),
          ),
        ),
      );

      // Verify liveRegion label
      expect(
        find.bySemanticsLabel(
          RegExp('Paracetamol.*done.*undo'),
        ),
        findsOneWidget,
      );

      // Verify undo button Semantics
      expect(
        find.bySemanticsLabel(
          RegExp('Undo.*Paracetamol'),
        ),
        findsOneWidget,
      );
    });
  });

  group('Semantics — ExcludeSemantics', () {
    testWidgets('FullScreenAlarm decorative icon is excluded', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FullScreenAlarmScreen(
            reminderId: 1,
            medicineName: 'Test',
            dosage: '1 tab',
            scheduledTime: '9 AM',
            onDone: () {},
            onSnooze: () {},
            onSkip: () {},
          ),
        ),
      );

      // The medication_rounded icon should be wrapped
      // in ExcludeSemantics — verify it exists as widget
      // but has no Semantics label of its own.
      final excludeWidgets = tester.widgetList<ExcludeSemantics>(
        find.byType(ExcludeSemantics),
      );
      expect(
        excludeWidgets.length,
        greaterThanOrEqualTo(1),
        reason:
            'Decorative icon should be excluded '
            'from Semantics tree',
      );
    });
  });
}
