import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Profile header section with avatar, name, and badge.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    this.name,
    this.badge,
    this.onEdit,
    super.key,
  });

  final String? name;
  final String? badge;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final displayName = name ?? 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Edit button (top-right)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                onPressed: onEdit,
                tooltip: 'Edit profile',
              ),
            ),

            // Avatar (72px)
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                initial,
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              displayName,
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 4),
              Text(
                badge!,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
