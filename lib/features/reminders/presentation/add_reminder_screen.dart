import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/reminders/application/add_reminder_notifier.dart';
import 'package:memo_care/features/reminders/application/add_reminder_state.dart';
import 'package:memo_care/features/reminders/presentation/widgets/day_of_week_pills.dart';
import 'package:memo_care/features/reminders/presentation/widgets/dose_unit_fields.dart';
import 'package:memo_care/features/reminders/presentation/widgets/notes_textarea.dart';
import 'package:memo_care/features/reminders/presentation/widgets/reminder_mode_toggle.dart';
import 'package:memo_care/features/reminders/presentation/widgets/reminder_type_grid.dart';
import 'package:memo_care/features/reminders/presentation/widgets/time_mode_toggle.dart';

/// Full-screen form for adding a new reminder.
class AddReminderScreen extends ConsumerWidget {
  const AddReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addReminderNotifierProvider);
    final notifier = ref.read(addReminderNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Add Reminder',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.cardGap),

                  // Mode toggle — Say It / Build It
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: ReminderModeToggle(
                      isBuildIt: true, // Default to Build It
                      onChanged: (_) {
                        // Voice input feature — future phase
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sectionGap),

                  // Section: Type
                  const _SectionLabel('Type'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: ReminderTypeGrid(
                      selected: state.reminderType,
                      onSelected: notifier.setType,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sectionGap),

                  // Section: Name
                  const _SectionLabel('Name'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _hintForType(state.reminderType),
                        hintStyle: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary.withAlpha(128),
                        ),
                        filled: true,
                        fillColor: AppColors.cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.inputRadius,
                          ),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.inputRadius,
                          ),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.inputRadius,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.accent,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      style: AppTypography.bodyLarge,
                      onChanged: notifier.setName,
                    ),
                  ),

                  // Section: Dose & Unit (only for medicine type)
                  if (state.reminderType == ReminderType.medicine) ...[
                    const SizedBox(height: AppSpacing.sectionGap),
                    const _SectionLabel('Dose & Unit'),
                    const SizedBox(height: 8),
                    DoseUnitFields(
                      dose: state.dose,
                      unit: state.unit,
                      onDoseChanged: notifier.setDose,
                      onUnitChanged: notifier.setUnit,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sectionGap),

                  // Section: When
                  const _SectionLabel('When'),
                  const SizedBox(height: 8),
                  TimeModeToggle(
                    isFixedTime: state.timeMode == TimeMode.fixed,
                    selectedTime: state.fixedTime,
                    linkedEvent: state.linkedEvent,
                    offsetMinutes: state.offsetMinutes,
                    onChanged: (isFixed) {
                      notifier.setTimeMode(
                        isFixed ? TimeMode.fixed : TimeMode.linked,
                      );
                    },
                    onTimePicked: notifier.setFixedTime,
                    onEventChanged: notifier.setLinkedEvent,
                    onOffsetChanged: notifier.setOffsetMinutes,
                  ),

                  const SizedBox(height: AppSpacing.sectionGap),

                  // Section: Repeat Days
                  const _SectionLabel('Repeat Days'),
                  const SizedBox(height: 8),
                  DayOfWeekPills(
                    selectedDays: state.selectedDays,
                    onToggle: notifier.toggleDay,
                  ),

                  const SizedBox(height: AppSpacing.sectionGap),

                  // Section: Notes
                  const _SectionLabel('Notes'),
                  const SizedBox(height: 8),
                  NotesTextarea(
                    value: state.notes,
                    onChanged: notifier.setNotes,
                  ),

                  const SizedBox(height: AppSpacing.sectionGap),

                  // Chain link toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Add to Chain',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Link this reminder to another for sequential dosing',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: state.chainLink,
                      onChanged: (_) => notifier.toggleChainLink(),
                      activeThumbColor: AppColors.accent,
                    ),
                  ),

                  // Error message
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom save button
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              12,
              AppSpacing.screenHorizontal,
              32,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: FilledButton(
                onPressed: state.isValid && !state.isSaving
                    ? () async {
                        final success = await notifier.save(context);
                        if (success && context.mounted) {
                          context.pop();
                        }
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor: AppColors.accent.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.buttonRadius,
                    ),
                  ),
                ),
                child: state.isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save Reminder',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hintForType(ReminderType type) {
    return switch (type) {
      ReminderType.medicine => 'e.g., Metformin 500mg',
      ReminderType.meal => 'e.g., Breakfast',
      ReminderType.activity => 'e.g., Walk 30 min',
      ReminderType.call => 'e.g., Call Dr. Sharma',
      ReminderType.exercise => 'e.g., Morning stretch',
      ReminderType.custom => 'e.g., Blood pressure check',
    };
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
