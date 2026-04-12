import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/dev/harness_runners.dart';

/// TC-066–TC-074 Missed reminders sheet.
class MissedSheetTestRunner {
  MissedSheetTestRunner._();

  static void runTests(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessRunners.runMissedSheet(ref);
  }
}
