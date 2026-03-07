import 'package:memo_care/features/escalation/domain/escalation_level.dart';

/// Default duration constants used across the app.
abstract final class AppDurations {
  /// Default escalation timeouts per tier.
  ///
  /// - [EscalationLevel.silent]: 2 minutes before escalating to audible
  /// - [EscalationLevel.audible]: 3 minutes before escalating to fullscreen
  /// - [EscalationLevel.fullscreen]: no timeout (terminal state)
  static const Map<EscalationLevel, Duration> defaultEscalationTimeouts = {
    EscalationLevel.silent: Duration(minutes: 2),
    EscalationLevel.audible: Duration(minutes: 3),
  };

  /// Default snooze duration when user taps SNOOZE.
  static const Duration defaultSnoozeDuration = Duration(minutes: 10);

  /// Maximum number of snoozes before auto-skip.
  static const int maxSnoozeCount = 3;
}
