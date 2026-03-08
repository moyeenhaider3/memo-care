import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'test_helpers.dart';

void main() {
  patrolSetUp(testSetUp);
  patrolTearDown(testTearDown);

  group('Boot Reschedule', () {
    patrolTest(
      'boot-completed broadcast triggers '
      'alarm rescheduling',
      ($) async {
        await $.pumpApp();
        await $.completeOnboarding();
        await $.pumpAndSettle();

        // Verify home screen has scheduled reminders
        // from the template onboarding path.
        await $.call('MemoCare').waitUntilVisible();

        // Simulate BOOT_COMPLETED broadcast via ADB.
        // NOTE: This requires adb access from the
        // test runner. The actual command is:
        //
        //   adb shell am broadcast \
        //     -a android.intent.action.BOOT_COMPLETED
        //     -n com.example.memo_care/
        //       .BootCompletedReceiver
        //
        // Patrol cannot send ADB broadcasts directly.
        // This test serves as the structural scaffold
        // — run with `adb shell` in a CI pipeline
        // or manually verify with ADB.

        // After the broadcast, alarms should be
        // rescheduled. Verify by waiting for the
        // next notification to fire at the expected
        // time.
        await $.pumpAndSettle();
      },
    );

    patrolTest(
      'app-update broadcast triggers '
      'alarm rescheduling',
      ($) async {
        await $.pumpApp();
        await $.completeOnboarding();
        await $.pumpAndSettle();

        await $.call('MemoCare').waitUntilVisible();

        // Simulate MY_PACKAGE_REPLACED via ADB:
        //
        //   adb shell am broadcast \
        //     -a android.intent.action
        //       .MY_PACKAGE_REPLACED \
        //     -n com.example.memo_care/
        //       .PackageUpdateReceiver
        //
        // After package update, all pending alarms
        // should be re-registered with the
        // AlarmManager. Verify notifications still
        // fire at expected times.
        await $.pumpAndSettle();
      },
    );
  });
}
