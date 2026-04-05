import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/platform/permission_service.dart';
import 'package:memo_care/core/presentation/widgets/memo_fab.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/features/common/presentation/widgets/channel_disabled_banner.dart';

/// Shell widget providing a 5-tab [NavigationBar] and centered FAB.
///
/// Tabs: Home | Schedule | (Add) | History | Profile
///
/// The "Add" destination (index 2) is a placeholder — tapping it
/// navigates to `/add-reminder` via the FAB instead of switching
/// to a shell branch.
///
/// Uses [StatefulNavigationShell] to preserve tab state.
class AppShell extends StatefulWidget {
  /// Creates an [AppShell] wrapping the given [navigationShell].
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  /// The stateful navigation shell that manages tab state.
  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _launchPermissionsChecked = false;
  var _permissionFlowInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ignore: discarded_futures // workaround
      _requestMissingPermissionsOnLaunch();
    });
  }

  Future<void> _requestMissingPermissionsOnLaunch() async {
    if (!mounted || _launchPermissionsChecked || _permissionFlowInProgress) {
      return;
    }

    _launchPermissionsChecked = true;
    final permissionService = PermissionService();
    final status = await permissionService.checkAllCritical();
    if (!mounted || status.allGranted) return;

    _permissionFlowInProgress = true;
    try {
      if (!status.notifications) {
        await permissionService.requestNotificationPermission(
          context: context,
        );
        if (!mounted) return;
      }

      if (!status.exactAlarms) {
        await permissionService.requestExactAlarmPermission(
          context: context,
        );
        if (!mounted) return;
      }

      if (!status.batteryOptimization) {
        await permissionService.requestBatteryOptimization(
          context: context,
        );
        if (!mounted) return;
      }

      if (!status.fullScreenIntent) {
        await permissionService.requestFullScreenIntentPermission(
          context: context,
        );
      }
    } finally {
      _permissionFlowInProgress = false;
    }
  }

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
      // ignore: discarded_futures // workaround
      context.push(AppRoutes.addReminder);
      return;
    }
    final branch = _toBranchIndex(index);
    widget.navigationShell.goBranch(
      branch,
      initialLocation: branch == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ChannelDisabledBanner(),
          Expanded(child: widget.navigationShell),
        ],
      ),
      floatingActionButton: MemoFab(
        onPressed: () => context.push(AppRoutes.addReminder),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _toDestinationIndex(widget.navigationShell.currentIndex),
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
