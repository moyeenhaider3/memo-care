import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/app.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/providers/database_provider.dart';
import 'package:patrol/patrol.dart';

// ── In-memory database ─────────────────────────────────

/// Creates a fresh in-memory [AppDatabase] for each test.
AppDatabase createTestDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());

// ── Setup / Teardown ───────────────────────────────────

AppDatabase? _testDb;

/// Called before each patrol test.
Future<void> testSetUp() async {
  _testDb = createTestDatabase();
}

/// Called after each patrol test.
Future<void> testTearDown() async {
  await _testDb?.close();
  _testDb = null;
}

// ── App Pumping ────────────────────────────────────────

/// Extensions for pumping the MemoCare app in patrol
/// integration tests.
extension AppPumping on PatrolIntegrationTester {
  /// Pump the MemoCare app with an in-memory database.
  Future<void> pumpApp() async {
    final db = _testDb ?? createTestDatabase();
    await pumpWidgetAndSettle(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const MemoCareApp(),
      ),
    );
  }
}

// ── Common Interactions ────────────────────────────────

/// Extensions for common in-app interactions used
/// across integration tests.
extension CommonActions on PatrolIntegrationTester {
  /// Complete the onboarding flow with default
  /// selections. Lands on the home screen upon
  /// completion.
  ///
  /// Uses widget text selectors that match the actual
  /// screen text from Phases 06-08.
  Future<void> completeOnboarding({
    String condition = 'Diabetes',
  }) async {
    // Step 1: Select condition
    await call(condition).tap();
    await call('Continue').tap();
    await pumpAndSettle();

    // Step 2: Template picker — skip for manual path
    await call('Skip').tap();
    await pumpAndSettle();

    // Step 3: Set meal anchors (accept defaults)
    await call('Continue').tap();
    await pumpAndSettle();

    // Step 4: Add at least one medicine
    await call('Add a medicine').tap();
    await pumpAndSettle();

    // Step 5: Review and confirm
    await call('Confirm').tap();
    await pumpAndSettle();
  }

  /// Navigate to a tab by tapping its bottom nav label.
  Future<void> navigateToTab(String label) async {
    await call(label).tap();
    await pumpAndSettle();
  }

  /// Wait until [text] is visible, polling with a
  /// timeout.
  Future<void> waitForVisible(
    String text, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      try {
        await call(text).waitUntilVisible();
        return;
      } on Exception {
        await Future<void>.delayed(
          const Duration(milliseconds: 500),
        );
      }
    }
    throw TimeoutException(
      '"$text" not visible after $timeout',
    );
  }
}
