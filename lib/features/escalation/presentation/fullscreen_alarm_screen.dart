import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:memo_care/features/escalation/presentation/widgets/alarm_action_buttons.dart';
import 'package:memo_care/features/escalation/presentation/widgets/alarm_content_card.dart';
import 'package:memo_care/features/escalation/presentation/widgets/alarm_time_hero.dart';
import 'package:memo_care/features/escalation/presentation/widgets/caregiver_warning.dart';
import 'package:memo_care/features/escalation/presentation/widgets/pulsing_gradient_background.dart';

/// Full-screen alarm screen with pulsing background (10-07).
///
/// Features:
/// - Pulsing radial gradient background (2s breathing cycle)
/// - 64px time hero + 32px medicine name
/// - White content card with chain step indicator
/// - 88px DONE/SNOOZE/SKIP buttons with spring bounce
/// - Caregiver escalation warning
///
/// FIXED: Removed [SingleChildScrollView] — it absorbed gestures so bounce
/// buttons only received incomplete tap gestures; layout is non-scrollable.
class FullScreenAlarmScreen extends StatefulWidget {
  const FullScreenAlarmScreen({
    required this.reminderId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    required this.onDone,
    required this.onSnooze,
    required this.onSkip,
    this.dateText,
    this.instructionText,
    this.warningText,
    this.chainStep,
    this.chainTotal,
    this.showCaregiverWarning = false,
    this.caregiverMinutesRemaining = 5,
    this.doneButtonLabel = "I've Done It",
    this.snoozeButtonLabel = 'Remind me in 10 min',
    super.key,
  });

  final int reminderId;
  final String medicineName;
  final String dosage;
  final String scheduledTime;
  final String? dateText;
  final String? instructionText;
  final String? warningText;
  final VoidCallback onDone;

  /// Called when the user taps the SNOOZE button — re-alerts after snooze
  /// duration.
  final VoidCallback onSnooze;

  /// Called when the user taps the SKIP button (missed intentionally).
  final VoidCallback onSkip;

  final int? chainStep;
  final int? chainTotal;
  final bool showCaregiverWarning;
  final int caregiverMinutesRemaining;
  final String doneButtonLabel;
  final String snoozeButtonLabel;

  @override
  State<FullScreenAlarmScreen> createState() => _FullScreenAlarmScreenState();
}

class _FullScreenAlarmScreenState extends State<FullScreenAlarmScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
        ),
      );
    });
  }

  @override
  void dispose() {
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      ),
    );
    super.dispose();
  }

  void _restoreSystemUI() {
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: PulsingGradientBackground(),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Column(
                    children: [
                      // FIXED: FittedBox + bounded constraints — 200% text scale fits
                      // without page scroll (scaleDown only when needed).
                      Expanded(
                        flex: 2,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                ),
                                child: AlarmTimeHero(
                                  time: widget.scheduledTime,
                                  medicineName: widget.medicineName,
                                  dateText: widget.dateText,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                  maxHeight: constraints.maxHeight,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: AlarmContentCard(
                                    medicineName: widget.medicineName,
                                    dosage: widget.dosage,
                                    instructions: widget.instructionText,
                                    warningText: widget.warningText,
                                    chainStep: widget.chainStep,
                                    chainTotal: widget.chainTotal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (widget.showCaregiverWarning) ...[
                        CaregiverWarning(
                          minutesRemaining: widget.caregiverMinutesRemaining,
                        ),
                        const SizedBox(height: 8),
                      ],
                      AlarmActionButtons(
                        medicineName: widget.medicineName,
                        doneLabel: widget.doneButtonLabel,
                        snoozeLabel: widget.snoozeButtonLabel,
                        onDone: () {
                          _restoreSystemUI();
                          debugPrint(
                            "🟢 [ALARM] I've Done It — reminderId: "
                            '${widget.reminderId}',
                          );
                          widget.onDone();
                        },
                        onSnooze: () {
                          _restoreSystemUI();
                          debugPrint(
                            '🟡 [ALARM] Snooze — reminderId: '
                            '${widget.reminderId}',
                          );
                          widget.onSnooze();
                        },
                      ),
                      // FIXED: Plain TextButton had no Semantics label — a11y test + TalkBack
                      Semantics(
                        label: 'Skip ${widget.medicineName}',
                        button: true,
                        sortKey: const OrdinalSortKey(5),
                        child: TextButton(
                          onPressed: () {
                            _restoreSystemUI();
                            debugPrint(
                              '🔴 [ALARM] Skip — reminderId: '
                              '${widget.reminderId}',
                            );
                            widget.onSkip();
                          },
                          child: Text(
                            'Skip this reminder',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
