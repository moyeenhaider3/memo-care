import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/caregiver_service.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/fasting/application/fasting_notifier.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:memo_care/features/settings/domain/models/app_settings.dart';
import 'package:memo_care/features/settings/presentation/widgets/caregiver_section.dart';
import 'package:memo_care/features/settings/presentation/widgets/data_export_section.dart';
import 'package:memo_care/features/settings/presentation/widgets/display_settings_section.dart';
import 'package:memo_care/features/settings/presentation/widgets/fasting_toggle_tile.dart';
import 'package:memo_care/features/settings/presentation/widgets/profile_header.dart';

/// Revamped Settings & Profile screen (VIEW-05, 10-04).
///
/// Sections:
/// 1. Profile Header — avatar, name, badge
/// 2. Display Settings — text size, high contrast, dark mode
/// 3. Notification Preferences — toggles
/// 4. Snooze & Escalation — sliders
/// 5. Fasting Mode — gold accent toggle
/// 6. Caregiver — linked phone management
/// 7. Data Export — PDF/CSV
/// 8. App Info
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Failed to load settings',
            style: AppTypography.bodyLarge,
          ),
        ),
        data: (settings) => _SettingsBody(settings: settings),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(settingsRepositoryProvider);
    final fastingState = ref.watch(fastingNotifierProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ─── PROFILE HEADER ───
        const ProfileHeader(
          name: 'User',
          badge: 'Adult',
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        // ─── DISPLAY SETTINGS ───
        DisplaySettingsSection(
          textScale: 1,
          highContrast: false,
          darkMode: false,
          onTextScaleChanged: (_) {},
          onHighContrastChanged: (_) {},
          onDarkModeChanged: (_) {},
        ),

        const Divider(height: 32, indent: 16, endIndent: 16),

        // ─── NOTIFICATION PREFERENCES ───
        const _SectionHeader(title: 'Notifications'),
        const SizedBox(height: 8),

        _SettingsSwitch(
          title: 'Notifications',
          subtitle: 'Enable medication reminders',
          value: settings.notificationsEnabled,
          onChanged: (v) => unawaited(
            repo.setNotificationsEnabled(enabled: v),
          ),
        ),
        _SettingsSwitch(
          title: 'Sound',
          subtitle: 'Play alarm sound for reminders',
          value: settings.soundEnabled,
          onChanged: (v) => unawaited(
            repo.setSoundEnabled(enabled: v),
          ),
        ),
        _SettingsSwitch(
          title: 'Vibration',
          subtitle: 'Vibrate on reminder notifications',
          value: settings.vibrationEnabled,
          onChanged: (v) => unawaited(
            repo.setVibrationEnabled(enabled: v),
          ),
        ),

        const Divider(height: 32, indent: 16, endIndent: 16),

        // ─── SNOOZE & ESCALATION ───
        const _SectionHeader(title: 'Snooze & Escalation'),
        const SizedBox(height: 8),

        _SettingsSlider(
          title: 'Snooze Duration',
          subtitle: '${settings.snoozeDurationMinutes} min',
          value: settings.snoozeDurationMinutes.toDouble(),
          min: 1,
          max: 15,
          divisions: 14,
          onChanged: (v) => unawaited(
            repo.setSnoozeDuration(v.round()),
          ),
        ),
        _SettingsSlider(
          title: 'Silent → Audible',
          subtitle: '${settings.silentTimeoutMinutes} min',
          value: settings.silentTimeoutMinutes.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (v) => unawaited(
            repo.setSilentTimeout(v.round()),
          ),
        ),
        _SettingsSlider(
          title: 'Audible → Full-Screen',
          subtitle: '${settings.audibleTimeoutMinutes} min',
          value: settings.audibleTimeoutMinutes.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (v) => unawaited(
            repo.setAudibleTimeout(v.round()),
          ),
        ),

        const Divider(height: 32, indent: 16, endIndent: 16),

        // ─── FASTING MODE ───
        FastingToggleTile(
          enabled: fastingState.isActive,
          onChanged: (value) {
            ref.read(fastingNotifierProvider.notifier).setActive(active: value);
          },
        ),

        const Divider(height: 32, indent: 16, endIndent: 16),

        // ─── CAREGIVER ───
        CaregiverSection(
          caregiverPhone: settings.caregiverPhone.isEmpty
              ? null
              : settings.caregiverPhone,
          onAddCaregiver: () {
            // TODO: show phone input dialog
          },
          onRemoveCaregiver: () {
            unawaited(repo.setCaregiverPhone(''));
          },
          onSendTestAlert: () {
            if (settings.caregiverPhone.isNotEmpty) {
              unawaited(
                CaregiverService.sendTestAlert(
                  phoneNumber: settings.caregiverPhone,
                ),
              );
            }
          },
        ),

        const Divider(height: 32, indent: 16, endIndent: 16),

        // ─── DATA EXPORT ───
        DataExportSection(
          onExportPdf: () {
            // TODO: generate & share PDF
          },
          onExportCsv: () {
            // TODO: generate & share CSV
          },
        ),

        const SizedBox(height: 32),

        // ─── APP INFO ───
        Center(
          child: Text(
            'MemoCare v1.0',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ------------------------------------------------------------------
// Private helpers
// ------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
    );
  }
}

class _SettingsSlider extends StatelessWidget {
  const _SettingsSlider({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
              ),
              trackHeight: 6,
              activeTrackColor: AppColors.accent,
              thumbColor: AppColors.accent,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: '${value.round()} min',
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
