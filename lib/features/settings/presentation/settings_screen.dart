import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:memo_care/features/settings/domain/models/app_settings.dart';

/// Settings screen for notification, snooze, and escalation
/// preferences (VIEW-05).
///
/// Sections:
/// 1. Notification Preferences — toggles
/// 2. Snooze & Escalation — sliders
///
/// All changes are immediately persisted to
/// `SharedPreferences` via `SettingsRepository`.
///
/// Accessibility:
/// - All text >= 18 pt
/// - Slider thumb >= 20 dp
/// - Switch touch targets >= 56 dp
/// - Semantics labels on all controls
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text(
            'Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Failed to load settings',
            style: theme.textTheme.bodyLarge,
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
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // ─── NOTIFICATION PREFERENCES ───
        const _SectionHeader(
          title: 'Notification Preferences',
        ),
        const SizedBox(height: 8),

        _SettingsSwitch(
          title: 'Notifications',
          subtitle: 'Enable medication reminders',
          value: settings.notificationsEnabled,
          onChanged: (v) => unawaited(
            repo.setNotificationsEnabled(enabled: v),
          ),
          semanticsLabel:
              'Notifications: '
              '${settings.notificationsEnabled ? "enabled" : "disabled"}',
        ),
        _SettingsSwitch(
          title: 'Sound',
          subtitle: 'Play alarm sound for reminders',
          value: settings.soundEnabled,
          onChanged: (v) => unawaited(
            repo.setSoundEnabled(enabled: v),
          ),
          semanticsLabel:
              'Sound: ${settings.soundEnabled ? "enabled" : "disabled"}',
        ),
        _SettingsSwitch(
          title: 'Vibration',
          subtitle: 'Vibrate on reminder notifications',
          value: settings.vibrationEnabled,
          onChanged: (v) => unawaited(
            repo.setVibrationEnabled(enabled: v),
          ),
          semanticsLabel:
              'Vibration: '
              '${settings.vibrationEnabled ? "enabled" : "disabled"}',
        ),

        const SizedBox(height: 24),

        // ─── SNOOZE & ESCALATION ───
        const _SectionHeader(
          title: 'Snooze & Escalation',
        ),
        const SizedBox(height: 8),

        _SettingsSlider(
          title: 'Snooze Duration',
          subtitle: '${settings.snoozeDurationMinutes} minutes',
          value: settings.snoozeDurationMinutes.toDouble(),
          min: 1,
          max: 15,
          divisions: 14,
          onChanged: (v) => unawaited(
            repo.setSnoozeDuration(v.round()),
          ),
          semanticsLabel:
              'Snooze duration: '
              '${settings.snoozeDurationMinutes} minutes. '
              'Drag to adjust between 1 and '
              '15 minutes.',
        ),

        _SettingsSlider(
          title: 'Silent → Audible Timeout',
          subtitle: '${settings.silentTimeoutMinutes} minutes',
          value: settings.silentTimeoutMinutes.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (v) => unawaited(
            repo.setSilentTimeout(v.round()),
          ),
          semanticsLabel:
              'Silent to audible escalation '
              'timeout: '
              '${settings.silentTimeoutMinutes} '
              'minutes. '
              'Drag to adjust between 1 and '
              '10 minutes.',
        ),

        _SettingsSlider(
          title: 'Audible → Full-Screen Timeout',
          subtitle: '${settings.audibleTimeoutMinutes} minutes',
          value: settings.audibleTimeoutMinutes.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (v) => unawaited(
            repo.setAudibleTimeout(v.round()),
          ),
          semanticsLabel:
              'Audible to full-screen escalation '
              'timeout: '
              '${settings.audibleTimeoutMinutes} '
              'minutes. '
              'Drag to adjust between 1 and '
              '10 minutes.',
        ),

        const SizedBox(height: 32),

        // App version
        Center(
          child: Text(
            'MemoCare v1.0',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Semantics(
        header: true,
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
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
    required this.semanticsLabel,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticsLabel,
      toggled: value,
      child: SwitchListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
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
    required this.semanticsLabel,
  });

  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Semantics(
            label: semanticsLabel,
            slider: true,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 12,
                ),
                trackHeight: 6,
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
          ),
        ],
      ),
    );
  }
}
