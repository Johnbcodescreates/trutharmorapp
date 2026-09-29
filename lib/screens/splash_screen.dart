import 'package:flutter/material.dart';

import '../app/app_shell.dart';
import '../theme/app_colors.dart';
import '../widgets/truth_armor_logo.dart';

/// Minimal branded splash: shield + name + tagline, gentle fade.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const AppShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(fade),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TruthArmorMark.onDark(size: 96),
                SizedBox(height: 20),
                Text(
                  'TruthArmor',
                  style: TextStyle(color: AppColors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                SizedBox(height: 8),
                Text(
                  'Pause. Verify. Protect.',
                  style: TextStyle(color: Color(0xFFB8C4D6), fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
