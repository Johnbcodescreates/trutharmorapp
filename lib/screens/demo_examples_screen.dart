import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../data/categories.dart';
import '../data/demo_examples.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// DEMO EXAMPLES — safe, fictional scenarios for demonstrations.
class DemoExamplesScreen extends StatelessWidget {
  const DemoExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Demo examples')),
      body: PageBody(
        children: [
          const Pill.demo('DEMO EXAMPLES'),
          const SizedBox(height: Gap.sm + 4),
          Text(
            'These scenarios are entirely fictional and contain no real personal information. '
            'They run through the same analysis as a real check.',
            style: t.bodyLarge,
          ),
          const SizedBox(height: Gap.lg),
          for (final e in kDemoExamples)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.sm + 2),
              child: SectionCard(
                onTap: () => Nav.analyze(context, e.toDraft()),
                child: Row(
                  children: [
                    Icon(Categories.byId(e.categoryId).icon, color: AppColors.blue, size: 28),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(e.title, style: t.titleMedium)),
                              if (e.featured) ...[
                                const SizedBox(width: Gap.sm),
                                const Icon(Icons.star_rounded, size: 18, color: AppColors.blue),
                              ],
                            ],
                          ),
                          Text(e.subtitle, style: t.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.play_arrow_rounded, color: AppColors.blue),
                  ],
                ),
              ),
            ),
          const SizedBox(height: Gap.sm),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.blue),
              const SizedBox(width: 6),
              Expanded(child: Text('Featured: senior and youth protection scenarios', style: t.bodySmall)),
            ],
          ),
        ],
      ),
    );
  }
}
