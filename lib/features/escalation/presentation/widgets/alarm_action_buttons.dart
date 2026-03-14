import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// 88px DONE / SNOOZE alarm action buttons with spring bounce.
class AlarmActionButtons extends StatelessWidget {
  const AlarmActionButtons({
    required this.onDone,
    required this.onSnooze,
    this.medicineName,
    this.snoozeDisabled = false,
    super.key,
  });

  final VoidCallback onDone;
  final VoidCallback onSnooze;
  final String? medicineName;
  final bool snoozeDisabled;

  @override
  Widget build(BuildContext context) {
    final name = medicineName ?? 'medicine';
    return Semantics(
      sortKey: const OrdinalSortKey(2),
      child: Column(
        children: [
          Semantics(
            label: 'Confirm taking $name',
            button: true,
            sortKey: const OrdinalSortKey(3),
            child: SizedBox(
              height: AppSpacing.alertButtonHeight,
              child: _BounceButton(
                height: AppSpacing.alertButtonHeight,
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                icon: Icons.check_circle,
                label: 'DONE',
                onPressed: onDone,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Skip $name',
            button: true,
            sortKey: const OrdinalSortKey(4),
            child: SizedBox(
              height: AppSpacing.alertButtonHeight,
              child: _BounceButton(
                height: AppSpacing.alertButtonHeight,
                backgroundColor: AppColors.warning,
                foregroundColor: AppColors.textPrimary,
                icon: Icons.snooze,
                label: 'SNOOZE',
                onPressed: snoozeDisabled ? null : onSnooze,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Button with spring micro-bounce animation on tap.
class _BounceButton extends StatefulWidget {
  const _BounceButton({
    required this.height,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final double height;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<_BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<_BounceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails _) async {
    await _controller.forward();
  }

  Future<void> _onTapUp(TapUpDetails _) async {
    await _controller.reverse();
    widget.onPressed?.call();
  }

  Future<void> _onTapCancel() async {
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: widget.height,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          decoration: BoxDecoration(
            color: isDisabled
                ? widget.backgroundColor.withAlpha(100)
                : widget.backgroundColor,
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.foregroundColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: AppTypography.displayMedium.copyWith(
                  color: widget.foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
