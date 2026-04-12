import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/dev/harness_runners.dart';

/// TC-159–TC-168 Chain context.
class ChainContextTestRunner {
  ChainContextTestRunner._();

  static Future<void> runTests(WidgetRef ref) async {
    if (!kDebugMode) return;
    await HarnessRunners.runChainContext(ref);
  }
}
