import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';

/// Profile option data.
class _ProfileOption {
  const _ProfileOption({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String key;
  final String label;
  final String description;
  final IconData icon;
}

const _options = [
  _ProfileOption(
    key: 'elderly',
    label: 'Elderly',
    description: 'Optimised for ease of use',
    icon: Icons.elderly,
  ),
  _ProfileOption(
    key: 'adult',
    label: 'Adult',
    description: 'Manage your daily routine',
    icon: Icons.person,
  ),
  _ProfileOption(
    key: 'parent',
    label: 'Parent',
    description: 'Track for the whole family',
    icon: Icons.family_restroom,
  ),
];

/// Page 1 — Profile Type selection (Elderly / Adult / Parent).
class ProfileTypePage extends ConsumerWidget {
  /// Creates a [ProfileTypePage].
  const ProfileTypePage({
    required this.stepLabel,
    required this.onNext,
    super.key,
  });

  /// E.g. 'Step 1 of 7'.
  final String stepLabel;

  /// Called when "Continue" is pressed.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final selected = state.profileType;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(stepLabel),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      'Set up for you',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the profile that best fits your needs.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  for (final opt in _options) ...[
                    Semantics(
                      button: true,
                      selected: selected == opt.key,
                      label: '${opt.label}: ${opt.description}',
                      child: GestureDetector(
                        onTap: () => notifier.setProfileType(opt.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected == opt.key
                                  ? primary
                                  : theme.colorScheme.outlineVariant,
                              width: selected == opt.key ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: selected == opt.key
                                      ? primary.withValues(alpha: 0.1)
                                      : theme.colorScheme.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  opt.icon,
                                  color: selected == opt.key
                                      ? primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.label,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      opt.description,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected == opt.key)
                                Icon(
                                  Icons.check_circle,
                                  color: primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selected != null ? onNext : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
