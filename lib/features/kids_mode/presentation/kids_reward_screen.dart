import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/kids_theme.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/bonus_points_display.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/celebration_text.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/confetti_animation.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/gold_star_animation.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/waving_mascot.dart';

class KidsRewardScreen extends StatelessWidget {
  const KidsRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: KidsTheme.data,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const ConfettiAnimation(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: KidsColors.warmYellow,
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A7C3AED),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GoldStarAnimation(),
                        SizedBox(height: 18),
                        WavingMascot(),
                        SizedBox(height: 18),
                        CelebrationText(),
                        SizedBox(height: 22),
                        BonusPointsDisplay(),
                        SizedBox(height: 22),
                        _BackButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/kids'),
        style: ElevatedButton.styleFrom(
          backgroundColor: KidsColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Text(
          'Back to Dashboard',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
