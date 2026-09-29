import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../data/safety_articles.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'article_screen.dart';

/// SAFETY CENTER — plain-language education.
class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Center')),
      body: PageBody(
        children: [
          Text('Learn the warning signs', style: t.headlineSmall),
          const SizedBox(height: Gap.xs),
          Text('Short guides for every age. Share them with the people you care about.', style: t.bodyLarge),
          const SizedBox(height: Gap.lg),
          for (final a in kSafetyArticles)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.sm + 2),
              child: SectionCard(
                onTap: () => Nav.push(context, ArticleScreen(article: a)),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(14)),
                      child: Icon(a.icon, color: AppColors.blue),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(child: Text(a.title, style: t.titleMedium)),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText, size: 28),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
