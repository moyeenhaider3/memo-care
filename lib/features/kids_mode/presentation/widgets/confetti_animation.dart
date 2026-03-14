import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

class ConfettiAnimation extends StatefulWidget {
  const ConfettiAnimation({super.key});

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  static const _particleCount = 50;

  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    final random = math.Random(42);
    _particles = List.generate(_particleCount, (_) {
      return _ConfettiParticle(
        xFactor: random.nextDouble(),
        wobblePhase: random.nextDouble() * math.pi * 2,
        wobbleAmp: 0.01 + random.nextDouble() * 0.03,
        size: 4 + random.nextDouble() * 8,
        delay: random.nextDouble(),
        speed: 0.65 + random.nextDouble() * 0.35,
        color: _kPalette[random.nextInt(_kPalette.length)],
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

const _kPalette = <Color>[
  KidsColors.primary,
  KidsColors.warmYellow,
  KidsColors.playfulGreen,
  KidsColors.coralPink,
  Color(0xFFEF4444),
];

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.xFactor,
    required this.wobblePhase,
    required this.wobbleAmp,
    required this.size,
    required this.delay,
    required this.speed,
    required this.color,
  });

  final double xFactor;
  final double wobblePhase;
  final double wobbleAmp;
  final double size;
  final double delay;
  final double speed;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()..color = particle.color;
      final local = ((progress + particle.delay) % 1.0);
      final y = local * size.height * particle.speed;
      final wobble = math.sin(local * math.pi * 6 + particle.wobblePhase) *
          size.width *
          particle.wobbleAmp;
      final x = particle.xFactor * size.width + wobble;

      canvas.drawCircle(Offset(x, y), particle.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
