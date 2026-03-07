import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';

/// Shell wrapper for onboarding step screens.
///
/// Provides a linear progress indicator showing current step, back
/// navigation (except on the first step), and consistent padding.
///
/// Used as the [ShellRoute] builder in [appRouterProvider].
class OnboardingFlow extends ConsumerWidget {
  /// Creates an [OnboardingFlow] wrapping [child].
  const OnboardingFlow({required this.child, super.key});

  /// The step screen rendered by the current route.
  final Widget child;

  /// Steps visible in the progress bar (excludes `complete`).
  static const List<OnboardingStep> _visibleSteps = [
    OnboardingStep.condition,
    OnboardingStep.template,
    OnboardingStep.anchors,
    OnboardingStep.medicines,
    OnboardingStep.review,
    OnboardingStep.permissions,
  ];

  /// Maps each step to its GoRouter path for back navigation.
  static const Map<OnboardingStep, String> _stepPaths = {
    OnboardingStep.condition:
        '${AppRoutes.onboarding}/${AppRoutes.condition}',
    OnboardingStep.template:
        '${AppRoutes.onboarding}/${AppRoutes.template}',
    OnboardingStep.anchors:
        '${AppRoutes.onboarding}/${AppRoutes.anchors}',
    OnboardingStep.medicines:
        '${AppRoutes.onboarding}/${AppRoutes.medicines}',
    OnboardingStep.review:
        '${AppRoutes.onboarding}/${AppRoutes.review}',
    OnboardingStep.permissions:
        '${AppRoutes.onboarding}/${AppRoutes.permissions}',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final currentIndex =
        _visibleSteps.indexOf(state.currentStep);
    final progress =
        (currentIndex + 1) / _visibleSteps.length;
    final isFirstStep = currentIndex <= 0;

    return Scaffold(
      appBar: AppBar(
        leading: isFirstStep
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 28,
                tooltip: 'Go back',
                constraints: const BoxConstraints(
                  minWidth: 56,
                  minHeight: 56,
                ),
                onPressed: () {
                  if (currentIndex > 0) {
                    final prevStep =
                        _visibleSteps[currentIndex - 1];
                    final prevPath = _stepPaths[prevStep];
                    if (prevPath != null) {
                      ref
                          .read(
                            onboardingNotifierProvider
                                .notifier,
                          )
                          .goToStep(prevStep);
                      context.go(prevPath);
                    }
                  }
                },
              ),
        title: Text(
          'Step ${currentIndex + 1} of ${_visibleSteps.length}',
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            semanticsLabel: 'Onboarding progress',
            semanticsValue:
                '${(progress * 100).round()}%',
          ),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
