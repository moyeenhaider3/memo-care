import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/dev/harness_runners.dart';

/// TC-001–TC-012 App shell / global.
class ShellGlobalTestRunner {
  ShellGlobalTestRunner._();

  static void runTests(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessRunners.runShellGlobal(ref);
  }
}
