import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../data/categories.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/common.dart';

/// CHECK tab: start a new assessment.
class CheckScreen extends StatelessWidget {
  const CheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Start a check')),
      body: PageBody(
        children: [
          SectionCard(
            color: AppColors.lightBlue,
            borderColor: AppColors.lightBlue,
            onTap: () => Nav.quickScan(context),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.white, size: 30),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Scan', style: t.titleLarge),
                      Text("Not sure which kind it is? Add it and we'll suggest one.", style: t.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.navy, size: 28),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          Text('Or choose a situation', style: t.titleLarge),
          const SizedBox(height: Gap.md - 4),
          for (final c in Categories.all) CategoryTile(category: c, onTap: () => Nav.openCategory(context, c)),
        ],
      ),
    );
  }
}
