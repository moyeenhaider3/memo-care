/// Decision result from [SnoozeLimiter.evaluate].
sealed class SnoozeDecision {
  const SnoozeDecision();
}

/// Snooze is allowed — [remainingSnoozes] indicates how
/// many are left.
final class SnoozeAllowed extends SnoozeDecision {
  /// Creates a [SnoozeAllowed] decision.
  const SnoozeAllowed({required this.remainingSnoozes});

  /// Number of snoozes remaining after this one
  /// (0 = last snooze).
  final int remainingSnoozes;
}

/// Snooze limit exhausted — auto-transition to SKIPPED.
final class SnoozeExhausted extends SnoozeDecision {
  /// Creates a [SnoozeExhausted] decision.
  const SnoozeExhausted({required this.reason});

  /// Human-readable reason for the auto-skip.
  final String reason;
}

/// Enforces maximum snooze count per reminder (CHAIN-06).
///
/// After [maxSnoozes] snooze attempts, returns
/// [SnoozeExhausted] indicating the reminder should
/// auto-transition to SKIPPED.
///
/// Pure Dart — no Flutter imports, no I/O. Takes snooze
/// count as input.
class SnoozeLimiter {
  /// Creates a [SnoozeLimiter] with optional custom
  /// [maxSnoozes]. Default: 3 (CHAIN-06).
  const SnoozeLimiter({this.maxSnoozes = 3});

  /// Maximum number of snoozes allowed per reminder.
  final int maxSnoozes;

  /// Evaluates whether a snooze is allowed given
  /// [currentSnoozeCount].
  ///
  /// [currentSnoozeCount] is the number of times this
  /// reminder has already been snoozed.
  ///
  /// Returns:
  /// - [SnoozeAllowed] if count < [maxSnoozes]
  /// - [SnoozeExhausted] if count >= [maxSnoozes]
  SnoozeDecision evaluate(int currentSnoozeCount) {
    if (currentSnoozeCount >= maxSnoozes) {
      return SnoozeExhausted(
        reason:
            'Auto-skipped after $maxSnoozes snooze attempts',
      );
    }
    return SnoozeAllowed(
      remainingSnoozes:
          maxSnoozes - currentSnoozeCount - 1,
    );
  }
}
