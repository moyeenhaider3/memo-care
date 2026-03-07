import 'dart:async';

import 'package:memo_care/core/constants/durations.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';

/// State machine that drives escalation through three tiers:
/// [EscalationLevel.silent] → [EscalationLevel.audible] →
/// [EscalationLevel.fullscreen].
///
/// Usage:
/// ```dart
/// final fsm = EscalationFSM();
/// fsm.start((level) {
///   // Show notification at [level] tier
/// });
/// // When user acknowledges:
/// fsm.acknowledge();
/// ```
class EscalationFSM {
  /// Creates an FSM with optional custom [timeouts].
  ///
  /// If [timeouts] is null, uses [AppDurations.defaultEscalationTimeouts].
  /// The map defines how long to wait at each level before escalating.
  /// [EscalationLevel.fullscreen] is the terminal state (no timeout needed).
  EscalationFSM({
    Map<EscalationLevel, Duration>? timeouts,
  }) : _timeouts = timeouts ?? AppDurations.defaultEscalationTimeouts;

  final Map<EscalationLevel, Duration> _timeouts;
  EscalationLevel _current = EscalationLevel.silent;
  Timer? _timer;
  bool _active = false;

  /// The current escalation level.
  EscalationLevel get current => _current;

  /// Whether the FSM is actively running (started and not
  /// acknowledged/disposed).
  bool get isActive => _active;

  /// Starts escalation from [EscalationLevel.silent].
  ///
  /// [onEscalate] is called each time the level advances.
  /// If already active, cancels the current run and restarts from silent.
  void start(void Function(EscalationLevel level) onEscalate) {
    _timer?.cancel();
    _current = EscalationLevel.silent;
    _active = true;
    _scheduleNext(onEscalate);
  }

  /// Acknowledges the reminder (DONE/SKIP/SNOOZE).
  ///
  /// Cancels any pending timer and resets to [EscalationLevel.silent].
  void acknowledge() {
    _timer?.cancel();
    _timer = null;
    _current = EscalationLevel.silent;
    _active = false;
  }

  /// Releases resources. Does NOT reset level (unlike [acknowledge]).
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _active = false;
  }

  void _scheduleNext(void Function(EscalationLevel level) onEscalate) {
    final timeout = _timeouts[_current];
    if (timeout == null) return; // terminal state (fullscreen)

    _timer = Timer(timeout, () {
      final nextIndex = _current.index + 1;
      if (nextIndex < EscalationLevel.values.length) {
        _current = EscalationLevel.values[nextIndex];
        onEscalate(_current);
        _scheduleNext(onEscalate);
      }
    });
  }
}
