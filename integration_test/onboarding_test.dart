import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'test_helpers.dart';

void main() {
  patrolSetUp(testSetUp);
  patrolTearDown(testTearDown);

  group('Onboarding Flow', () {
    patrolTest(
      'completes onboarding via template path '
      '— lands on home with reminders',
      ($) async {
        await $.pumpApp();

        // ── Step 1: Condition ──
        // First launch → redirect to onboarding.
        await $.call('What do you need help with?')
            .waitUntilVisible();
        await $.call('Diabetes').tap();
        await $.pumpAndSettle();

        // ── Step 2: Template picker ──
        await $.call('Choose a template')
            .waitUntilVisible();
        // Select the first available template.
        await $.call('Select').tap();
        await $.pumpAndSettle();

        // ── Step 3: Meal anchors ──
        await $.call('Set your meal times')
            .waitUntilVisible();
        await $.call('Continue').tap();
        await $.pumpAndSettle();

        // ── Step 4: Medicines (template pre-filled) ──
        await $.call('Your Medicines')
            .waitUntilVisible();
        await $.call('Continue').tap();
        await $.pumpAndSettle();

        // ── Step 5: Review ──
        await $.call('Review Your Schedule')
            .waitUntilVisible();
        await $.call('Looks Good \u2014 Set It Up!')
            .tap();
        await $.pumpAndSettle();

        // ── Step 6: Permissions ──
        // Grant all permissions via native interaction.
        await $.call('Allow Permissions')
            .waitUntilVisible();
        await $.call('Grant All Permissions').tap();
        await $.platform.mobile
            .grantPermissionWhenInUse();
        await $.pumpAndSettle();

        // ── Assertions: home screen ──
        await $.call('MemoCare').waitUntilVisible();
      },
    );

    patrolTest(
      'completes onboarding via manual entry '
      '— single medicine appears on home',
      ($) async {
        await $.pumpApp();

        // ── Condition ──
        await $.call('What do you need help with?')
            .waitUntilVisible();
        await $.call('Diabetes').tap();
        await $.pumpAndSettle();

        // ── Skip template ──
        await $.call('Choose a template')
            .waitUntilVisible();
        await $.call(
          "Skip — I'll add medicines manually",
        ).tap();
        await $.pumpAndSettle();

        // ── Meal anchors (accept defaults) ──
        await $.call('Set your meal times')
            .waitUntilVisible();
        await $.call('Continue').tap();
        await $.pumpAndSettle();

        // ── Manual medicine entry ──
        await $.call('Add Your Medicines')
            .waitUntilVisible();
        await $.call('Add Medicine').tap();
        await $.pumpAndSettle();

        // Fill medicine dialog.
        await $.tester.enterText(
          $.call('Medicine Name').exists
              ? $.call('Medicine Name').finder
              : $.call('e.g., Metformin').finder,
          'Aspirin',
        );
        await $.tester.enterText(
          $.call('Dosage').exists
              ? $.call('Dosage').finder
              : $.call('e.g., 500mg').finder,
          '75mg',
        );
        await $.call('Add').tap();
        await $.pumpAndSettle();

        // Continue past medicines.
        await $.call('Continue').tap();
        await $.pumpAndSettle();

        // ── Review ──
        await $.call('Review Your Schedule')
            .waitUntilVisible();
        await $.call('Looks Good \u2014 Set It Up!')
            .tap();
        await $.pumpAndSettle();

        // ── Permissions — skip for now ──
        await $.call('Allow Permissions')
            .waitUntilVisible();
        await $.call('Skip for now').tap();
        await $.pumpAndSettle();

        // ── Assertions ──
        await $.call('MemoCare').waitUntilVisible();
        // Aspirin should appear in today's schedule.
        await $.call('Aspirin').waitUntilVisible();
      },
    );

    patrolTest(
      'preserves selections on back navigation '
      'during onboarding',
      ($) async {
        await $.pumpApp();

        // ── Condition ──
        await $.call('What do you need help with?')
            .waitUntilVisible();
        await $.call('Diabetes').tap();
        await $.pumpAndSettle();

        // ── Template ──
        await $.call('Choose a template')
            .waitUntilVisible();
        await $.call('Select').tap();
        await $.pumpAndSettle();

        // ── Anchors ──
        await $.call('Set your meal times')
            .waitUntilVisible();

        // Navigate back via system back or AppBar back.
        await $.tester.pageBack();
        await $.pumpAndSettle();

        // ── Template should still be selected ──
        await $.call('Choose a template')
            .waitUntilVisible();
        // The previously selected template should show
        // its selected state.
        await $.call('Select').waitUntilVisible();

        // Go forward again.
        await $.call('Select').tap();
        await $.pumpAndSettle();

        // Anchors should appear without losing state.
        await $.call('Set your meal times')
            .waitUntilVisible();
      },
    );
  });
}
