import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/app_config.dart';
import '../app/app_state.dart';
import '../app/navigation.dart';
import '../data/categories.dart';
import '../data/safety_articles.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/common.dart';
import '../widgets/truth_armor_logo.dart';
import 'article_screen.dart';
import 'demo_examples_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final simple = context.simple;
    final useList = simple || MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return Scaffold(
      body: SafeArea(
        child: PageBody(
          padding: const EdgeInsets.fromLTRB(Gap.md + 4, Gap.md, Gap.md + 4, Gap.xl),
          children: [
            // ── Header ──
            Row(
              children: [
                const TruthArmorLogo(markSize: 38, showTagline: true),
                const Spacer(),
                if (AppConfig.isDemoMode) const Pill.demo('DEMO MODE'),
              ],
            ),
            const SizedBox(height: Gap.lg),

            // ── Main card ──
            Container(
              padding: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Gap.radius + 4),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.navy, Color(0xFF123A63)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What would you like to check?', style: t.headlineMedium?.copyWith(color: AppColors.white)),
                  const SizedBox(height: Gap.sm + 2),
                  Text(
                    simple
                        ? 'Pick what you are worried about. You can add a screenshot, paste the message, or answer a few questions.'
                        : "Choose the situation that best matches what you're dealing with. You can upload a screenshot, "
                            'paste information, or answer a few questions.',
                    style: t.bodyLarge?.copyWith(color: const Color(0xFFD5DEEA)),
                  ),
                  const SizedBox(height: Gap.lg - 4),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.navy,
                      ),
                      onPressed: () => Nav.quickScan(context),
                      icon: const Icon(Icons.bolt_rounded, color: AppColors.blue, size: 26),
                      label: const Text('QUICK SCAN'),
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  Center(
                    child: Text(
                      'Screenshot · Text · Link · Message',
                      style: t.bodySmall?.copyWith(color: const Color(0xFFB8C4D6)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.xl - 4),

            // ── Audiences ──
            Text('Protecting the people you care about', style: t.titleLarge),
            const SizedBox(height: Gap.md - 4),
            Row(
              children: [
                Expanded(
                  child: _AudienceCard(
                    icon: Icons.elderly_rounded,
                    label: 'SENIORS',
                    onTap: () {
                      final a = articleById('elder_fraud');
                      if (a != null) Nav.push(context, ArticleScreen(article: a));
                    },
                  ),
                ),
                const SizedBox(width: Gap.sm + 2),
                Expanded(
                  child: _AudienceCard(
                    icon: Icons.school_outlined,
                    label: 'YOUTH',
                    onTap: () => Nav.openCategory(context, Categories.youth),
                  ),
                ),
                const SizedBox(width: Gap.sm + 2),
                Expanded(
                  child: _AudienceCard(
                    icon: Icons.family_restroom_rounded,
                    label: 'FAMILIES',
                    onTap: () => context.read<AppState>().setTab(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.xl - 4),

            // ── Categories ──
            Text('Choose a situation', style: t.titleLarge),
            const SizedBox(height: Gap.md - 4),
            if (useList)
              for (final c in Categories.all) CategoryTile(category: c, onTap: () => Nav.openCategory(context, c))
            else
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: Gap.sm + 4,
                crossAxisSpacing: Gap.sm + 4,
                childAspectRatio: 0.78,
                children: [
                  for (final c in Categories.all)
                    CategoryCard(category: c, onTap: () => Nav.openCategory(context, c)),
                ],
              ),
            const SizedBox(height: Gap.lg),

            // ── Demo examples ──
            SectionCard(
              onTap: () => Nav.push(context, const DemoExamplesScreen()),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_outline_rounded, color: AppColors.blue, size: 32),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Try a demo example', style: t.titleMedium),
                        Text('See how TruthArmor works using safe, fictional scenarios.', style: t.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: Gap.md, horizontal: Gap.sm),
      child: Column(
        children: [
          Icon(icon, color: AppColors.navy, size: 32),
          const SizedBox(height: Gap.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1, color: AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}
