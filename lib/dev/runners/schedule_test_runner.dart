import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/dev/harness_runners.dart';

/// TC-075–TC-084 Today’s schedule.
class ScheduleTestRunner {
  ScheduleTestRunner._();

  static void runTests(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessRunners.runSchedule(ref);
  }
}
