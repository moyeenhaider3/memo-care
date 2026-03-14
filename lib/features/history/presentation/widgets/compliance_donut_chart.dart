import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Compliance donut chart — CustomPainter ring with color segments.
///
/// Shows Done (green), Missed (red), Skipped (grey), Pending (amber)
/// proportions. Center text shows overall compliance percentage.
class ComplianceDonutChart extends StatelessWidget {
  const ComplianceDonutChart({
    required this.done,
    required this.missed,
    required this.skipped,
    required this.pending,
    super.key,
  });

  final int done;
  final int missed;
  final int skipped;
  final int pending;

  int get _total => done + missed + skipped + pending;

  int get _compliancePercent {
    if (_total == 0) return 0;
    return ((done / _total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: _DonutPainter(
              done: done,
              missed: missed,
              skipped: skipped,
              pending: pending,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_compliancePercent%',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Compliance',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppColors.success, label: 'Done', count: done),
            const SizedBox(width: 16),
            _LegendDot(
                color: AppColors.danger, label: 'Missed', count: missed),
            const SizedBox(width: 16),
            _LegendDot(
                color: AppColors.skippedGrey,
                label: 'Skipped',
                count: skipped),
            const SizedBox(width: 16),
            _LegendDot(
                color: AppColors.warning, label: 'Pending', count: pending),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.count,
  });
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.done,
    required this.missed,
    required this.skipped,
    required this.pending,
  });

  final int done;
  final int missed;
  final int skipped;
  final int pending;

  @override
  void paint(Canvas canvas, Size size) {
    final total = done + missed + skipped + pending;
    if (total == 0) {
      // Draw empty ring
      final paint = Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromLTWH(14, 14, size.width - 28, size.height - 28),
        0,
        2 * math.pi,
        false,
        paint,
      );
      return;
    }

    final rect = Rect.fromLTWH(14, 14, size.width - 28, size.height - 28);
    const strokeWidth = 14.0;

    final segments = <(double, Color)>[
      (done / total, AppColors.success),
      (missed / total, AppColors.danger),
      (skipped / total, AppColors.skippedGrey),
      (pending / total, AppColors.warning),
    ];

    var startAngle = -math.pi / 2;
    for (final (fraction, color) in segments) {
      if (fraction <= 0) continue;
      final sweep = fraction * 2 * math.pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      done != oldDelegate.done ||
      missed != oldDelegate.missed ||
      skipped != oldDelegate.skipped ||
      pending != oldDelegate.pending;
}
