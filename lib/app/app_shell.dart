import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/check_screen.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/safety_center_screen.dart';
import '../screens/settings_screen.dart';
import 'app_state.dart';

/// Bottom navigation: HOME · CHECK · HISTORY · SAFETY · SETTINGS
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _pages = <Widget>[
    HomeScreen(),
    CheckScreen(),
    HistoryScreen(),
    SafetyCenterScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: IndexedStack(index: state.tabIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.tabIndex,
        onDestinationSelected: state.setTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield_rounded), label: 'Check'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'History'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Safety'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
