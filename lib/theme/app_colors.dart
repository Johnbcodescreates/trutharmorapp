import 'package:flutter/material.dart';

/// TruthArmor brand palette.
///
/// Brand identity = navy / blue / white. Risk colors are used ONLY to
/// communicate risk (badges, meters) — never as decoration.
class AppColors {
  AppColors._();

  // Brand
  static const Color navy = Color(0xFF0B1F33);
  static const Color blue = Color(0xFF2563EB);
  static const Color lightBlue = Color(0xFFE8F1FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F9FC);
  static const Color text = Color(0xFF172033);
  static const Color mutedText = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);

  // Risk (communication only)
  static const Color riskLow = Color(0xFF16A34A);
  static const Color riskCaution = Color(0xFFEAB308);
  static const Color riskElevated = Color(0xFFEA580C);
  static const Color riskHigh = Color(0xFFDC2626);

  // Tinted backgrounds for risk cards (soft, readable)
  static const Color riskLowBg = Color(0xFFEAF7EE);
  static const Color riskCautionBg = Color(0xFFFEF8E1);
  static const Color riskElevatedBg = Color(0xFFFFF0E6);
  static const Color riskHighBg = Color(0xFFFDECEC);

  // Dark text to pair with the yellow badge (yellow + white fails contrast)
  static const Color onCaution = Color(0xFF422006);
}
