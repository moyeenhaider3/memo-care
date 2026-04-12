import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/dev/harness_runners.dart';

/// TC-149–TC-158 Template library.
class TemplateLibraryTestRunner {
  TemplateLibraryTestRunner._();

  static void runTests(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessRunners.runTemplateLibrary(ref);
  }
}
