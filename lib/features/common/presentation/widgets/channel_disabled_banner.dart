import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/providers/health_check_providers.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// Non-dismissable banner shown when notification channels are
/// disabled.
///
/// Place this at the top of your scaffold body (e.g., in a
/// [Column] before the main content). It auto-hides when all
/// channels are healthy.
///
/// Tapping **FIX NOW** opens the system notification settings
/// for the app.
class ChannelDisabledBanner extends ConsumerWidget {
  /// Creates a [ChannelDisabledBanner].
  const ChannelDisabledBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(channelHealthStatusProvider);

    return healthAsync.when(
      data: (status) {
        if (status.isHealthy) return const SizedBox.shrink();

        return MaterialBanner(
          backgroundColor: AppColors.danger,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Medication reminders may not work',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              for (final issue in status.issues)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '• $issue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          leading: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 32,
          ),
          actions: [
            TextButton(
              onPressed: openAppSettings,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'FIX NOW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
