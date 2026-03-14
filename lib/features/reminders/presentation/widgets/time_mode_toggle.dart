import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Time mode toggle: "Fixed Time" / "Linked to Event".
class TimeModeToggle extends StatelessWidget {
  const TimeModeToggle({
    required this.isFixedTime,
    required this.onChanged,
    required this.selectedTime,
    required this.onTimePicked,
    this.linkedEvent,
    this.onEventChanged,
    this.offsetMinutes = 0,
    this.onOffsetChanged,
    super.key,
  });

  final bool isFixedTime;
  final ValueChanged<bool> onChanged;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimePicked;
  final String? linkedEvent;
  final ValueChanged<String>? onEventChanged;
  final int offsetMinutes;
  final ValueChanged<int>? onOffsetChanged;

  static const _events = [
    'Before Breakfast',
    'After Breakfast',
    'Before Lunch',
    'After Lunch',
    'Before Dinner',
    'After Dinner',
    'Bedtime',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode toggle
          Row(
            children: [
              Expanded(
                child: _ToggleOption(
                  label: 'Fixed Time',
                  isSelected: isFixedTime,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ToggleOption(
                  label: 'Linked to Event',
                  isSelected: !isFixedTime,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content based on mode
          if (isFixedTime)
            _FixedTimeInput(
              time: selectedTime,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                );
                if (picked != null) onTimePicked(picked);
              },
            )
          else
            _LinkedEventInput(
              selectedEvent: linkedEvent,
              events: _events,
              onEventChanged: onEventChanged ?? (_) {},
              offset: offsetMinutes,
              onOffsetChanged: onOffsetChanged ?? (_) {},
            ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FixedTimeInput extends StatelessWidget {
  const _FixedTimeInput({required this.time, required this.onTap});
  final TimeOfDay? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.accent, size: 20),
            const SizedBox(width: 12),
            Text(
              time != null ? time!.format(context) : 'Select time',
              style: AppTypography.bodyLarge.copyWith(
                color: time != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkedEventInput extends StatelessWidget {
  const _LinkedEventInput({
    required this.selectedEvent,
    required this.events,
    required this.onEventChanged,
    required this.offset,
    required this.onOffsetChanged,
  });

  final String? selectedEvent;
  final List<String> events;
  final ValueChanged<String> onEventChanged;
  final int offset;
  final ValueChanged<int> onOffsetChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedEvent,
          items: events
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) onEventChanged(v);
          },
          decoration: InputDecoration(
            labelText: 'Event',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Offset:',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '$offset'),
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed != null) onOffsetChanged(parsed);
                },
                decoration: InputDecoration(
                  suffixText: 'min',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.inputRadius),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
