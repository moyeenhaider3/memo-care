import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/platform/audio_service.dart';
import 'package:memo_care/core/platform/permission_service.dart';
import 'package:memo_care/core/providers/notification_providers.dart';
import 'package:memo_care/core/providers/tts_providers.dart';
import 'package:memo_care/features/chain_engine/application/chain_context_providers.dart';
import 'package:memo_care/features/confirmation/application/confirmation_notifier.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/escalation/application/escalation_controller.dart';
import 'package:memo_care/features/escalation/domain/escalation_fsm.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';
import 'package:memo_care/features/escalation/presentation/fullscreen_alarm_screen.dart';
import 'package:memo_care/features/reminders/application/providers.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';

/// Stream provider for a single reminder by ID.
/// Used by [AlarmScreenLoader] to reactively watch reminder data.
// ignore: specify_nonobvious_property_types // workaround
final reminderByIdStreamProvider = StreamProvider.autoDispose
    .family<Reminder?, int>((ref, reminderId) {
      return ref.watch(reminderRepositoryProvider).watchById(reminderId);
    });

/// Loads reminder data for [reminderId] and displays [FullScreenAlarmScreen].
///
/// Starts the [EscalationController] on mount so audio looping and
/// wakelock are active while the screen is shown. Calls
/// [ConfirmationNotifier.confirm] on DONE / SNOOZE / SKIP and pops the route.
class AlarmScreenLoader extends ConsumerStatefulWidget {
  const AlarmScreenLoader({required this.reminderId, super.key});

  final int reminderId;

  @override
  ConsumerState<AlarmScreenLoader> createState() => _AlarmScreenLoaderState();
}

class _AlarmScreenLoaderState extends ConsumerState<AlarmScreenLoader> {
  EscalationController? _controller;
  bool _escalationStarted = false;
  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();
    // Start escalation after first frame so reminder data is loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startEscalation());
  }

  Future<void> _startEscalation() async {
    if (_escalationStarted || !mounted) return;
    _escalationStarted = true;

    final notifService = ref.read(notificationServiceProvider);
    final settings = ref.read(settingsRepositoryProvider).current;

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
      audioService: AudioService(),
      fsm: fsm,
    );
    _controller = controller;

    // Read current reminder snapshot.
    final reminderSnapshot = await ref
        .read(reminderRepositoryProvider)
        .watchById(widget.reminderId)
        .first;

    if (reminderSnapshot == null || !mounted) return;

    final permService = PermissionService();
    final canFullScreen = await permService.canUseFullScreenIntent();

    await controller.startEscalation(
      reminderId: widget.reminderId,
      title: '💊 ${reminderSnapshot.medicineName}',
      body: reminderSnapshot.dosage != null
          ? '${reminderSnapshot.dosage} — Time to take your medication'
          : 'Time to take your medication',
      canUseFullScreen: canFullScreen,
      actions: reminderActionsFor(
        medicineName: reminderSnapshot.medicineName,
        caregiverPhone: settings.caregiverPhone,
      ),
    );
  }

  Future<void> _acknowledge() async {
    if (_acknowledged) return;
    _acknowledged = true;
    try {
      await ref.read(ttsServiceProvider).stop();
    } on Object catch (_) {
      // Non-fatal: continue acknowledgement flow even if stop fails.
    }
    await _controller?.acknowledge();
  }

  Future<void> _handleDone() async {
    await _acknowledge();
    final reminder = await _loadReminder();
    if (reminder == null) {
      if (mounted) context.pop();
      return;
    }
    await ref
        .read(confirmationNotifierProvider.notifier)
        .confirm(
          reminderId: widget.reminderId,
          chainId: reminder.chainId,
          confirmState: ConfirmationState.done,
          medicineName: reminder.medicineName,
        );
    if (mounted) context.pop();
  }

  Future<void> _handleSnooze() async {
    await _acknowledge();
    final reminder = await _loadReminder();
    if (reminder == null) {
      if (mounted) context.pop();
      return;
    }
    final settings = ref.read(settingsRepositoryProvider).current;
    final snoozeUntil = DateTime.now().toUtc().add(
      Duration(minutes: settings.snoozeDurationMinutes),
    );

    await ref
        .read(confirmationNotifierProvider.notifier)
        .confirm(
          reminderId: widget.reminderId,
          chainId: reminder.chainId,
          confirmState: ConfirmationState.snoozed,
          medicineName: reminder.medicineName,
          snoozeUntil: snoozeUntil,
        );
    if (mounted) context.pop();
  }

  Future<void> _handleSkip() async {
    await _acknowledge();
    final reminder = await _loadReminder();
    if (reminder == null) {
      if (mounted) context.pop();
      return;
    }
    await ref
        .read(confirmationNotifierProvider.notifier)
        .confirm(
          reminderId: widget.reminderId,
          chainId: reminder.chainId,
          confirmState: ConfirmationState.skipped,
          medicineName: reminder.medicineName,
        );
    if (mounted) context.pop();
  }

  Future<Reminder?> _loadReminder() {
    return ref
        .read(reminderRepositoryProvider)
        .watchById(widget.reminderId)
        .first;
  }

  @override
  void dispose() {
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reminderAsync = ref.watch(
      reminderByIdStreamProvider(widget.reminderId),
    );
    final chainContextAsync = ref.watch(
      chainContextProvider(widget.reminderId),
    );

    return reminderAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error loading reminder: $e')),
      ),
      data: (reminder) {
        if (reminder == null) {
          // Reminder deleted — pop back.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.pop();
          });
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        final scheduledTime = reminder.scheduledAt != null
            ? DateFormat('h:mm a').format(reminder.scheduledAt!.toLocal())
            : 'Now';
        final scheduledDate = DateFormat('EEEE, MMM d').format(
          (reminder.scheduledAt ?? DateTime.now()).toLocal(),
        );

        final settings = ref.read(settingsRepositoryProvider).current;
        final escalateMinutes =
            settings.silentTimeoutMinutes + settings.audibleTimeoutMinutes;
        final showCaregiverWarning = settings.caregiverPhone.trim().isNotEmpty;
        final warningText =
            'Your confirmation window closes in $escalateMinutes minutes.';
        final instructionText = 'Take ${reminder.medicineType.ttsContext}';

        final chainContext = chainContextAsync.asData?.value;
        final chainStep = chainContext == null
            ? null
            : chainContext.upstreamReminders.length + 1;
        final chainTotal = chainContext == null
            ? null
            : chainContext.upstreamReminders.length +
                  chainContext.downstreamReminders.length +
                  1;

        return FullScreenAlarmScreen(
          reminderId: reminder.id,
          medicineName: reminder.medicineName,
          dosage: reminder.dosage ?? '',
          scheduledTime: scheduledTime,
          dateText: scheduledDate,
          instructionText: instructionText,
          warningText: warningText,
          chainStep: chainStep,
          chainTotal: chainTotal,
          showCaregiverWarning: showCaregiverWarning,
          caregiverMinutesRemaining: escalateMinutes,
          snoozeButtonLabel:
              'Remind me in ${settings.snoozeDurationMinutes} min',
          onDone: _handleDone,
          onSnooze: _handleSnooze,
          onSkip: _handleSkip,
        );
      },
    );
  }
}
