import 'dart:async';

import 'package:flutter/material.dart';
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
/// - 88px DONE/SNOOZE buttons with spring bounce
/// - Caregiver escalation warning
class FullScreenAlarmScreen extends StatelessWidget {
  const FullScreenAlarmScreen({
    required this.reminderId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    required this.onDone,
    required this.onSkip,
    this.chainStep,
    this.chainTotal,
    this.showCaregiverWarning = false,
    this.caregiverMinutesRemaining = 5,
    super.key,
  });

  final int reminderId;
  final String medicineName;
  final String dosage;
  final String scheduledTime;
  final VoidCallback onDone;
  final VoidCallback onSkip;
  final int? chainStep;
  final int? chainTotal;
  final bool showCaregiverWarning;
  final int caregiverMinutesRemaining;

  @override
  Widget build(BuildContext context) {
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Pulsing background
          const Positioned.fill(
            child: PulsingGradientBackground(),
          ),
          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 8),
                        // Time hero
                        AlarmTimeHero(
                          time: scheduledTime,
                          medicineName: medicineName,
                        ),
                        const SizedBox(height: 24),
                        // Content card
                        AlarmContentCard(
                          medicineName: medicineName,
                          dosage: dosage,
                          chainStep: chainStep,
                          chainTotal: chainTotal,
                        ),
                        const SizedBox(height: 24),
                        // Caregiver warning
                        if (showCaregiverWarning) ...[
                          CaregiverWarning(
                            minutesRemaining: caregiverMinutesRemaining,
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Action buttons
                        AlarmActionButtons(
                          medicineName: medicineName,
                          onDone: () {
                            _restoreSystemUI();
                            onDone();
                          },
                          onSnooze: () {
                            _restoreSystemUI();
                            onSkip();
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _restoreSystemUI() {
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      ),
    );
  }
}
