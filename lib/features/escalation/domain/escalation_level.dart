/// Escalation tiers for unacknowledged reminders.
///
/// Progression: [silent] → [audible] → [fullscreen].
/// Each tier increases urgency to ensure the user responds.
enum EscalationLevel {
  /// Low-priority notification, no sound or vibration.
  silent,

  /// High-priority notification with sound and vibration.
  audible,

  /// Full-screen takeover with alarm sound loop and wakelock.
  fullscreen,
}
