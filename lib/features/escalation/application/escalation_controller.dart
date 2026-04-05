import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/platform/audio_service.dart';
import 'package:memo_care/core/platform/notification_service.dart';
import 'package:memo_care/features/escalation/domain/escalation_fsm.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Orchestrates the full escalation pipeline for a single
/// reminder.
///
/// Coordinates:
/// - [EscalationFSM] for tier state transitions
/// - [NotificationService] for displaying/updating notifications
/// - [AudioService] for alarm sound looping
/// - [WakelockPlus] for keeping screen on
/// - [VolumeController] for maximizing volume at fullscreen tier
class EscalationController {
  /// Creates an [EscalationController].
  EscalationController({
    required NotificationService notificationService,
    AudioService? audioService,
    EscalationFSM? fsm,
  }) : _notificationService = notificationService,
       _audioService = audioService ?? AudioService(),
       _fsm = fsm ?? EscalationFSM();

  final NotificationService _notificationService;
  final AudioService _audioService;
  final EscalationFSM _fsm;

  int? _activeReminderId;
  bool _canUseFullScreen = false;
  String _title = '';
  String _body = '';
  List<AndroidNotificationAction> _actions = kReminderActions;

  /// The current escalation level.
  EscalationLevel get currentLevel => _fsm.current;

  /// Whether an escalation is currently active.
  bool get isActive => _fsm.isActive;

  /// The reminder ID being escalated, or null if not active.
  int? get activeReminderId => _activeReminderId;

  /// Starts the escalation pipeline for a reminder.
  ///
  /// Shows an initial SILENT notification, then progresses
  /// through AUDIBLE then FULLSCREEN on timeouts.
  ///
  /// [canUseFullScreen] should be the result of
  /// `PermissionService.canUseFullScreenIntent()`.
  Future<void> startEscalation({
    required int reminderId,
    required String title,
    required String body,
    required bool canUseFullScreen,
    List<AndroidNotificationAction>? actions,
  }) async {
    // If already escalating a different reminder, acknowledge
    // the old one.
    if (_fsm.isActive && _activeReminderId != reminderId) {
      await acknowledge();
    }

    _activeReminderId = reminderId;
    _canUseFullScreen = canUseFullScreen;
    _title = title;
    _body = body;
    _actions = actions ?? kReminderActions;

    // Show initial SILENT notification.
    await _showNotificationAtLevel(EscalationLevel.silent);

    // Start FSM — it calls _onEscalate on each tier
    // transition.
    _fsm.start(_onEscalate);
  }

  /// Called by the FSM on each tier transition.
  void _onEscalate(EscalationLevel newLevel) {
    // Fire-and-forget — FSM callback is sync, but we need
    // async ops.
    unawaited(_handleEscalation(newLevel));
  }

  Future<void> _handleEscalation(
    EscalationLevel level,
  ) async {
    final reminderId = _activeReminderId;
    if (reminderId == null) return;

    switch (level) {
      case EscalationLevel.silent:
        // FSM starts at silent, escalates to audible first.
        break;

      case EscalationLevel.audible:
        // Start alarm sound loop.
        await _audioService.startLoop();
        // Update notification to urgent tier.
        await _showNotificationAtLevel(
          EscalationLevel.audible,
        );

      case EscalationLevel.fullscreen:
        // Maximize volume.
        try {
          VolumeController.instance.showSystemUI = false;
          await VolumeController.instance.setVolume(1);
        } on Exception {
          // Volume control failure should not block
          // escalation.
        }
        // Enable wakelock.
        try {
          await WakelockPlus.enable();
        } on Exception {
          // Wakelock failure should not block escalation.
        }

        if (_canUseFullScreen) {
          // Show full-screen intent notification — launches
          // FullScreenAlarmScreen.
          await _showNotificationAtLevel(
            EscalationLevel.fullscreen,
            fullScreenIntent: true,
          );
        } else {
          // Degrade gracefully: high-priority heads-up
          // notification (no full-screen).
          await _showNotificationAtLevel(
            EscalationLevel.fullscreen,
          );
          debugPrint(
            'MemoCare: Full-screen intent denied — '
            'degraded to heads-up notification',
          );
        }
    }
  }

  /// Acknowledges the current escalation
  /// (user tapped DONE/SKIP/SNOOZE).
  ///
  /// Cancels timers, stops sound, releases wakelock,
  /// cancels notification.
  Future<void> acknowledge() async {
    final reminderId = _activeReminderId;

    // Stop FSM timers.
    _fsm.acknowledge();

    // Stop alarm sound.
    await _audioService.stop();

    // Release wakelock.
    try {
      await WakelockPlus.disable();
    } on Exception {
      // Ignore wakelock errors.
    }

    // Cancel notification.
    if (reminderId != null) {
      await _notificationService.cancel(reminderId);
    }

    _activeReminderId = null;
  }

  /// Releases all resources. Call when this controller is no
  /// longer needed.
  Future<void> dispose() async {
    _fsm.dispose();
    await _audioService.dispose();
    try {
      await WakelockPlus.disable();
    } on Exception {
      // Ignore wakelock errors.
    }
    _activeReminderId = null;
  }

  Future<void> _showNotificationAtLevel(
    EscalationLevel level, {
    bool fullScreenIntent = false,
  }) async {
    final reminderId = _activeReminderId;
    if (reminderId == null) return;

    await _notificationService.show(
      id: reminderId,
      title: _title,
      body: _body,
      level: level,
      fullScreenIntent: fullScreenIntent,
      actions: _actions,
      payload: '{"reminderId": $reminderId}',
    );
  }
}
