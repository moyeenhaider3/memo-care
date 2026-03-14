import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/presentation/widgets/memo_fab.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';

/// Shell widget providing a 5-tab [NavigationBar] and centered FAB.
///
/// Tabs: Home | Schedule | (Add) | History | Profile
///
/// The "Add" destination (index 2) is a placeholder — tapping it
/// navigates to `/add-reminder` via the FAB instead of switching
/// to a shell branch.
///
/// Uses [StatefulNavigationShell] to preserve tab state.
class AppShell extends StatelessWidget {
  /// Creates an [AppShell] wrapping the given [navigationShell].
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  /// The stateful navigation shell that manages tab state.
  final StatefulNavigationShell navigationShell;

  /// Maps a 5-tab destination index to a 4-branch shell index.
  ///
  /// Index 2 (Add) is intercepted in [_onDestinationSelected] and
  /// never reaches here, so indices 3 and 4 become branches 2 and 3.
  static int _toBranchIndex(int destinationIndex) {
    if (destinationIndex < 2) return destinationIndex;
    return destinationIndex - 1; // 3→2, 4→3
  }

  /// Maps a 4-branch shell index back to a 5-tab destination index.
  static int _toDestinationIndex(int branchIndex) {
    if (branchIndex < 2) return branchIndex;
    return branchIndex + 1; // 2→3, 3→4
  }

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == 2) {
      // "Add" tab — navigate to add-reminder route
      context.push(AppRoutes.addReminder);
      return;
    }
    final branch = _toBranchIndex(index);
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: MemoFab(
        onPressed: () => context.push(AppRoutes.addReminder),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _toDestinationIndex(navigationShell.currentIndex),
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
        height: AppSpacing.navBarHeight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: AppSpacing.navIconSize),
            selectedIcon: Icon(Icons.home, size: AppSpacing.navIconSize),
            label: 'Home',
            tooltip: "Home tab — Today's reminders",
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_today_outlined,
              size: AppSpacing.navIconSize,
            ),
            selectedIcon: Icon(
              Icons.calendar_today,
              size: AppSpacing.navIconSize,
            ),
            label: 'Schedule',
            tooltip: 'Schedule tab — Full day view',
          ),
          // Placeholder for the FAB gap — tapping navigates to /add-reminder
          NavigationDestination(
            icon: SizedBox(
              width: AppSpacing.navIconSize,
              height: AppSpacing.navIconSize,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history_outlined,
              size: AppSpacing.navIconSize,
            ),
            selectedIcon: Icon(
              Icons.history,
              size: AppSpacing.navIconSize,
            ),
            label: 'History',
            tooltip: 'History tab — Medication log',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outlined,
              size: AppSpacing.navIconSize,
            ),
            selectedIcon: Icon(
              Icons.person,
              size: AppSpacing.navIconSize,
            ),
            label: 'Profile',
            tooltip: 'Profile tab — Settings & preferences',
          ),
        ],
      ),
    );
  }
}
