import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/splash_screen.dart';
import '../theme/app_theme.dart';
import 'app_state.dart';

class TruthArmorApp extends StatelessWidget {
  const TruthArmorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final simple = context.select<AppState, bool>((s) => s.simpleMode);
    return MaterialApp(
      title: 'TruthArmor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(simpleMode: simple),
      // Simple Mode enlarges text on top of the user's system text size.
      builder: (context, child) {
        if (!simple) return child ?? const SizedBox.shrink();
        final mq = MediaQuery.of(context);
        final current = mq.textScaler.scale(10) / 10;
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear((current * 1.2).clamp(1.2, 2.2))),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
