import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

class WavingMascot extends StatefulWidget {
  const WavingMascot({super.key});

  @override
  State<WavingMascot> createState() => _WavingMascotState();
}

class _WavingMascotState extends State<WavingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle = -10 + (20 * _controller.value);
        return Transform.rotate(
          angle: angle * math.pi / 180,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: KidsColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 62,
              color: KidsColors.primary,
            ),
          ),
        );
      },
    );
  }
}
