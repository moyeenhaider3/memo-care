import 'package:flutter/material.dart';
import 'package:memo_care/core/presentation/app_shell.dart' show AppShell;
import 'package:memo_care/core/theme/app_colors.dart';

/// Centered floating action button for quick-add reminder.
///
/// Placed at [FloatingActionButtonLocation.centerDocked] inside
/// [AppShell]'s [Scaffold]. Tapping navigates to `/add-reminder`.
class MemoFab extends StatelessWidget {
  /// Creates a [MemoFab].
  const MemoFab({required this.onPressed, super.key});

  /// Callback when the FAB is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      tooltip: 'Add new reminder',
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
