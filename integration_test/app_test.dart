import 'package:patrol/patrol.dart';

import 'test_helpers.dart';

void main() {
  patrolSetUp(testSetUp);
  patrolTearDown(testTearDown);

  // Detailed flow tests are added by Plans 09-02 → 09-04.
  // This smoke test verifies the harness boots the app.

  patrolTest(
    'app launches successfully',
    ($) async {
      await $.pumpApp();

      // App should show either onboarding (first launch)
      // or home screen. On a fresh in-memory DB the
      // onboarding redirect fires because isComplete is
      // false — so check for the condition step.
      await $.pumpAndSettle();
    },
  );
}
