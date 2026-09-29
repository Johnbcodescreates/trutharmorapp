import 'package:flutter/material.dart';

import '../models/risk.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// The large risk indicator at the top of the results screen.
class RiskHero extends StatelessWidget {
  const RiskHero({super.key, required this.level, required this.headline, required this.score});
  final RiskLevel level;
  final String headline;
  final int score;

  @override
  Widget build(BuildContext context) {
    final style = RiskStyle.of(level);
    final t = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: 'Risk level: ${level.label}. $headline',
      child: Container(
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(Gap.radius),
          border: Border.all(color: style.color.withAlpha(70), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(color: style.color, borderRadius: BorderRadius.circular(99)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style.icon, color: style.onColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        level.label,
                        style: TextStyle(color: style.onColor, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.md),
            Text(headline, style: t.headlineSmall),
            const SizedBox(height: Gap.md),
            RiskMeter(score: score),
          ],
        ),
      ),
    );
  }
}

/// Four-band spectrum (green → yellow → orange → red) with a marker.
class RiskMeter extends StatelessWidget {
  const RiskMeter({super.key, required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: LayoutBuilder(builder: (context, c) {
        final x = (score.clamp(0, 100) / 100.0) * c.maxWidth;
        return SizedBox(
          height: 26,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const Row(
                    children: [
                      Expanded(flex: 25, child: SizedBox(height: 8, child: ColoredBox(color: AppColors.riskLow))),
                      Expanded(flex: 25, child: SizedBox(height: 8, child: ColoredBox(color: AppColors.riskCaution))),
                      Expanded(flex: 25, child: SizedBox(height: 8, child: ColoredBox(color: AppColors.riskElevated))),
                      Expanded(flex: 25, child: SizedBox(height: 8, child: ColoredBox(color: AppColors.riskHigh))),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: (x - 9).clamp(0, c.maxWidth - 18).toDouble(),
                top: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.navy, width: 3),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Small badge used in history rows.
class RiskChip extends StatelessWidget {
  const RiskChip({super.key, required this.level});
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final s = RiskStyle.of(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: s.background, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 16, color: level == RiskLevel.caution ? AppColors.onCaution : s.color),
          const SizedBox(width: 5),
          Text(
            level.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: level == RiskLevel.caution ? AppColors.onCaution : s.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// "What we found" row: signal group + level.
class GroupRow extends StatelessWidget {
  const GroupRow({super.key, required this.breakdown, required this.simple});
  final GroupBreakdown breakdown;
  final bool simple;

  Color get _color => switch (breakdown.level) {
        GroupLevel.none => AppColors.mutedText,
        GroupLevel.low => AppColors.riskLow,
        GroupLevel.moderate => AppColors.onCaution,
        GroupLevel.high => AppColors.riskHigh,
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final filled = switch (breakdown.level) {
      GroupLevel.none => 0,
      GroupLevel.low => 1,
      GroupLevel.moderate => 2,
      GroupLevel.high => 3,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              simple ? breakdown.group.simpleLabel : breakdown.group.label,
              style: t.bodyLarge,
            ),
          ),
          for (var i = 0; i < 3; i++)
            Container(
              width: 16,
              height: 8,
              margin: const EdgeInsets.only(left: 3),
              decoration: BoxDecoration(
                color: i < filled ? _color : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(
              breakdown.level.label,
              textAlign: TextAlign.right,
              style: t.labelMedium?.copyWith(color: _color, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
