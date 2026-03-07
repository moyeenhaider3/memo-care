import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell widget providing [NavigationBar] for the main app tabs.
///
/// Wraps Home, History, and Settings screens in a shared scaffold
/// with persistent bottom navigation. Uses [StatefulNavigationShell]
/// to preserve tab state across navigation.
///
/// Accessibility:
/// - All touch targets >= 56 dp
/// - Icons at 28 dp for elderly visibility
/// - Semantics labels on every tab
class AppShell extends StatelessWidget {
  /// Creates an [AppShell] wrapping the given [navigationShell].
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  /// The stateful navigation shell that manages tab state.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation:
                index == navigationShell.currentIndex,
          );
        },
        height: 72, // ensures 56 dp+ touch targets with padding
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 28),
            selectedIcon: Icon(Icons.home, size: 28),
            label: 'Home',
            tooltip: "Home tab — Today's reminders",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined, size: 28),
            selectedIcon: Icon(Icons.history, size: 28),
            label: 'History',
            tooltip: 'History tab — Medication log',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 28),
            selectedIcon: Icon(Icons.settings, size: 28),
            label: 'Settings',
            tooltip: 'Settings tab — Preferences',
          ),
        ],
      ),
    );
  }
}
