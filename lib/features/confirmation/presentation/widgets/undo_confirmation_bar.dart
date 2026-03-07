import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/confirmation/application/providers.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/confirmation/domain/models/undoable_confirmation.dart';
import 'package:memo_care/features/confirmation/domain/undo_confirmation_service.dart';

/// Duration of the undo countdown (10 seconds per A11Y-07).
const _undoDuration = Duration(seconds: 10);

/// A bottom bar that allows the user to undo a medication
/// confirmation within [_undoDuration].
///
/// Shows medicine name, action label, countdown progress, and
/// an UNDO button. Auto-dismisses when the timer expires.
///
/// Accessibility:
/// - Announce via [Semantics] with live region
/// - Button touch target >= 48 dp
/// - High-contrast text
class UndoConfirmationBar extends ConsumerStatefulWidget {
  /// Creates an [UndoConfirmationBar].
  const UndoConfirmationBar({
    required this.undoable,
    required this.onDismissed,
    super.key,
  });

  /// The confirmation that can be undone.
  final UndoableConfirmation undoable;

  /// Called when the bar is dismissed (either timer expired or
  /// undo completed).
  final VoidCallback onDismissed;

  @override
  ConsumerState<UndoConfirmationBar> createState() =>
      _UndoConfirmationBarState();
}

class _UndoConfirmationBarState
    extends ConsumerState<UndoConfirmationBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _undoing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _undoDuration,
    )..addStatusListener(_onAnimationStatus);
    unawaited(_controller.forward());
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onDismissed();
    }
  }

  Future<void> _handleUndo() async {
    if (_undoing) return;
    setState(() => _undoing = true);
    _controller.stop();

    final service =
        ref.read(undoConfirmationServiceProvider);
    final result = await service.undo(widget.undoable);

    if (!mounted) return;

    switch (result) {
      case UndoSucceeded():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.undoable.medicineName} undone',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      case UndoFailed(:final reason):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Undo failed: $reason'),
            backgroundColor: Colors.red.shade700,
          ),
        );
    }

    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionLabel = switch (widget.undoable.confirmState) {
      ConfirmationState.done => 'marked as done',
      ConfirmationState.skipped => 'skipped',
      ConfirmationState.snoozed => 'snoozed',
    };

    return Semantics(
      liveRegion: true,
      label: '${widget.undoable.medicineName} '
          '$actionLabel. Tap undo to revert.',
      child: Material(
        elevation: 6,
        color: theme.colorScheme.inverseSurface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                // Text: "Medicine Name" marked as done
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.undoable.medicineName,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(
                          color: theme
                              .colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        actionLabel,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          color: theme
                              .colorScheme.onInverseSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Countdown indicator
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: 1 - _controller.value,
                        strokeWidth: 3,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme
                            .colorScheme.onInverseSurface
                            .withValues(alpha: 0.2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),

                // UNDO button
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: _undoing ? null : _handleUndo,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          theme.colorScheme.inversePrimary,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _undoing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme
                                  .inversePrimary,
                            ),
                          )
                        : const Text('UNDO'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
