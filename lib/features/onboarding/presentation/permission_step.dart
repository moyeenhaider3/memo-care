import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/platform/permission_service.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';

/// Internal permission info for display.
class _PermissionInfo {
  const _PermissionInfo({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String key;
  final String title;
  final String description;
  final IconData icon;
}

/// Step 6: Batch permission requests (ONBD-03).
///
/// Requests all required OS permissions in one screen:
/// - POST_NOTIFICATIONS (Android 13+)
/// - SCHEDULE_EXACT_ALARM (Android 12+)
/// - REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
///
/// Each permission is shown with an explanation of why it's
/// needed. Users can skip and continue with degraded
/// experience.
class PermissionStep extends ConsumerStatefulWidget {
  /// Creates a [PermissionStep].
  const PermissionStep({super.key});

  @override
  ConsumerState<PermissionStep> createState() =>
      _PermissionStepState();
}

class _PermissionStepState
    extends ConsumerState<PermissionStep> {
  bool _notificationsGranted = false;
  bool _exactAlarmGranted = false;
  bool _batteryOptimizationGranted = false;
  bool _isRequesting = false;

  static const List<_PermissionInfo> _permissions = [
    _PermissionInfo(
      key: 'notifications',
      title: 'Notifications',
      description: 'So we can remind you to take your '
          'medicine on time.',
      icon: Icons.notifications_active,
    ),
    _PermissionInfo(
      key: 'exact_alarm',
      title: 'Exact Alarms',
      description: 'To ring at the exact scheduled time, '
          'even when your phone is idle.',
      icon: Icons.alarm,
    ),
    _PermissionInfo(
      key: 'battery',
      title: 'Battery Optimization',
      description: 'To prevent your phone from silencing '
          'reminders in the background.',
      icon: Icons.battery_saver,
    ),
  ];

  bool _isGranted(String key) {
    return switch (key) {
      'notifications' => _notificationsGranted,
      'exact_alarm' => _exactAlarmGranted,
      'battery' => _batteryOptimizationGranted,
      _ => false,
    };
  }

  bool get _allGranted =>
      _notificationsGranted &&
      _exactAlarmGranted &&
      _batteryOptimizationGranted;

  Future<void> _requestAll() async {
    setState(() => _isRequesting = true);

    try {
      if (!kIsWeb && Platform.isAndroid) {
        final permService = PermissionService();
        final result = await permService.requestAllMissing();
        if (mounted) {
          setState(() {
            _notificationsGranted = result.notifications;
            _exactAlarmGranted = result.exactAlarms;
            _batteryOptimizationGranted = result.batteryOptimization;
          });
        }
      } else {
        // Non-Android platforms: mark as granted (permissions
        // are handled differently on iOS).
        setState(() {
          _notificationsGranted = true;
          _exactAlarmGranted = true;
          _batteryOptimizationGranted = true;
        });
      }

      ref
          .read(onboardingNotifierProvider.notifier)
          .setPermissionsGranted(granted: _allGranted);
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  void _completeOnboarding() {
    ref
        .read(onboardingNotifierProvider.notifier)
        .completeOnboarding();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Allow Permissions',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'MemoCare needs a few permissions to remind '
          'you on time. You can change these later in '
          'settings.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: _permissions
                .map((perm) => _PermissionCard(
                      info: perm,
                      granted: _isGranted(perm.key),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (!_allGranted) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _isRequesting ? null : _requestAll,
              child: _isRequesting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Grant All Permissions'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Semantics(
              button: true,
              label: 'Skip permissions and continue. '
                  'Some features may not work properly.',
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip for now'),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    theme.colorScheme.primary,
                foregroundColor:
                    theme.colorScheme.onPrimary,
              ),
              child: const Text("All Set — Let's Go!"),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.info,
    required this.granted,
  });

  final _PermissionInfo info;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${info.title}: ${info.description}. '
          '${granted ? "Granted" : "Not granted yet"}.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                info.icon,
                size: 36,
                color: granted
                    ? theme.colorScheme.primary
                    : theme
                        .colorScheme
                        .onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            info.title,
                            style: theme
                                .textTheme
                                .titleSmall,
                          ),
                        ),
                        if (granted)
                          Icon(
                            Icons.check_circle,
                            color: theme
                                .colorScheme
                                .primary,
                            size: 28,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style:
                          theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
