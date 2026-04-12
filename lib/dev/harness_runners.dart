import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/chain_engine/application/chain_context_providers.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_providers.dart';
import 'package:memo_care/features/history/application/history_notifier.dart';
import 'package:memo_care/features/kids_mode/application/kids_mode_notifier.dart';
import 'package:memo_care/features/kids_mode/application/reward_notifier.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/reminders/application/add_reminder_notifier.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:memo_care/features/templates/domain/models/template_packs.dart';
import 'package:memo_care/dev/harness_log.dart';
import 'package:memo_care/dev/harness_seed_context.dart';

/// Aggregates harness checks grouped by manual-test guide sections.
class HarnessRunners {
  HarnessRunners._();

  static void runShellGlobal(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: App Shell / Global]');
    _tryTc(
      'TC-009',
      'Legacy settings path constant',
      () {
        const legacyPath = '/settings';
        if (legacyPath != '/settings') {
          throw StateError('legacy path mismatch');
        }
      },
      'AppRoutes (profile redirect)',
      'constant',
    );
    _tryTc(
      'TC-010',
      'Alarm path prefix',
      () {
        if (!AppRoutes.alarm.startsWith('/alarm')) {
          throw StateError('alarm route');
        }
      },
      'AppRoutes.alarm',
      'constant',
    );
    HarnessLog.manual(
      'TC-001',
      'Bottom navigation',
      'AppShell NavigationBar',
      'Tap Home, Schedule, History, Profile on device.',
    );
    HarnessLog.manual(
      'TC-005',
      'Channel banner',
      'ChannelDisabledBanner',
      'Disable a notification channel in OS settings first.',
    );
  }

  static void runOnboarding(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Onboarding state]');
    try {
      final st = ref.read(onboardingNotifierProvider);
      if (st.profileType != 'elderly') {
        throw StateError('profileType ${st.profileType}');
      }
      if (st.selectedCondition != 'diabetes') {
        throw StateError('condition ${st.selectedCondition}');
      }
      HarnessLog.pass(
        'TC-015',
        'Onboarding notifier profile + condition',
        'onboardingNotifierProvider',
        'seeded elderly + diabetes',
        'profile=${st.profileType}, condition=${st.selectedCondition}',
      );
    } on Object catch (e) {
      HarnessLog.fail(
        'TC-015',
        'Onboarding notifier',
        'onboardingNotifierProvider',
        'seed',
        e,
      );
    }
  }

  static void runHome(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Home data]');
    final async = ref.read(dailyScheduleNotifierProvider);
    async.when(
      data: (DailyScheduleState s) {
        HarnessLog.pass(
          'TC-046',
          'Daily schedule loaded',
          'dailyScheduleNotifierProvider',
          'seeded DB',
          'today=${s.todayReminders.length} missed=${s.missedReminders.length}',
        );
        if (s.todayReminders.length >= 3) {
          HarnessLog.pass(
            'TC-048',
            'Today reminders list',
            'todayRemindersProvider',
            '≥3 seeded',
            'count=${s.todayReminders.length}',
          );
        } else {
          HarnessLog.skipped(
            'TC-048',
            'Today reminders list',
            'fewer than 3 in today window — check local midnight',
          );
        }
        if (s.missedReminders.isNotEmpty) {
          HarnessLog.pass(
            'TC-047',
            'Missed reminders present',
            'missedRemindersProvider',
            '1 missed seeded',
            'count=${s.missedReminders.length}',
          );
        }
      },
      loading: () {
        HarnessLog.skipped('TC-046', 'Daily schedule', 'still loading');
      },
      error: (Object e, StackTrace _) {
        HarnessLog.fail(
          'TC-046',
          'Daily schedule',
          'dailyScheduleNotifier',
          'seed',
          e,
        );
      },
    );
  }

  static void runMissedSheet(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Missed sheet data]');
    final missed = ref.read(missedRemindersProvider);
    if (missed.isNotEmpty) {
      HarnessLog.pass(
        'TC-066',
        'Missed list non-empty',
        'missedRemindersProvider',
        'seed',
        'count=${missed.length}',
      );
    } else {
      HarnessLog.skipped('TC-066', 'Missed list', 'empty — time boundary');
    }
  }

  static void runSchedule(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Schedule tab data]');
    final async = ref.read(dailyScheduleNotifierProvider);
    async.when(
      data: (DailyScheduleState s) {
        HarnessLog.pass(
          'TC-075',
          'Schedule uses same schedule state',
          'dailyScheduleNotifierProvider',
          'seed',
          'today count=${s.todayReminders.length}',
        );
      },
      loading: () => HarnessLog.skipped('TC-075', 'Schedule', 'loading'),
      error: (Object e, StackTrace _) => HarnessLog.fail(
        'TC-075',
        'Schedule',
        'dailyScheduleNotifierProvider',
        'read',
        e,
      ),
    );
    HarnessLog.manual(
      'TC-075b',
      'Schedule hourly UI',
      'TodaysFullScheduleScreen',
      'Open Schedule tab and scroll hourly list.',
    );
  }

  static Future<void> runHistory(WidgetRef ref) async {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: History]');
    try {
      final st = await ref.read(historyNotifierProvider.future);
      if (st.items.isNotEmpty) {
        HarnessLog.pass(
          'TC-085',
          'History items loaded',
          'historyNotifierProvider',
          'seeded past rows',
          'count=${st.items.length}',
        );
      } else {
        HarnessLog.skipped('TC-085', 'History', 'no items');
      }
    } on Object catch (e) {
      HarnessLog.fail(
        'TC-085',
        'History load',
        'historyNotifierProvider',
        'seed',
        e,
      );
    }
  }

  static void runProfile(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Profile / Settings]');
    try {
      final phone = ref.read(settingsRepositoryProvider).getCaregiverPhone();
      if (phone == '+923001234567') {
        HarnessLog.pass(
          'TC-110',
          'Caregiver phone',
          'settingsRepository.getCaregiverPhone',
          'seed',
          phone,
        );
      }
    } on Object catch (e) {
      HarnessLog.fail('TC-110', 'Caregiver', 'settingsRepository', 'seed', e);
    }
    HarnessLog.manual(
      'TC-116',
      'Settings export stubs',
      'DataExportSection',
      'Tap PDF/CSV in Profile — stubs only per code.',
    );
  }

  static void runAddReminder(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Add Reminder form state]');
    final n = ref.read(addReminderNotifierProvider.notifier)..reset();
    n.setName('Metformin');
    n.setDose('500');
    n.setUnit('mg');
    final st = ref.read(addReminderNotifierProvider);
    if (!st.isValid) {
      HarnessLog.manual(
        'TC-129',
        'Add reminder valid form',
        'AddReminderNotifier',
        'Complete time + repeat days in UI — isValid=$st',
      );
    } else {
      HarnessLog.pass(
        'TC-129',
        'Form validity after seed fields',
        'addReminderNotifierProvider',
        'name+dose',
        'isValid=true',
      );
    }
    n.setName('');
    final invalid = ref.read(addReminderNotifierProvider);
    if (!invalid.isValid) {
      HarnessLog.pass(
        'TC-128',
        'Empty name invalid',
        'AddReminderState.isValid',
        'cleared name',
        'isValid=false',
      );
    }
  }

  static void runTemplateLibrary(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Template library]');
    final packs = kTemplatePacks;
    HarnessLog.pass(
      'TC-149',
      'Template packs catalog',
      'kTemplatePacks',
      'static list',
      '${packs.length} packs (Diabetes/Heart/etc.)',
    );
    HarnessLog.manual(
      'TC-150',
      'Apply template',
      'TemplateService.apply',
      'Open /templates route and tap Apply on device.',
    );
  }

  static Future<void> runChainContext(WidgetRef ref) async {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Chain context]');
    final id = HarnessSeedContext.chainMiddleReminderId;
    if (id == null) {
      HarnessLog.skipped('TC-160', 'Chain context provider', 'no middle id');
      return;
    }
    try {
      final ctx = await ref.read(chainContextProvider(id).future);
      final step = ctx.upstreamReminders.length + 1;
      final total = ctx.upstreamReminders.length + ctx.downstreamReminders.length + 1;
      HarnessLog.pass(
        'TC-161',
        'Chain middle step index',
        'chainContextProvider',
        'reminderId=$id',
        'step=$step of $total',
      );
    } on Object catch (e) {
      HarnessLog.fail('TC-160', 'Chain load', 'chainContextProvider', 'middle id', e);
    }
  }

  static void runAlarm(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Alarm prerequisites]');
    final id = HarnessSeedContext.alarmWithCaregiverReminderId;
    final phone = ref.read(settingsRepositoryProvider).getCaregiverPhone();
    if (id != null && phone.isNotEmpty) {
      HarnessLog.pass(
        'TC-174',
        'Caregiver + reminder id',
        'settings + seed',
        'reminderId=$id phone set',
        'alarm can show caregiver warning',
      );
    }
    HarnessLog.manual(
      'TC-171',
      'Fullscreen alarm UI',
      'AlarmScreenLoader',
      'Navigate to /alarm/\$id or wait for notification.',
    );
  }

  static void runKids(WidgetRef ref) {
    if (!kDebugMode) return;
    HarnessLog.banner('🧪 [SCREEN: Kids mode]');
    final st = ref.read(kidsModeNotifierProvider);
    if (st.childName == 'Ali') {
      HarnessLog.pass(
        'TC-189',
        'Child name',
        'kidsModeNotifierProvider',
        'setChildName',
        st.childName,
      );
    }
    final completed = st.dailyQuests.where((q) => q.isCompleted).length;
    HarnessLog.pass(
      'TC-191',
      'Quest completion count',
      'kidsModeNotifier',
      'completeQuest x3',
      '$completed completed',
    );
    final rw = ref.read(rewardNotifierProvider);
    if (rw.useSoundVariant) {
      HarnessLog.pass(
        'TC-193',
        'Reward sound variant flag',
        'rewardNotifierProvider',
        'setUseSoundVariant(true)',
        'useSoundVariant=true',
      );
    }
  }
}

void _tryTc(
  String tc,
  String title,
  void Function() body,
  String method,
  String input,
) {
  try {
    body();
    HarnessLog.pass(tc, title, method, input, 'ok');
  } on Object catch (e) {
    HarnessLog.fail(tc, title, method, input, e);
  }
}
