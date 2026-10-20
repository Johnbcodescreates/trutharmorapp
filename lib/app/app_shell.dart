import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/assessment_draft.dart';
import '../screens/check_screen.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/input/ocr_review_screen.dart';
import '../screens/input/screenshot_flow.dart';
import '../screens/quick_scan_screen.dart';
import '../screens/safety_center_screen.dart';
import '../screens/settings_screen.dart';
import '../data/categories.dart';
import '../services/share/share_receiver.dart';
import 'app_state.dart';
import 'navigation.dart';

/// Bottom navigation: HOME · CHECK · HISTORY · SAFETY · SETTINGS
///
/// Also receives "Share → TruthArmor" from other Android apps and opens the
/// right check (shared text → Quick Scan, shared screenshot → read + review).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _pages = <Widget>[
    HomeScreen(),
    CheckScreen(),
    HistoryScreen(),
    SafetyCenterScreen(),
    SettingsScreen(),
  ];

  StreamSubscription<SharedItem>? _shareSub;

  @override
  void initState() {
    super.initState();
    final receiver = ShareReceiver.instance;
    if (receiver.isSupported) {
      _shareSub = receiver.onShare.listen(_handleShare);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final first = await receiver.initialShare();
        if (first != null) _handleShare(first);
      });
    }
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  Future<void> _handleShare(SharedItem item) async {
    if (!mounted) return;
    // Start from the main screen so Back returns somewhere sensible.
    Navigator.of(context).popUntil((r) => r.isFirst);
    context.read<AppState>().setTab(0);

    final path = item.imagePath;
    if (path != null) {
      final text = await ScreenshotFlow.readFile(context, path);
      await ShareReceiver.deleteTempImage(path); // Never keep the image.
      if (text == null || !mounted) return;
      Nav.push(
        context,
        OcrReviewScreen(
          draft: AssessmentDraft(categoryId: Categories.aiMessage.id, text: text, source: InputSource.screenshot),
          quickScan: true,
        ),
      );
      return;
    }

    final text = item.text?.trim() ?? '';
    if (text.isEmpty) return;
    Nav.push(context, QuickScanScreen(initialText: text, shared: true));
  }

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
