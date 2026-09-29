import 'package:flutter/material.dart';

import '../models/scan_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/resource_card.dart';

/// HOW TO VERIFY SAFELY — category-specific, independent verification.
class VerifySafelyScreen extends StatelessWidget {
  const VerifySafelyScreen({super.key, required this.category});
  final ScanCategory category;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('How to verify safely')),
      body: PageBody(
        children: [
          // The core TruthArmor principle.
          Container(
            padding: const EdgeInsets.all(Gap.lg - 4),
            decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(Gap.radius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.block_rounded, color: Color(0xFFFCA5A5)),
                    SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text(
                        'Do not use the contact information in the suspicious message to verify it.',
                        style: TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.md - 4),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF86EFAC)),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text(
                        "Instead: visit the organization's official website or use a trusted phone number you already have.",
                        style: t.bodyLarge?.copyWith(color: const Color(0xFFD5DEEA)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          SectionTitle('Steps for: ${category.shortTitle}', icon: category.icon),
          for (var i = 0; i < category.verifySteps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.sm + 2),
              child: SectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.lightBlue,
                      child: Text('${i + 1}', style: t.titleSmall?.copyWith(color: AppColors.blue)),
                    ),
                    const SizedBox(width: Gap.md - 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.verifySteps[i].title, style: t.titleMedium),
                          const SizedBox(height: 2),
                          Text(category.verifySteps[i].detail, style: t.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (category.resources.isNotEmpty) ...[
            const SizedBox(height: Gap.md),
            const SectionTitle('Official help & reporting', icon: Icons.support_agent_rounded),
            for (final r in category.resources) ResourceCard(resource: r),
            Text(
              'Search for these organizations yourself if you prefer — that is always a good habit.',
              style: t.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
