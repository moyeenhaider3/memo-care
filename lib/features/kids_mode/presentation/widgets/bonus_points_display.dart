import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

class BonusPointsDisplay extends StatefulWidget {
  const BonusPointsDisplay({
    super.key,
    this.points = 50,
  });

  final int points;

  @override
  State<BonusPointsDisplay> createState() => _BonusPointsDisplayState();
}

class _BonusPointsDisplayState extends State<BonusPointsDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<int> _count;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _count = IntTween(begin: 0, end: widget.points).animate(_controller);
    // ignore: discarded_futures // workaround
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: KidsColors.warmYellow,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33FBBF24),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _count,
          builder: (context, _) {
            return Text(
              '+${_count.value} Bonus Points!',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5B3A00),
              ),
            );
          },
        ),
      ),
    );
  }
}
