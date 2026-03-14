import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/presentation/app_shell.dart';
import 'package:memo_care/features/daily_schedule/presentation/chain_context_screen.dart';
import 'package:memo_care/features/daily_schedule/presentation/home_screen.dart';
import 'package:memo_care/features/daily_schedule/presentation/todays_full_schedule_screen.dart';
import 'package:memo_care/features/history/presentation/history_screen.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/presentation/anchor_step.dart';
import 'package:memo_care/features/onboarding/presentation/condition_step.dart';
import 'package:memo_care/features/onboarding/presentation/medicine_step.dart';
import 'package:memo_care/features/onboarding/presentation/onboarding_flow.dart';
import 'package:memo_care/features/onboarding/presentation/onboarding_page_view.dart';
import 'package:memo_care/features/onboarding/presentation/permission_step.dart';
import 'package:memo_care/features/onboarding/presentation/review_step.dart';
import 'package:memo_care/features/reminders/presentation/add_reminder_screen.dart';
import 'package:memo_care/features/settings/presentation/settings_screen.dart';
import 'package:memo_care/features/templates/presentation/template_library_screen.dart';
import 'package:memo_care/features/templates/presentation/template_picker_screen.dart';
import 'package:memo_care/features/fasting/presentation/ramadan_screen.dart';
import 'package:memo_care/features/kids_mode/presentation/kids_dashboard_screen.dart';
import 'package:memo_care/features/kids_mode/presentation/kids_reward_screen.dart';
import 'package:memo_care/features/kids_mode/presentation/kids_reward_sound_screen.dart';

/// Route path constants used across the app.
abstract final class AppRoutes {
  /// Onboarding root path.
  static const onboarding = '/onboarding';

  /// Onboarding sub-paths (relative).
  static const condition = 'condition';
  static const template = 'template';
  static const anchors = 'anchors';
  static const medicines = 'medicines';
  static const review = 'review';
  static const permissions = 'permissions';

  /// Post-onboarding tab paths.
  static const home = '/home';
  static const schedule = '/schedule';
  static const history = '/history';
  static const profile = '/profile';

  /// Standalone routes.
  static const addReminder = '/add-reminder';
  static const templates = '/templates';
  /// Kids Mode route.
  static const kids = '/kids';
  static const kidsReward = '/kids/reward';
  static const kidsRewardSound = '/kids/reward-sound';

  /// Ramadan / Fasting Mode route.
  static const ramadan = '/ramadan';
  /// Legacy alias — redirects to /profile.
  @Deprecated('Use AppRoutes.profile')
  static const settings = '/settings';
}

/// Provides the [GoRouter] instance for the entire app.
///
/// Navigation structure (post-10-01):
///  - 4 shell branches: /home, /schedule, /history, /profile
///  - Standalone: /add-reminder (triggered by FAB)
///  - Chain context detail (no bottom nav)
///  - Onboarding flow (no bottom nav)
///
/// Redirect guards ensure:
///  - Users who completed onboarding go to `/home`.
///  - Users who haven't completed onboarding go to
///    `/onboarding/condition`.
///  - `/settings` redirects to `/profile`.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final onboardingState = ref.read(onboardingNotifierProvider);
      final isOnboarding = state.uri.path.startsWith(AppRoutes.onboarding);
      final isComplete = onboardingState.isComplete;

      // Legacy /settings → /profile redirect.
      if (state.uri.path == AppRoutes.settings) {
        return AppRoutes.profile;
      }

      if (isComplete && isOnboarding) {
        return AppRoutes.home;
      }

      if (!isComplete && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      return null;
    },
    routes: [
      // --- Main app tabs (post-onboarding) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1 — Schedule
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.schedule,
                name: 'schedule',
                builder: (context, state) =>
                    const TodaysFullScheduleScreen(),
              ),
            ],
          ),
          // Branch 2 — History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          // Branch 3 — Profile (was Settings)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // --- Add Reminder (standalone, no bottom nav) ---
      GoRoute(
        path: AppRoutes.addReminder,
        name: 'addReminder',
        builder: (context, state) => const AddReminderScreen(),
      ),

      // --- Template Library (standalone, no bottom nav) ---
      GoRoute(
        path: AppRoutes.templates,
        name: 'templates',
        builder: (context, state) => const TemplateLibraryScreen(),
      ),

      // --- Chain context detail (no bottom nav) ---
      GoRoute(
        path: '/reminder/:id/chain',
        name: 'chainContext',
        builder: (context, state) {
          final id = int.parse(
            state.pathParameters['id']!,
          );
          return ChainContextScreen(
            reminderId: id,
          );
        },
      ),

      // --- Onboarding (new PageView-based flow, Phase 10-09) ---
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPageView(),
      ),

      // --- Legacy onboarding sub-routes (kept for backward compat) ---
      ShellRoute(
        builder: (context, state, child) => OnboardingFlow(child: child),
        routes: [
          GoRoute(
            path: '${AppRoutes.onboarding}/${AppRoutes.condition}',
            builder: (context, state) => const ConditionStep(),
          ),
          GoRoute(
            path: '${AppRoutes.onboarding}/${AppRoutes.template}',
            builder: (context, state) => const TemplatePickerScreen(),
          ),
          GoRoute(
            path: '${AppRoutes.onboarding}/${AppRoutes.anchors}',
            builder: (context, state) => const AnchorStep(),
          ),
          GoRoute(
            path: '${AppRoutes.onboarding}/${AppRoutes.medicines}',
            builder: (context, state) => const MedicineStep(),
          ),
          GoRoute(
            path: '${AppRoutes.onboarding}/${AppRoutes.review}',
            builder: (context, state) => const ReviewStep(),
          ),
          GoRoute(
            path: '${AppRoutes.onboarding}/${AppRoutes.permissions}',
            builder: (context, state) => const PermissionStep(),
          ),
        ],
      ),

      // --- Kids Mode (standalone, no main bottom nav) ---
      GoRoute(
        path: AppRoutes.kids,
        name: 'kids',
        builder: (context, state) => const KidsDashboardScreen(),
      ),

      GoRoute(
        path: AppRoutes.kidsReward,
        name: 'kidsReward',
        builder: (context, state) => const KidsRewardScreen(),
      ),

      GoRoute(
        path: AppRoutes.kidsRewardSound,
        name: 'kidsRewardSound',
        builder: (context, state) => const KidsRewardSoundScreen(),
      ),

      // --- Ramadan/Fasting Mode (standalone, no main bottom nav) ---
      GoRoute(
        path: AppRoutes.ramadan,
        name: 'ramadan',
        builder: (context, state) => const RamadanScreen(),
      ),
    ],
  );
});
