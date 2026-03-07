import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memo_care/core/constants/notification_channels.dart';

/// Health status of notification channels.
class ChannelHealthStatus {
  /// Creates a [ChannelHealthStatus].
  const ChannelHealthStatus({
    required this.notificationsEnabled,
    required this.silentChannelEnabled,
    required this.urgentChannelEnabled,
    required this.criticalChannelEnabled,
  });

  /// All channels healthy — no banner needed.
  const ChannelHealthStatus.allHealthy()
    : notificationsEnabled = true,
      silentChannelEnabled = true,
      urgentChannelEnabled = true,
      criticalChannelEnabled = true;

  /// Whether notifications are globally enabled for the app.
  final bool notificationsEnabled;

  /// Whether the silent notification channel is enabled.
  final bool silentChannelEnabled;

  /// Whether the urgent notification channel is enabled.
  final bool urgentChannelEnabled;

  /// Whether the critical notification channel is enabled.
  final bool criticalChannelEnabled;

  /// True if everything is healthy — no banner needed.
  bool get isHealthy =>
      notificationsEnabled &&
      silentChannelEnabled &&
      urgentChannelEnabled &&
      criticalChannelEnabled;

  /// Human-readable list of issues for the banner.
  List<String> get issues => [
    if (!notificationsEnabled) 'Notifications are turned off for this app',
    if (!silentChannelEnabled) 'Medication Reminders channel is disabled',
    if (!urgentChannelEnabled) 'Urgent Medication Alerts channel is disabled',
    if (!criticalChannelEnabled)
      'Critical Medication Alarms channel is disabled',
  ];
}

/// Checks the health of all notification channels.
///
/// Used on `AppLifecycleState.resumed` to detect if the user (or OEM)
/// has disabled any critical notification channels.
class ChannelHealthChecker {
  /// Creates a [ChannelHealthChecker].
  ChannelHealthChecker({
    required FlutterLocalNotificationsPlugin plugin,
  }) : _plugin = plugin;

  final FlutterLocalNotificationsPlugin _plugin;

  /// Checks the health of all notification channels.
  ///
  /// Returns a [ChannelHealthStatus] with the state of each channel.
  Future<ChannelHealthStatus> check() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) {
      // Not on Android — assume healthy.
      return const ChannelHealthStatus.allHealthy();
    }

    // Check global notification enable.
    final globalEnabled = await android.areNotificationsEnabled() ?? true;

    if (!globalEnabled) {
      return const ChannelHealthStatus(
        notificationsEnabled: false,
        silentChannelEnabled: false,
        urgentChannelEnabled: false,
        criticalChannelEnabled: false,
      );
    }

    // Check individual channels.
    final channels = await android.getNotificationChannels() ?? [];
    final channelMap = {
      for (final ch in channels) ch.id: ch,
    };

    bool isChannelEnabled(String channelId) {
      final channel = channelMap[channelId];
      if (channel == null) return false;
      return channel.importance != Importance.none;
    }

    return ChannelHealthStatus(
      notificationsEnabled: globalEnabled,
      silentChannelEnabled: isChannelEnabled(NotificationChannels.silentId),
      urgentChannelEnabled: isChannelEnabled(NotificationChannels.urgentId),
      criticalChannelEnabled: isChannelEnabled(NotificationChannels.criticalId),
    );
  }
}
