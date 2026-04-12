import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/dev/harness_runners.dart';

/// TC-100–TC-125 Profile / settings.
class ProfileTestRunner {
  ProfileTestRunner._();

  static void runTests(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessRunners.runProfile(ref);
  }
}
