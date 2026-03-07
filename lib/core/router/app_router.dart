import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/presentation/app_shell.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/presentation/anchor_step.dart';
import 'package:memo_care/features/onboarding/presentation/condition_step.dart';
import 'package:memo_care/features/onboarding/presentation/medicine_step.dart';
import 'package:memo_care/features/onboarding/presentation/onboarding_flow.dart';
import 'package:memo_care/features/onboarding/presentation/permission_step.dart';
import 'package:memo_care/features/onboarding/presentation/review_step.dart';
import 'package:memo_care/features/templates/presentation/template_picker_screen.dart';

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
  static const history = '/history';
  static const settings = '/settings';
}

/// Provides the [GoRouter] instance for the entire app.
///
/// Redirect guards ensure:
///  - Users who completed onboarding go to `/home`.
///  - Users who haven't completed onboarding go to
///    `/onboarding/condition`.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final onboardingState =
          ref.read(onboardingNotifierProvider);
      final isOnboarding =
          state.uri.path.startsWith(AppRoutes.onboarding);
      final isComplete = onboardingState.isComplete;

      if (isComplete && isOnboarding) {
        return AppRoutes.home;
      }

      if (!isComplete && !isOnboarding) {
        return '${AppRoutes.onboarding}/${AppRoutes.condition}';
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const Scaffold(
                  body: Center(
                    child: Text(
                      'Home Screen',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: 'history',
                builder: (context, state) => const Scaffold(
                  body: Center(
                    child: Text(
                      'History Screen',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: 'settings',
                builder: (context, state) => const Scaffold(
                  body: Center(
                    child: Text(
                      'Settings Screen',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // --- Onboarding flow ---
      ShellRoute(
        builder: (context, state, child) =>
            OnboardingFlow(child: child),
        routes: [
          GoRoute(
            path:
                '${AppRoutes.onboarding}/${AppRoutes.condition}',
            builder: (context, state) =>
                const ConditionStep(),
          ),
          GoRoute(
            path:
                '${AppRoutes.onboarding}/${AppRoutes.template}',
            builder: (context, state) =>
                const TemplatePickerScreen(),
          ),
          GoRoute(
            path:
                '${AppRoutes.onboarding}/${AppRoutes.anchors}',
            builder: (context, state) => const AnchorStep(),
          ),
          GoRoute(
            path:
                '${AppRoutes.onboarding}/${AppRoutes.medicines}',
            builder: (context, state) =>
                const MedicineStep(),
          ),
          GoRoute(
            path:
                '${AppRoutes.onboarding}/${AppRoutes.review}',
            builder: (context, state) => const ReviewStep(),
          ),
          GoRoute(
            path:
                '${AppRoutes.onboarding}/${AppRoutes.permissions}',
            builder: (context, state) =>
                const PermissionStep(),
          ),
        ],
      ),
    ],
  );
});
