import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen alarm screen launched by the critical
/// notification's full-screen intent at the FULLSCREEN
/// escalation tier.
///
/// Features:
/// - Dark background (reduces glare at night)
/// - HUGE medication name text (36pt)
/// - GIANT "I TOOK IT" button (green, 80dp height)
/// - GIANT "SKIP" button (red, 80dp height)
/// - No SNOOZE at this point — user must decide
/// - Screen stays on (wakelock managed by
///   `EscalationController`)
class FullScreenAlarmScreen extends StatelessWidget {
  /// Creates a [FullScreenAlarmScreen].
  const FullScreenAlarmScreen({
    required this.reminderId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    required this.onDone,
    required this.onSkip,
    super.key,
  });

  /// The reminder ID (for action routing).
  final int reminderId;

  /// Medicine name to display prominently.
  final String medicineName;

  /// Dosage text (e.g., "500mg, 1 tablet").
  final String dosage;

  /// When the medication was due.
  final String scheduledTime;

  /// Called when user taps DONE.
  final VoidCallback onDone;

  /// Called when user taps SKIP.
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 48,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Alert icon
              const Icon(
                Icons.medication_rounded,
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 24),

              // "Time to take" label
              const Text(
                'Time to take your medicine',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Medicine name — HUGE text
              Text(
                medicineName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Dosage
              Text(
                dosage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Scheduled time
              Text(
                'Due at $scheduledTime',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // DONE button — GIANT green
              SizedBox(
                width: double.infinity,
                height: 80,
                child: FilledButton.icon(
                  onPressed: () {
                    _restoreSystemUI();
                    onDone();
                  },
                  icon: const Icon(
                    Icons.check_circle,
                    size: 36,
                  ),
                  label: const Text(
                    'I TOOK IT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SKIP button — GIANT red
              SizedBox(
                width: double.infinity,
                height: 80,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _restoreSystemUI();
                    onSkip();
                  },
                  icon: const Icon(
                    Icons.cancel,
                    size: 36,
                  ),
                  label: const Text(
                    'SKIP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE74C3C),
                    side: const BorderSide(
                      color: Color(0xFFE74C3C),
                      width: 3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
