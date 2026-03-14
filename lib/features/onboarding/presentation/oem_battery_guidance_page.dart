import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memo_care/core/platform/oem_detector.dart';
import 'package:memo_care/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// Onboarding page that shows device-specific battery
/// optimization instructions.
///
/// Shows step-by-step guide based on the detected OEM
/// manufacturer. Displayed during onboarding BEFORE the
/// first alarm is scheduled.
class OemBatteryGuidancePage extends StatefulWidget {
  /// Creates an [OemBatteryGuidancePage].
  const OemBatteryGuidancePage({
    required this.onContinue,
    super.key,
  });

  /// Called when the user taps "I've done this" or "Continue".
  final VoidCallback onContinue;

  @override
  State<OemBatteryGuidancePage> createState() => _OemBatteryGuidancePageState();
}

class _OemBatteryGuidancePageState extends State<OemBatteryGuidancePage> {
  late final _detector = OemDetector();
  late OemGuidance? _guidance;
  late bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadGuidance());
  }

  Future<void> _loadGuidance() async {
    final guidance = await _detector.getGuidance();
    if (mounted) {
      setState(() {
        _guidance = guidance;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final guidance = _guidance!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Important Setup Step'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning icon + severity indicator
              Icon(
                guidance.severity >= 8
                    ? Icons.warning_rounded
                    : Icons.info_outline_rounded,
                color: guidance.severity >= 8 ? Colors.orange : Colors.blue,
                size: 48,
              ),
              const SizedBox(height: 16),

              // OEM name
              Text(
                guidance.oemName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Warning text
              Text(
                guidance.warningText,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Steps
              Expanded(
                child: ListView.separated(
                  itemCount: guidance.steps.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final step = guidance.steps[index];
                    return _StepCard(
                      stepNumber: index + 1,
                      step: step,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Open Settings button
              OutlinedButton.icon(
                onPressed: openAppSettings,
                icon: const Icon(Icons.settings),
                label: const Text(
                  'Open Settings',
                  style: TextStyle(fontSize: 18),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
              const SizedBox(height: 12),

              // Continue button
              FilledButton(
                onPressed: widget.onContinue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text(
                  "I've done this — Continue",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.stepNumber,
    required this.step,
  });

  final int stepNumber;
  final OemGuidanceStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Instruction text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.instruction,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (step.subInstruction != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.subInstruction!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: LegacyAppColors.skippedGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
