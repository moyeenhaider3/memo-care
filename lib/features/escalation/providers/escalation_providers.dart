import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/audio_service.dart';
import 'package:memo_care/core/providers/notification_providers.dart';
import 'package:memo_care/features/escalation/application/escalation_controller.dart';
import 'package:memo_care/features/escalation/domain/escalation_fsm.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';

/// Provides a singleton [AudioService] instance.
///
/// Uses a manual [Provider] (not @Riverpod code-gen) because
/// riverpod_generator was dropped due to analyzer version
/// conflicts with drift_dev.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// Provides the [EscalationController] that orchestrates
/// FSM + notifications + audio + wakelock.
///
/// This is a kept-alive singleton — only one escalation can
/// be active at a time. Reads user-configured timeouts from
/// settings.
final escalationControllerProvider = Provider<EscalationController>((ref) {
  final notifService = ref.watch(notificationServiceProvider);
  final audio = ref.watch(audioServiceProvider);
  final settings = ref.watch(settingsRepositoryProvider).current;

  final fsm = EscalationFSM(
    timeouts: {
      EscalationLevel.silent: Duration(
        minutes: settings.silentTimeoutMinutes,
      ),
      EscalationLevel.audible: Duration(
        minutes: settings.audibleTimeoutMinutes,
      ),
    },
  );

  final controller = EscalationController(
    notificationService: notifService,
    audioService: audio,
    fsm: fsm,
  );
  ref.onDispose(controller.dispose);
  return controller;
});
