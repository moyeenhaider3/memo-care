import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';
import 'package:memo_care/features/templates/application/template_providers.dart';
import 'package:memo_care/features/templates/domain/models/template_pack.dart';

/// Step 2: Template pack selection.
///
/// Shows template packs matching the user's selected condition.
/// User can select a pack or skip to manual setup (ONBD-02).
class TemplatePickerScreen extends ConsumerWidget {
  /// Creates a [TemplatePickerScreen].
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onboardingState =
        ref.watch(onboardingNotifierProvider);
    final notifier =
        ref.read(onboardingNotifierProvider.notifier);
    final templateRepo =
        ref.read(templateRepositoryProvider);

    final condition =
        onboardingState.selectedCondition ?? '';
    final packs = templateRepo.getByCondition(condition);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            'Choose a template',
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Templates set up your medication schedule '
          'automatically. You can customise everything '
          'afterwards.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: packs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No templates available for this '
                        'condition.',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: packs.length,
                  itemBuilder: (context, index) {
                    final pack = packs[index];
                    return _TemplateCard(
                      pack: pack,
                      onSelect: () {
                        notifier
                          ..selectTemplate(pack.id)
                          ..goToStep(
                            OnboardingStep.anchors,
                          );
                        context.go(
                          '${AppRoutes.onboarding}/'
                          '${AppRoutes.anchors}',
                        );
                      },
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Semantics(
            button: true,
            label: 'Skip templates and set up medicines '
                'manually',
            child: TextButton.icon(
              onPressed: () {
                notifier
                  ..skipTemplate()
                  ..goToStep(OnboardingStep.anchors);
                context.go(
                  '${AppRoutes.onboarding}/'
                  '${AppRoutes.anchors}',
                );
              },
              icon: const Icon(Icons.skip_next),
              label: const Text(
                "Skip — I'll add medicines manually",
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Card displaying a single template pack.
class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.pack,
    required this.onSelect,
  });

  final TemplatePack pack;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '${pack.name} — ${pack.description}. '
          '${pack.medicines.length} medicines. '
          'Tap to select.',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.playlist_add_check,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pack.name,
                        style:
                            theme.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pack.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: pack.medicines
                      .map(
                        (m) => Chip(
                          label: Text(
                            m.name,
                            style: theme
                                .textTheme
                                .labelMedium,
                          ),
                          visualDensity:
                              VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onSelect,
                    child: const Text('Select'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
