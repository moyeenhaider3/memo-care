import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

// ignore: lines_longer_than_ // workaround
// ignore: lines_longer_than_80_chars // workaround
/// Button to switch from Kids View back to the Parent (standard adult) dashboard.
///
/// Protected by a 4-digit PIN dialog. If no PIN is set, a simple confirmation
/// dialog is shown instead.
class ParentViewToggle extends StatelessWidget {
  const ParentViewToggle({
    required this.onUnlocked,
    this.pin,
    super.key,
  });

  /// Called when parent view is successfully unlocked.
  final VoidCallback onUnlocked;

  /// Optional stored PIN. If null/empty, a simple confirmation is shown.
  final String? pin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: KidsColors.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: KidsColors.primary.withAlpha(50),
            width: 2,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 18,
              color: KidsColors.primary,
            ),
            SizedBox(width: 6),
            Text(
              'Parent View',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: KidsColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (pin == null || pin!.isEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Switch to Parent View?'),
          content: const Text(
            'This will show the standard adult dashboard.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Switch'),
            ),
          ],
        ),
      );
      if (confirmed ?? false) onUnlocked();
    } else {
      await _showPinDialog(context);
    }
  }

  Future<void> _showPinDialog(BuildContext context) async {
    final controller = TextEditingController();
    String? error;

    final entered = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Enter Parent PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: '_ _ _ _',
                  errorText: error,
                  counterText: '',
                ),
                autofocus: true,
                onChanged: (_) => setState(() => error = null),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text == pin) {
                  Navigator.of(ctx).pop(controller.text);
                } else {
                  setState(() => error = 'Incorrect PIN');
                }
              },
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );

    if (entered != null) onUnlocked();
  }
}
