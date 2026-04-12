import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/dev/harness_runners.dart';

/// TC-169–TC-188 Fullscreen alarm & tray.
class AlarmTestRunner {
  AlarmTestRunner._();

  static void runTests(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessRunners.runAlarm(ref);
  }
}
