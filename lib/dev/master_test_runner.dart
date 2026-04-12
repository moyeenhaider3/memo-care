import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/dev/harness_log.dart';
import 'package:memo_care/dev/runners/add_reminder_test_runner.dart';
import 'package:memo_care/dev/runners/alarm_test_runner.dart';
import 'package:memo_care/dev/runners/chain_context_test_runner.dart';
import 'package:memo_care/dev/runners/history_test_runner.dart';
import 'package:memo_care/dev/runners/home_test_runner.dart';
import 'package:memo_care/dev/runners/kids_test_runner.dart';
import 'package:memo_care/dev/runners/missed_sheet_test_runner.dart';
import 'package:memo_care/dev/runners/onboarding_test_runner.dart';
import 'package:memo_care/dev/runners/profile_test_runner.dart';
import 'package:memo_care/dev/runners/schedule_test_runner.dart';
import 'package:memo_care/dev/runners/shell_global_test_runner.dart';
import 'package:memo_care/dev/runners/template_library_test_runner.dart';

/// Runs every screen runner and prints [HarnessLog.summaryFooter].
class MasterTestRunner {
  MasterTestRunner._();

  /// Execute after first frame (+ optional delay from caller).
  static Future<void> runAll(WidgetRef ref) async {
    if (!kDebugMode) return;

    HarnessLog.reset();
    HarnessLog.banner('🚀 MEMOCARE DEV HARNESS — MasterTestRunner');

    ShellGlobalTestRunner.runTests(ref);
    OnboardingTestRunner.runTests(ref);
    HomeTestRunner.runTests(ref);
    MissedSheetTestRunner.runTests(ref);
    ScheduleTestRunner.runTests(ref);
    await HistoryTestRunner.runTests(ref);
    ProfileTestRunner.runTests(ref);
    AddReminderTestRunner.runTests(ref);
    TemplateLibraryTestRunner.runTests(ref);
    await ChainContextTestRunner.runTests(ref);
    AlarmTestRunner.runTests(ref);
    KidsTestRunner.runTests(ref);

    HarnessLog.summaryFooter(totalTcs: 205);
  }
}
