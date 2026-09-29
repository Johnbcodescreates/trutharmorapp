import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../models/risk.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

extension SimpleModeX on BuildContext {
  /// True when Senior-Friendly Simple Mode is on.
  bool get simple => Provider.of<AppState>(this).simpleMode;

  /// Pick standard or simple wording.
  String pick(String standard, String? simpleText) =>
      (simple && simpleText != null && simpleText.isNotEmpty) ? simpleText : standard;
}

/// Colors + icon for each risk level. Risk colors appear ONLY here.
class RiskStyle {
  const RiskStyle(this.color, this.background, this.onColor, this.icon);
  final Color color;
  final Color background;
  final Color onColor;
  final IconData icon;

  static RiskStyle of(RiskLevel level) => switch (level) {
        RiskLevel.low => const RiskStyle(AppColors.riskLow, AppColors.riskLowBg, Colors.white, Icons.check_circle_rounded),
        RiskLevel.caution =>
          const RiskStyle(AppColors.riskCaution, AppColors.riskCautionBg, AppColors.onCaution, Icons.error_outline_rounded),
        RiskLevel.elevated =>
          const RiskStyle(AppColors.riskElevated, AppColors.riskElevatedBg, Colors.white, Icons.warning_amber_rounded),
        RiskLevel.high => const RiskStyle(AppColors.riskHigh, AppColors.riskHighBg, Colors.white, Icons.gpp_bad_rounded),
      };
}

/// White rounded card with a subtle shadow.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding, this.color, this.onTap, this.borderColor});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding ?? const EdgeInsets.all(Gap.md + 2), child: child);
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular(Gap.radius),
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A0B1F33), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Gap.radius),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// Section heading used on results and forms.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.icon, this.trailing});
  final String text;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm + 2),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.blue, size: 22),
            const SizedBox(width: Gap.sm),
          ],
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.navy, fontSize: 13),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Bullet list with readable spacing.
class BulletList extends StatelessWidget {
  const BulletList(this.items, {super.key, this.icon = Icons.circle, this.iconColor = AppColors.blue, this.iconSize = 8});
  final List<String> items;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: iconSize < 12 ? 8 : 2, right: 12),
                  child: Icon(icon, size: iconSize, color: iconColor),
                ),
                Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyLarge)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Small pill label, e.g. "DEMO EXAMPLE".
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = AppColors.blue, this.background = AppColors.lightBlue, this.icon});
  final String text;
  final Color color;
  final Color background;
  final IconData? icon;

  const Pill.demo(this.text, {super.key})
      : color = const Color(0xFF6D28D9),
        background = const Color(0xFFF1EAFE),
        icon = Icons.science_outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
          // No Flexible here: Pill is often placed inside a Row (unbounded width).
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

/// The standard disclaimer — readable but not dominant.
class DisclaimerBox extends StatelessWidget {
  const DisclaimerBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withAlpha(128),
        borderRadius: BorderRadius.circular(Gap.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.mutedText),
          const SizedBox(width: Gap.sm + 2),
          Expanded(
            child: Text(kAssessmentDisclaimer, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// Reminder not to type highly sensitive data into TruthArmor.
class SensitiveDataNotice extends StatelessWidget {
  const SensitiveDataNotice({super.key, this.detected = false});

  /// True when we actually spotted something sensitive in the input.
  final bool detected;

  @override
  Widget build(BuildContext context) {
    final color = detected ? AppColors.riskHigh : AppColors.mutedText;
    return Container(
      padding: const EdgeInsets.all(Gap.md - 2),
      decoration: BoxDecoration(
        color: detected ? AppColors.riskHighBg : AppColors.white,
        borderRadius: BorderRadius.circular(Gap.radiusSm),
        border: Border.all(color: detected ? AppColors.riskHigh.withAlpha(90) : AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, size: 20, color: color),
          const SizedBox(width: Gap.sm + 2),
          Expanded(
            child: Text(
              detected
                  ? 'It looks like this includes sensitive information. It will be hidden before any AI analysis — '
                      'but please remove it if you can. Do not enter passwords, Social Security numbers, '
                      'authentication codes, or complete bank account numbers into TruthArmor.'
                  : 'Do not enter passwords, Social Security numbers, authentication codes, or complete bank account '
                      'numbers into TruthArmor.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: detected ? AppColors.text : null),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width primary button with an optional icon.
class WideButton extends StatelessWidget {
  const WideButton({super.key, required this.label, required this.onPressed, this.icon, this.outlined = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 22), const SizedBox(width: 10)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: onPressed, child: child)
          : FilledButton(onPressed: onPressed, child: child),
    );
  }
}

/// Friendly inline error message.
class FriendlyError extends StatelessWidget {
  const FriendlyError(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: AppColors.riskCautionBg,
        borderRadius: BorderRadius.circular(Gap.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.onCaution),
          const SizedBox(width: Gap.sm + 2),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Consistent padded, scrollable page body with a max width (tablets).
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.padding});
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: padding ?? const EdgeInsets.fromLTRB(Gap.md + 4, Gap.sm, Gap.md + 4, Gap.xl + Gap.lg),
            children: children,
          ),
        ),
      ),
    );
  }
}
