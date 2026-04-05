import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

/// Robot mascot widget with idle bobbing animation and speech bubble.
///
/// Positioned in the layout (not fixed overlay) so it doesn't block content.
/// In test mode the animation does NOT start (avoids infinite-loop issues).
class MascotWidget extends StatefulWidget {
  const MascotWidget({
    this.message = 'Keep going! 🚀',
    super.key,
  });

  final String message;

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bobAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Avoid infinite animation in test environment.
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    );
    if (!isTest) {
      // ignore: discarded_futures // workaround
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speech bubble.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: KidsColors.primary.withAlpha(15),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: KidsColors.primary.withAlpha(40),
            ),
          ),
          child: Text(
            widget.message,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: KidsColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Bobbing robot icon.
        AnimatedBuilder(
          animation: _bobAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bobAnimation.value),
              child: child,
            );
          },
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: KidsColors.primary.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: KidsColors.primary.withAlpha(25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 44,
              color: KidsColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
