import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../data/categories.dart';
import '../data/safety_articles.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// One Safety Center article, always in the same five parts.
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article, this.showCheckButton = true});
  final SafetyArticle article;
  final bool showCheckButton;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final a = article;

    Widget section(int n, String title, Widget body) => Padding(
          padding: const EdgeInsets.only(bottom: Gap.md),
          child: SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.lightBlue,
                      child: Text('$n', style: t.labelMedium?.copyWith(color: AppColors.blue)),
                    ),
                    const SizedBox(width: Gap.sm + 2),
                    Expanded(child: Text(title, style: t.titleMedium)),
                  ],
                ),
                const SizedBox(height: Gap.sm + 2),
                body,
              ],
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Safety Center')),
      body: PageBody(
        children: [
          Row(
            children: [
              Icon(a.icon, color: AppColors.blue, size: 34),
              const SizedBox(width: Gap.md - 4),
              Expanded(child: Text(a.title, style: t.headlineSmall)),
            ],
          ),
          const SizedBox(height: Gap.lg),
          section(1, 'What it looks like', Text(a.looksLike, style: t.bodyLarge)),
          section(2, 'Common warning signs', BulletList(a.warningSigns, icon: Icons.warning_amber_rounded, iconSize: 18, iconColor: AppColors.navy)),
          section(3, 'What scammers want', Text(a.scammersWant, style: t.bodyLarge)),
          section(4, 'What you should do', BulletList(a.whatToDo, icon: Icons.check_circle_outline_rounded, iconSize: 18)),
          section(5, 'How to verify safely', BulletList(a.howToVerify, icon: Icons.verified_user_outlined, iconSize: 18)),
          if (showCheckButton && a.categoryId != null) ...[
            const SizedBox(height: Gap.sm),
            WideButton(
              label: 'Check something now',
              icon: Icons.shield_outlined,
              onPressed: () => Nav.openCategory(context, Categories.byId(a.categoryId!)),
            ),
          ],
        ],
      ),
    );
  }
}
