import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'test_helpers.dart';

void main() {
  patrolSetUp(testSetUp);
  patrolTearDown(testTearDown);

  group('Offline Operation', () {
    patrolTest(
      'full flow works in airplane mode '
      '— zero network dependency',
      ($) async {
        // NOTE: Airplane mode must be enabled
        // before running this test. Options:
        // 1. Use ADB:
        //    adb shell settings put global \
        //      airplane_mode_on 1
        //    adb shell am broadcast -a \
        //      android.intent.action.AIRPLANE_MODE
        // 2. Manually enable on device before run.
        //
        // Patrol does not support airplane
        // toggle natively in ^4.3.0.

        await $.pumpApp();

        // ── Onboarding ──
        await $.call('What do you need help with?')
            .waitUntilVisible();
        await $.call('Diabetes').tap();
        await $.pumpAndSettle();

        await $.call('Choose a template')
            .waitUntilVisible();
        await $.call('Select').tap();
        await $.pumpAndSettle();

        await $.call('Set your meal times')
            .waitUntilVisible();
        await $.call('Continue').tap();
        await $.pumpAndSettle();

        await $.call('Your Medicines')
            .waitUntilVisible();
        await $.call('Continue').tap();
        await $.pumpAndSettle();

        await $.call('Review Your Schedule')
            .waitUntilVisible();
        await $.call('Looks Good \u2014 Set It Up!')
            .tap();
        await $.pumpAndSettle();

        // Skip permissions (airplane mode blocks
        // some system dialogs on certain OEMs).
        await $.call('Allow Permissions')
            .waitUntilVisible();
        await $.call('Skip for now').tap();
        await $.pumpAndSettle();

        // ── Assert: home screen loaded offline ──
        await $.call('MemoCare').waitUntilVisible();

        // ── Navigate to history ──
        await $.call('History').tap();
        await $.pumpAndSettle();

        // History screen should load (empty) without
        // errors — no network spinners or dialogs.
        expect(
          $.call('History').exists,
          isTrue,
          reason: 'History should load offline',
        );
      },
    );

    patrolTest(
      'no login or signup required '
      '— single-user local-only',
      ($) async {
        await $.pumpApp();

        // ── Assert: first screen is onboarding ──
        await $.call('What do you need help with?')
            .waitUntilVisible();

        // No login, signup, or auth screen at all.
        expect(
          $.call('Sign In').exists,
          isFalse,
          reason: 'No sign-in screen expected',
        );
        expect(
          $.call('Log In').exists,
          isFalse,
          reason: 'No login screen expected',
        );
        expect(
          $.call('Create Account').exists,
          isFalse,
          reason: 'No account creation expected',
        );
      },
    );
  });
}
