/// Notification channel configuration constants.
///
/// Android requires notification channels (API 26+). Each channel has a fixed
/// importance level that the user can modify in system Settings. We use
/// 3 channels matching the escalation tiers.
abstract final class NotificationChannels {
  // ── Silent channel ──────────────────────────────────────────────
  /// Channel for initial (silent) reminder notifications.
  static const String silentId = 'memo_silent';
  static const String silentName = 'Medication Reminders';
  static const String silentDescription =
      'Initial reminder notifications (no sound)';

  // ── Urgent channel ──────────────────────────────────────────────
  /// Channel for escalated notifications with sound and vibration.
  static const String urgentId = 'memo_urgent';
  static const String urgentName = 'Urgent Medication Alerts';
  static const String urgentDescription =
      'Escalated alerts with sound and vibration when a reminder is not '
      'acknowledged';

  // ── Critical channel ────────────────────────────────────────────
  /// Channel for full-screen takeover alerts.
  static const String criticalId = 'memo_critical';
  static const String criticalName = 'Critical Medication Alarms';
  static const String criticalDescription =
      'Full-screen alarm for unacknowledged medication reminders';

  /// Custom sound filename (without extension) in res/raw/.
  static const String customSoundFile = 'reminder';
}
