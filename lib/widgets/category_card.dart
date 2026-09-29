import 'package:flutter/material.dart';

import '../models/scan_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Grid card: icon, title, short explanation, and a "Check" affordance.
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.onTap});
  final ScanCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Check: ${category.title}',
      child: SectionCard(
        onTap: onTap,
        padding: const EdgeInsets.all(Gap.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconTile(icon: category.icon),
            const SizedBox(height: Gap.sm + 4),
            Text(category.shortTitle, style: t.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                category.simpleDescription,
                style: t.bodySmall,
                overflow: TextOverflow.fade,
              ),
            ),
            const SizedBox(height: Gap.xs),
            Row(
              children: [
                Text('Check', style: t.labelMedium?.copyWith(color: AppColors.blue)),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width list row version (Check tab, Simple Mode).
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, required this.onTap});
  final ScanCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm + 4),
      child: Semantics(
        button: true,
        label: 'Check: ${category.title}',
        child: SectionCard(
          onTap: onTap,
          padding: const EdgeInsets.all(Gap.md),
          child: Row(
            children: [
              _IconTile(icon: category.icon),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.title, style: t.titleMedium),
                    const SizedBox(height: 2),
                    Text(category.simpleDescription, style: t.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: AppColors.blue, size: 26),
    );
  }
}
