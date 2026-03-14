import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/templates/application/template_providers.dart';
import 'package:memo_care/features/templates/domain/models/template_pack.dart';

/// Page 3 — Template pack selection.
///
/// Filtered by the condition selected on Page 2. User can select
/// a pack or skip to manual setup.
class TemplatePage extends ConsumerWidget {
  /// Creates a [TemplatePage].
  const TemplatePage({
    required this.stepLabel,
    required this.onNext,
    super.key,
  });

  /// E.g. 'Step 3 of 7'.
  final String stepLabel;

  /// Called when a template is selected or "Skip" is tapped.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final templateRepo = ref.read(templateRepositoryProvider);

    final condition = onboardingState.selectedCondition ?? '';
    final packs = templateRepo.getByCondition(condition);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(stepLabel),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    'Choose a template',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Templates set up your medication schedule automatically. '
                  'You can customise everything afterwards.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                if (packs.isEmpty)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No templates available for this condition.',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  for (final pack in packs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TemplateCard(
                        pack: pack,
                        onSelect: () {
                          notifier.selectTemplate(pack.id);
                          onNext();
                        },
                      ),
                    ),
              ],
            ),
          ),

          // Skip button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  notifier.skipTemplate();
                  onNext();
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Skip — set up manually'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.pack, required this.onSelect});

  final TemplatePack pack;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '${pack.name}. ${pack.description}. Tap to use this template.',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.playlist_add_check,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pack.name,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                if (pack.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    pack.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${pack.medicines.length} medicine'
                  '${pack.medicines.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
