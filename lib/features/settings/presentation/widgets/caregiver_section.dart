import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Caregiver management section: linked phone, add/remove, send test.
class CaregiverSection extends StatelessWidget {
  const CaregiverSection({
    required this.caregiverPhone,
    required this.onAddCaregiver,
    required this.onRemoveCaregiver,
    required this.onSendTestAlert,
    super.key,
  });

  /// Currently linked caregiver phone, null if none.
  final String? caregiverPhone;

  /// Called to add a new caregiver phone.
  final VoidCallback onAddCaregiver;

  /// Called to remove the current caregiver.
  final VoidCallback onRemoveCaregiver;

  /// Called to send a test alert to the caregiver.
  final VoidCallback onSendTestAlert;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'CAREGIVER',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
        ),
        if (caregiverPhone == null)
          _NoCaregiver(onAdd: onAddCaregiver)
        else
          _LinkedCaregiver(
            phone: caregiverPhone!,
            onRemove: onRemoveCaregiver,
            onSendTest: onSendTestAlert,
          ),
      ],
    );
  }
}

class _NoCaregiver extends StatelessWidget {
  const _NoCaregiver({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No caregiver linked',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add),
              label: Text(
                'Add Caregiver',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.accent,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedCaregiver extends StatelessWidget {
  const _LinkedCaregiver({
    required this.phone,
    required this.onRemove,
    required this.onSendTest,
  });
  final String phone;
  final VoidCallback onRemove;
  final VoidCallback onSendTest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 8,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.accentTeal,
              ),
            ),
            title: Text(
              phone,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Linked caregiver',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onSendTest,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                    ),
                    child: Text(
                      'Send Test Alert',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                    ),
                    child: Text(
                      'Remove',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
