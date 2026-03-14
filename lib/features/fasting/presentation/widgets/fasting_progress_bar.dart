import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

/// Horizontal gradient progress bar showing fast completion percentage.
/// Has an animated position dot with glow effect at the current time position.
class FastingProgressBar extends StatelessWidget {
  const FastingProgressBar({
    required this.progress,
    required this.sehriLabel,
    required this.iftarLabel,
    super.key,
  });

  /// 0.0 to 1.0 fraction of fast completed.
  final double progress;
  final String sehriLabel;
  final String iftarLabel;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();

    return Column(
      children: [
        // Labels + percentage.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sehriLabel,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white38,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '$pct% of fast completed',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: RamadanColors.iftarGold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              iftarLabel,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white38,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Progress bar with dot.
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final dotX = (barWidth * progress).clamp(4.0, barWidth - 4.0);

            return SizedBox(
              height: 18,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Background track.
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withAlpha(13),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 600),
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                RamadanColors.sehriBlue.withAlpha(150),
                                RamadanColors.iftarGold,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Glowing position dot.
                  Positioned(
                    left: dotX - 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withAlpha(200),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
