import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The TruthArmor shield mark (from assets/brand/logo_mark.png).
///
/// The artwork has its own silver border, so the same image works on both
/// light backgrounds and the navy splash screen.
class TruthArmorMark extends StatelessWidget {
  const TruthArmorMark({super.key, this.size = 40});

  /// Kept for older call sites — the new logo looks right on dark backgrounds.
  const TruthArmorMark.onDark({super.key, this.size = 40});

  static const assetPath = 'assets/brand/logo_mark.png';

  /// Fits inside a [size] x [size] box.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'TruthArmor logo',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => Icon(Icons.shield_rounded, size: size, color: AppColors.blue),
        ),
      ),
    );
  }
}

/// Full logo: shield mark + "TRUTHARMOR" wordmark (+ optional tagline).
class TruthArmorLogo extends StatelessWidget {
  const TruthArmorLogo({
    super.key,
    this.markSize = 40,
    this.showTagline = false,
    this.onDark = false,
  });

  final double markSize;
  final bool showTagline;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final wordSize = markSize * 0.5;
    final primary = onDark ? AppColors.white : AppColors.navy;
    final accent = onDark ? const Color(0xFF5EA2FF) : const Color(0xFF1D6FE0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TruthArmorMark(size: markSize),
        SizedBox(width: markSize * 0.2),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: 'TRUTH', style: TextStyle(color: primary)),
                TextSpan(text: 'ARMOR', style: TextStyle(color: accent)),
              ]),
              style: TextStyle(
                fontSize: wordSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
                height: 1.05,
              ),
            ),
            if (showTagline)
              Text(
                'Pause. Verify. Protect.',
                style: TextStyle(
                  fontSize: wordSize * 0.46,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: onDark ? const Color(0xFFB8C4D6) : AppColors.text,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
