import 'package:flutter/material.dart';

import '../data/categories.dart';
import '../models/question.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Shows the actual content of a DEMO EXAMPLE: the message itself, plus any
/// extra details (answers) that come with it.
class ExampleContentCard extends StatelessWidget {
  const ExampleContentCard({
    super.key,
    required this.categoryId,
    required this.text,
    this.answers = const {},
  });

  final String categoryId;
  final String text;
  final Map<String, dynamic> answers;

  static String formatAnswer(dynamic value) {
    if (value is List) return value.whereType<String>().join(', ');
    return switch (value) {
      YesNo.yes => 'Yes',
      YesNo.no => 'No',
      YesNo.unsure => 'Not sure',
      _ => '$value',
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final category = Categories.byId(categoryId);
    final details = <(String, String)>[
      for (final q in category.questions)
        if (answers[q.id] != null && formatAnswer(answers[q.id]).trim().isNotEmpty)
          (q.label, formatAnswer(answers[q.id])),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (text.trim().isNotEmpty) ...[
          const SectionTitle('The message', icon: Icons.chat_bubble_outline_rounded),
          Container(
            padding: const EdgeInsets.all(Gap.md + 2),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(Gap.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 24,
                  margin: const EdgeInsets.only(right: Gap.md - 4, top: 2),
                  decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(2)),
                ),
                Expanded(child: SelectableText(text.trim(), style: t.bodyLarge?.copyWith(height: 1.5))),
              ],
            ),
          ),
        ],
        if (details.isNotEmpty) ...[
          const SizedBox(height: Gap.md),
          const SectionTitle('Extra details', icon: Icons.checklist_rounded),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (label, value) in details)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: t.bodySmall),
                        Text(value, style: t.titleSmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
