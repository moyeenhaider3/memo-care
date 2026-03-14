import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

class GoldStarAnimation extends StatefulWidget {
  const GoldStarAnimation({super.key});

  @override
  State<GoldStarAnimation> createState() => _GoldStarAnimationState();
}

class _GoldStarAnimationState extends State<GoldStarAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(
      begin: 0,
      end: 1,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: KidsColors.warmYellow.withAlpha(80),
                width: 4,
              ),
            ),
          ),
          const Icon(
            Icons.star_rounded,
            size: 132,
            color: KidsColors.warmYellow,
          ),
        ],
      ),
    );
  }
}
