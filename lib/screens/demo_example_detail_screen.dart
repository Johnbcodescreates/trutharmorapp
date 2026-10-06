import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../data/categories.dart';
import '../data/demo_examples.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/example_content_card.dart';

/// Shows exactly what a DEMO EXAMPLE contains before it is analyzed,
/// so viewers (and judges) can read the message themselves first.
class DemoExampleDetailScreen extends StatelessWidget {
  const DemoExampleDetailScreen({super.key, required this.example});
  final DemoExample example;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final category = Categories.byId(example.categoryId);

    return Scaffold(
      appBar: AppBar(title: const Text('Demo example')),
      body: PageBody(
        children: [
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              const Pill.demo('DEMO EXAMPLE'),
              Pill(category.shortTitle.toUpperCase(), icon: category.icon),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(example.title, style: t.headlineSmall),
          const SizedBox(height: Gap.xs),
          Text(example.subtitle, style: t.bodyLarge?.copyWith(color: AppColors.mutedText)),
          const SizedBox(height: Gap.lg),
          ExampleContentCard(categoryId: example.categoryId, text: example.text, answers: example.answers),
          const SizedBox(height: Gap.lg),
          Text(
            'Read it yourself first: would you trust it? Then see what TruthArmor finds.',
            style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: AppColors.mutedText),
          ),
          const SizedBox(height: Gap.md),
          WideButton(
            label: 'Analyze this example',
            icon: Icons.shield_outlined,
            onPressed: () => Nav.analyze(context, example.toDraft()),
          ),
          const SizedBox(height: Gap.md),
          Text(
            'This scenario is fictional. Names, companies, links, and numbers are invented.',
            textAlign: TextAlign.center,
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}
