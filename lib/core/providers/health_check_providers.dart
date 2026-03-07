import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/channel_health_checker.dart';
import 'package:memo_care/core/providers/notification_providers.dart';

/// Provides the [ChannelHealthChecker] instance.
///
/// Uses a manual [Provider] (not @Riverpod code-gen) because
/// riverpod_generator was dropped due to analyzer version
/// conflicts with drift_dev.
final channelHealthCheckerProvider =
    Provider<ChannelHealthChecker>((ref) {
  final notifService = ref.watch(notificationServiceProvider);
  return ChannelHealthChecker(plugin: notifService.plugin);
});

/// Provides the current channel health status.
///
/// Invalidate this provider on `AppLifecycleState.resumed`
/// to re-check:
///
/// ```dart
/// if (state == AppLifecycleState.resumed) {
///   ref.invalidate(channelHealthStatusProvider);
/// }
/// ```
final channelHealthStatusProvider =
    FutureProvider<ChannelHealthStatus>((ref) async {
  final checker = ref.watch(channelHealthCheckerProvider);
  return checker.check();
});
