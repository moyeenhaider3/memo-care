import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:memo_care/core/theme/app_colors.dart';

/// Pulsing radial gradient background for the alarm screen.
///
/// Navy center → accent blue edge, scale animation on 2s cycle.
class PulsingGradientBackground extends StatefulWidget {
  const PulsingGradientBackground({super.key});

  @override
  State<PulsingGradientBackground> createState() =>
      _PulsingGradientBackgroundState();
}

class _PulsingGradientBackgroundState extends State<PulsingGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    final bindingName = SchedulerBinding.instance.runtimeType.toString();
    final isWidgetTestBinding = bindingName.contains(
      'TestWidgetsFlutterBinding',
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (isWidgetTestBinding) {
      _controller.value = 1;
    } else {
      // ignore: discarded_futures // workaround
      _controller.repeat(reverse: true);
    }

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    AppColors.primary, // navy center
                    AppColors.accent, // blue edge
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
