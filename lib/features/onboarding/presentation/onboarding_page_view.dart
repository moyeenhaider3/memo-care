import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:memo_care/features/onboarding/presentation/pages/accessibility_page.dart';
import 'package:memo_care/features/onboarding/presentation/pages/anchors_page.dart';
import 'package:memo_care/features/onboarding/presentation/pages/caregiver_page.dart';
import 'package:memo_care/features/onboarding/presentation/pages/celebration_page.dart';
import 'package:memo_care/features/onboarding/presentation/pages/condition_page.dart';
import 'package:memo_care/features/onboarding/presentation/pages/medicines_page.dart';
import 'package:memo_care/features/onboarding/presentation/pages/profile_type_page.dart';
import 'package:memo_care/features/onboarding/presentation/pages/template_page.dart';
import 'package:memo_care/features/onboarding/presentation/pages/welcome_page.dart';

/// Total number of onboarding pages.
const _kPageCount = 9;

/// Page index constants.
const _kWelcome = 0;
const _kProfile = 1;
const _kCondition = 2;
const _kTemplate = 3;
const _kAnchors = 4;
const _kMedicines = 5;
const _kAccessibility = 6;
const _kCaregiver = 7;
const _kCelebration = 8;

/// The merged 9-step onboarding experience.
///
/// Presented as a single [PageView] — no nested router routes.
/// Each step uses a callback to advance or jump the controller.
///
/// Step labels (shown in AppBar of each page):
///   Page 1 ProfileType  → Step 1 of 7
///   Page 2 Condition    → Step 2 of 7
///   Page 3 Template     → Step 3 of 7
///   Page 4 Anchors      → Step 4 of 7
///   Page 5 Medicines    → Step 5 of 7
///   Page 6 Accessibility→ Step 6 of 7
///   Page 7 Caregiver    → Step 7 of 7
///   (Welcome & Celebration have no step label)
class OnboardingPageView extends ConsumerStatefulWidget {
  /// Creates an [OnboardingPageView].
  const OnboardingPageView({super.key});

  @override
  ConsumerState<OnboardingPageView> createState() =>
      _OnboardingPageViewState();
}

class _OnboardingPageViewState extends ConsumerState<OnboardingPageView> {
  late final PageController _ctrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _ctrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _next() => _goTo(_current + 1);

  String _stepLabel(int step) => 'Step $step of 7';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _ctrl,
            // Disable swipe to prevent accidental navigation on
            // the Welcome gradient screen.
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _current = i),
            children: [
              // 0 — Welcome
              WelcomePage(onGetStarted: _next),

              // 1 — Profile Type
              ProfileTypePage(
                stepLabel: _stepLabel(1),
                onNext: _next,
              ),

              // 2 — Condition
              ConditionPage(
                stepLabel: _stepLabel(2),
                onNext: _next, // → Template page
                onSkipTemplate: () => _goTo(_kAnchors), // skip Template
              ),

              // 3 — Template
              TemplatePage(
                stepLabel: _stepLabel(3),
                onNext: () => _goTo(_kAnchors),
              ),

              // 4 — Anchors
              AnchorsPage(
                stepLabel: _stepLabel(4),
                onNext: _next,
              ),

              // 5 — Medicines
              MedicinesPage(
                stepLabel: _stepLabel(5),
                onNext: _next,
              ),

              // 6 — Accessibility
              AccessibilityPage(
                stepLabel: _stepLabel(6),
                onNext: ({required largeText, required highContrast}) {
                  final repo = ref.read(settingsRepositoryProvider);
                  unawaited(repo.setLargeText(largeText));
                  unawaited(repo.setHighContrast(highContrast));
                  _next();
                },
              ),

              // 7 — Caregiver
              CaregiverPage(
                stepLabel: _stepLabel(7),
                onNext: _next,
              ),

              // 8 — Celebration
              const CelebrationPage(),
            ],
          ),

          // Dot indicators (hidden on Welcome page and Celebration page)
          if (_current != _kWelcome && _current != _kCelebration)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _DotIndicator(
                total: _kPageCount - 2, // 7 visible dots (pages 1-7)
                current: _current - 1, // offset by 1 (skip Welcome)
              ),
            ),
        ],
      ),
    );
  }
}

/// A row of animated dot indicators.
class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final isActive = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? primary : primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
