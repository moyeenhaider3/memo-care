import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';

/// Page 7 — Optional caregiver link.
///
/// User enters a caregiver's phone number. Tapping "Send
/// Invitation" stores the number and advances. "Maybe Later"
/// skips without storing a number.
class CaregiverPage extends ConsumerStatefulWidget {
  /// Creates a [CaregiverPage].
  const CaregiverPage({
    required this.stepLabel,
    required this.onNext,
    super.key,
  });

  /// E.g. 'Step 7 of 7'.
  final String stepLabel;

  /// Called when user completes or skips this step.
  final VoidCallback onNext;

  @override
  ConsumerState<CaregiverPage> createState() => _CaregiverPageState();
}

class _CaregiverPageState extends ConsumerState<CaregiverPage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.stepLabel),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volunteer_activism,
                      color: primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      'Caregiver Link',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a family member or nurse to help track your '
                    'medications.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Phone field
                  TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Caregiver's Phone Number",
                      hintText: '(555) 000-0000',
                      prefixIcon: const Icon(Icons.call_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'They will receive an invitation link via SMS. '
                    'You can skip this and add it later in Settings.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final phone = _ctrl.text.trim();
                  if (phone.isNotEmpty) {
                    ref
                        .read(onboardingNotifierProvider.notifier)
                        .setCaregiverPhone(phone);
                  }
                  widget.onNext();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Send Invitation'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: widget.onNext,
                child: Text(
                  'Maybe Later',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
