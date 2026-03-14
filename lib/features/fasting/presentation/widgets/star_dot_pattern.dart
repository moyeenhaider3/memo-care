import 'package:flutter/material.dart';

/// Subtle star-dot pattern background for Ramadan screen.
/// Uses a CustomPainter to draw small dots arranged in a grid with low opacity.
class StarDotPattern extends StatelessWidget {
  const StarDotPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarDotPainter(),
      size: Size.infinite,
    );
  }
}

class _StarDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    const radius = 1.5;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
