import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The TruthArmor shield mark, drawn in code so it stays crisp at any size.
///
/// Same geometry as assets/brand/*.svg (100 x 100 design grid).
class TruthArmorMark extends StatelessWidget {
  const TruthArmorMark({
    super.key,
    this.size = 40,
    this.shieldColor = AppColors.navy,
    this.checkColor = AppColors.white,
  });

  /// White shield + blue check, for use on navy backgrounds.
  const TruthArmorMark.onDark({super.key, this.size = 40})
      : shieldColor = AppColors.white,
        checkColor = AppColors.blue;

  final double size;
  final Color shieldColor;
  final Color checkColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'TruthArmor logo',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ShieldPainter(shieldColor: shieldColor, checkColor: checkColor),
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  _ShieldPainter({required this.shieldColor, required this.checkColor});

  final Color shieldColor;
  final Color checkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100.0;
    canvas.save();
    canvas.scale(s, s);

    final shield = Path()
      ..moveTo(50, 7)
      ..lineTo(85, 19)
      ..lineTo(85, 46)
      ..cubicTo(85, 69, 70.5, 85, 50, 93)
      ..cubicTo(29.5, 85, 15, 69, 15, 46)
      ..lineTo(15, 19)
      ..close();
    canvas.drawPath(shield, Paint()..color = shieldColor);

    final check = Path()
      ..moveTo(33.5, 50.5)
      ..lineTo(45, 62)
      ..lineTo(67.5, 39);
    canvas.drawPath(
      check,
      Paint()
        ..color = checkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) =>
      old.shieldColor != shieldColor || old.checkColor != checkColor;
}

/// Full logo: shield mark + "TruthArmor" wordmark (+ optional tagline).
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
    final wordSize = markSize * 0.62;
    final primary = onDark ? AppColors.white : AppColors.navy;
    final accent = onDark ? const Color(0xFF8DB4FF) : AppColors.blue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        onDark ? TruthArmorMark.onDark(size: markSize) : TruthArmorMark(size: markSize),
        SizedBox(width: markSize * 0.22),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Truth', style: TextStyle(color: primary)),
                TextSpan(text: 'Armor', style: TextStyle(color: accent)),
              ]),
              style: TextStyle(
                fontSize: wordSize,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            if (showTagline)
              Text(
                'PAUSE. VERIFY. PROTECT.',
                style: TextStyle(
                  fontSize: wordSize * 0.34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: onDark ? const Color(0xFFB8C4D6) : AppColors.mutedText,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
