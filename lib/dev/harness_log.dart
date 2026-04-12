import 'package:flutter/foundation.dart';

/// Structured terminal logging for the MemoCare developer harness.
/// All output uses [debugPrint] so it appears in `flutter run`.
class HarnessLog {
  HarnessLog._();

  static int passCount = 0;
  static int failCount = 0;
  static int manualCount = 0;
  static int skippedCount = 0;
  static final List<String> failedLines = [];
  static final List<String> manualLines = [];

  static void reset() {
    passCount = 0;
    failCount = 0;
    manualCount = 0;
    skippedCount = 0;
    failedLines.clear();
    manualLines.clear();
  }

  static void banner(String title) {
    debugPrint('');
    debugPrint('════════════════════════════════════════');
    debugPrint(title);
    debugPrint('════════════════════════════════════════');
  }

  static void pass(
    String tcId,
    String title,
    String method,
    String input,
    String result,
  ) {
    passCount++;
    debugPrint('▶ $tcId | $title');
    debugPrint('  METHOD: $method');
    debugPrint('  INPUT:  $input');
    debugPrint('  RESULT: ✅ PASS — $result');
  }

  static void fail(
    String tcId,
    String title,
    String method,
    String input,
    Object error,
  ) {
    failCount++;
    final line = '$tcId — $method — $error';
    failedLines.add(line);
    debugPrint('▶ $tcId | $title');
    debugPrint('  METHOD: $method');
    debugPrint('  INPUT:  $input');
    debugPrint('  RESULT: ❌ FAIL — $error');
  }

  static void manual(
    String tcId,
    String title,
    String method,
    String steps,
  ) {
    manualCount++;
    manualLines.add('$tcId — $title');
    debugPrint('▶ $tcId | $title');
    debugPrint('  METHOD: $method');
    debugPrint('  RESULT: ⚠️ MANUAL — $steps');
  }

  static void skipped(String tcId, String title, String reason) {
    skippedCount++;
    debugPrint('▶ $tcId | $title');
    debugPrint('  RESULT: 🔶 SKIPPED — $reason');
  }

  static void summaryFooter({
    required int totalTcs,
  }) {
    banner('📋 MEMOCARE TEST RUN SUMMARY');
    debugPrint('Total TCs:     $totalTcs');
    debugPrint('✅ PASS:        $passCount  (auto-verified via logs)');
    debugPrint('❌ FAIL:        $failCount');
    debugPrint('⚠️  MANUAL:      $manualCount  (requires visual check)');
    debugPrint('🔶 SKIPPED:     $skippedCount');
    if (failedLines.isNotEmpty) {
      debugPrint('');
      debugPrint('Failed TCs:');
      for (final l in failedLines) {
        debugPrint('  $l');
      }
    }
    if (manualLines.isNotEmpty) {
      debugPrint('');
      debugPrint('Manual TCs (sample):');
      for (final l in manualLines.take(20)) {
        debugPrint('  $l');
      }
      if (manualLines.length > 20) {
        debugPrint('  … +${manualLines.length - 20} more');
      }
    }
    debugPrint('════════════════════════════════════════');
  }
}
