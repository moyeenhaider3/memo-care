import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Greeting header with circular avatar and time-based greeting.
///
// ignore: comment_references // workaround
/// Shows "Good morning/afternoon/evening, [Name]" text with
/// the current date below it.
class UserGreetingHeader extends StatelessWidget {
  const UserGreetingHeader({this.userName, super.key});

  /// User name to display. Defaults to 'there' if null.
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final name = userName ?? 'there';
    final greeting = _greeting;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Circular avatar (48px)
          Semantics(
            label: 'User avatar for $name',
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                initial,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Greeting + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    '$greeting, $name',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedDate,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Notification bell
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textSecondary,
            iconSize: 24,
            tooltip: 'Notifications',
            onPressed: () {
              // TODO(memo-care): Wire to notifications screen
            },
          ),
        ],
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _formattedDate {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, '
        '${months[now.month - 1]} ${now.day}';
  }
}
