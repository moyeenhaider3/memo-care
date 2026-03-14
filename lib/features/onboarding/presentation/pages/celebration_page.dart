import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/fasting/application/fasting_notifier.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/templates/application/template_providers.dart';
import 'package:memo_care/features/templates/domain/models/template_pack.dart';

/// Page 8 — Celebration / summary.
///
/// Creates the medication chain schedule (template or manual),
/// requests permissions, then navigates to the main dashboard
/// via [GoRouter].
class CelebrationPage extends ConsumerStatefulWidget {
  /// Creates a [CelebrationPage].
  const CelebrationPage({super.key});

  @override
  ConsumerState<CelebrationPage> createState() => _CelebrationPageState();
}

class _CelebrationPageState extends ConsumerState<CelebrationPage> {
  bool _isCreating = false;
  bool _done = false;

  String _formatTime(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${dh.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  String _conditionLabel(String? c) => switch (c) {
    'diabetes' => 'Diabetes',
    'blood_pressure' => 'Blood Pressure',
    'school_morning' => 'School Morning',
    _ => 'Manual Setup',
  };

  String _typeLabel(MedicineType t) => switch (t) {
    MedicineType.beforeMeal => 'Before Meal',
    MedicineType.afterMeal => 'After Meal',
    MedicineType.fixedTime => 'Fixed Time',
    MedicineType.doseGap => 'Dose Gap',
    MedicineType.emptyStomach => 'Empty Stomach',
  };

  Future<void> _finish() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);
    final state = ref.read(onboardingNotifierProvider);
    try {
      if (state.useTemplate && state.selectedTemplateId != null) {
        await _fromTemplate(state);
      } else {
        await _fromManual(state);
      }
    } on Exception catch (e) {
      _showError('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _fromTemplate(OnboardingState state) async {
    final svc = ref.read(templateServiceProvider);
    final repo = ref.read(templateRepositoryProvider);
    final fasting = ref.read(fastingNotifierProvider);
    final pack = repo.getById(state.selectedTemplateId!);
    if (pack == null) {
      _showError('Template not found. Please go back and try again.');
      return;
    }
    final overrides = <int, CustomMedicineEntry>{};
    for (var i = 0; i < state.customMedicines.length; i++) {
      overrides[i] = state.customMedicines[i];
    }
    final result = await svc.apply(
      pack: pack,
      userOverrides: overrides,
      mealAnchorTimes: state.mealAnchorDefaults,
      fastingModeActive: fasting.isActive,
      sehriTime: fasting.sehriTime,
      iftarTime: fasting.iftarTime,
    );
    result.match(
      (err) => _showError('Could not create schedule: ${err.message}'),
      (_) => _complete(),
    );
  }

  Future<void> _fromManual(OnboardingState state) async {
    final svc = ref.read(templateServiceProvider);
    final fasting = ref.read(fastingNotifierProvider);
    final meds = state.customMedicines
        .asMap()
        .entries
        .map(
          (e) => TemplateMedicine(
            name: e.value.name,
            medicineType: e.value.medicineType,
            chainPosition: e.key,
            defaultDosage: e.value.dosage,
            defaultTimeMinutes: e.value.timeMinutes,
            anchorMeal: e.value.anchorMeal != null
                ? TemplateMealType.values.firstWhere(
                    (t) => t.name == e.value.anchorMeal,
                    orElse: () => TemplateMealType.breakfast,
                  )
                : null,
          ),
        )
        .toList();
    final pack = TemplatePack(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      name: 'My Medications',
      description: 'Manually configured medications',
      condition: 'manual',
      medicines: meds,
      edges: const [],
    );
    final result = await svc.apply(
      pack: pack,
      mealAnchorTimes: state.mealAnchorDefaults,
      fastingModeActive: fasting.isActive,
      sehriTime: fasting.sehriTime,
      iftarTime: fasting.iftarTime,
    );
    result.match(
      (err) => _showError('Could not create schedule: ${err.message}'),
      (_) => _complete(),
    );
  }

  void _complete() {
    // Grant permissions (placeholder — real service wired in Phase 09-03)
    ref.read(onboardingNotifierProvider.notifier)
      ..setPermissionsGranted(granted: true)
      ..completeOnboarding();
    if (mounted) {
      setState(() => _done = true);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() => _isCreating = false);
    }
  }

  void _goToDashboard() {
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingNotifierProvider);

    if (_done) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'All set!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Success icon with celebration badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 64,
                              ),
                            ),
                            Positioned(
                              top: -12,
                              right: -12,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.celebration,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your profile is ready.',
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Let's head to your dashboard and add your "
                          'first reminder.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Summary card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Setup Summary',
                                    style: theme.textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _SummaryItem(
                                icon: Icons.person,
                                label:
                                    'Profile: ${_profileLabel(state.profileType)}',
                              ),
                              _SummaryItem(
                                icon: Icons.medical_information_outlined,
                                label:
                                    'Condition: ${_conditionLabel(state.selectedCondition)}',
                              ),
                              _SummaryItem(
                                icon: Icons.medication_outlined,
                                label:
                                    '${state.customMedicines.length} medicine'
                                    '${state.customMedicines.length == 1 ? '' : 's'} '
                                    'scheduled',
                              ),
                              if (state.caregiverPhone.isNotEmpty)
                                const _SummaryItem(
                                  icon: Icons.volunteer_activism,
                                  label: 'Caregiver invited',
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _goToDashboard,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Go to Dashboard'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Pre-celebration: schedule summary + confirm button
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Semantics(
                header: true,
                child: Text(
                  'Review Your Schedule',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _ReviewCard(
                    icon: Icons.medical_information,
                    title: 'Condition',
                    content: _conditionLabel(state.selectedCondition),
                  ),
                  if (state.useTemplate && state.selectedTemplateId != null)
                    _ReviewCard(
                      icon: Icons.playlist_add_check,
                      title: 'Template',
                      content: state.selectedTemplateId!
                          .replaceAll('_', ' ')
                          .split(' ')
                          .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
                          .join(' '),
                    ),
                  _ReviewCard(
                    icon: Icons.schedule,
                    title: 'Meal Times',
                    content: state.mealAnchorDefaults.entries
                        .map(
                          (e) =>
                              '${e.key[0].toUpperCase()}'
                              '${e.key.substring(1)}: '
                              '${_formatTime(e.value)}',
                        )
                        .join('\n'),
                  ),
                  _ReviewCard(
                    icon: Icons.medication_outlined,
                    title: 'Medicines',
                    content: state.customMedicines.isEmpty
                        ? 'None'
                        : state.customMedicines
                              .map(
                                (m) =>
                                    '• ${m.name}'
                                    '${m.dosage != null ? ' (${m.dosage})' : ''}'
                                    ' — ${_typeLabel(m.medicineType)}',
                              )
                              .join('\n'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Semantics(
                  button: true,
                  label: 'Confirm and create your medication schedule',
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _finish,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Text('Looks Good — Set It Up!'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _profileLabel(String? p) => switch (p) {
    'elderly' => 'Elderly',
    'adult' => 'Adult',
    'parent' => 'Parent',
    _ => 'Standard',
  };
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.content,
  });
  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(content, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
