import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/dev/harness_runners.dart';

/// TC-085–TC-099 History.
class HistoryTestRunner {
  HistoryTestRunner._();

  static Future<void> runTests(WidgetRef ref) async {
    if (!kDebugMode) return;
    await HarnessRunners.runHistory(ref);
  }
}
