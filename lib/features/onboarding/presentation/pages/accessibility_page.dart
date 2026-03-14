import 'package:flutter/material.dart';
import 'package:memo_care/features/onboarding/presentation/onboarding_page_view.dart'
    show OnboardingPageView;

/// Page 6 — Accessibility settings preview.
///
/// Lets the user enable Large Text and High Contrast before the
/// app is fully set up. Settings are passed up via callbacks so
/// the parent [OnboardingPageView] can adjust theme / text scale.
class AccessibilityPage extends StatefulWidget {
  /// Creates an [AccessibilityPage].
  const AccessibilityPage({
    required this.stepLabel,
    required this.onNext,
    this.initialLargeText = false,
    this.initialHighContrast = false,
    super.key,
  });

  /// E.g. 'Step 6 of 7'.
  final String stepLabel;

  /// Called when "Apply Settings" is pressed.
  final void Function({
    required bool largeText,
    required bool highContrast,
  })
  onNext;

  final bool initialLargeText;
  final bool initialHighContrast;

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
  late bool _largeText;
  late bool _highContrast;

  @override
  void initState() {
    super.initState();
    _largeText = widget.initialLargeText;
    _highContrast = widget.initialHighContrast;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      'Accessibility',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make MemoCare easier for you to see and read.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Toggle card
                  Card(
                    child: Column(
                      children: [
                        // Large Text
                        Semantics(
                          toggled: _largeText,
                          label: 'Large Text: ${_largeText ? 'on' : 'off'}',
                          child: SwitchListTile(
                            value: _largeText,
                            onChanged: (v) => setState(() => _largeText = v),
                            secondary: const Icon(Icons.format_size),
                            title: const Text(
                              'Large Text',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('Increase text size'),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        // High Contrast
                        Semantics(
                          toggled: _highContrast,
                          label:
                              'High Contrast: ${_highContrast ? 'on' : 'off'}',
                          child: SwitchListTile(
                            value: _highContrast,
                            onChanged: (v) => setState(() => _highContrast = v),
                            secondary: const Icon(Icons.contrast),
                            title: const Text(
                              'High Contrast',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text(
                              'Improve visibility of elements',
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Preview banner
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      '"This is how your text will look'
                      '${_largeText ? ' with Large Text enabled' : ''}."',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: primary,
                        fontStyle: FontStyle.italic,
                        fontSize: _largeText ? 20 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => widget.onNext(
                  largeText: _largeText,
                  highContrast: _highContrast,
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Apply Settings'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
