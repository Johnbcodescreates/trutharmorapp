import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/app_config.dart';
import '../app/app_state.dart';
import '../app/navigation.dart';
import '../models/risk.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/truth_armor_logo.dart';
import 'demo_examples_screen.dart';

/// SETTINGS — accessibility, privacy, responsible AI, disclaimer, account.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const responsibleAiPoints = [
    'AI can make mistakes.',
    'Results are based on patterns — not proof.',
    'TruthArmor does not determine legal truth.',
    'TruthArmor does not determine whether a person is a criminal.',
    'TruthArmor does not determine whether a person is a predator.',
    'TruthArmor does not guarantee that a website, job, or message is legitimate.',
    'Always verify important information independently.',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: PageBody(
        children: [
          // ── Accessibility ──
          const SectionTitle('Accessibility', icon: Icons.accessibility_new_rounded),
          SectionCard(
            padding: const EdgeInsets.symmetric(vertical: Gap.xs),
            child: SwitchListTile(
              value: state.simpleMode,
              onChanged: state.setSimpleMode,
              title: Text('Simple Mode', style: t.titleMedium),
              subtitle: Text(
                'Bigger text and buttons, plainer words, less on screen. Great for seniors and anyone who wants it simpler.',
                style: t.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: Gap.lg),

          // ── Privacy ──
          const SectionTitle('Privacy', icon: Icons.lock_outline_rounded),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: state.saveHistory,
                  onChanged: state.setSaveHistory,
                  title: Text('Save scan history', style: t.titleMedium),
                  subtitle: Text('Date, category, and risk level only — on this device.', style: t.bodySmall),
                ),
                const Divider(),
                const BulletList([
                  'Screenshots are read on your phone and are never uploaded or saved.',
                  'Messages and answers are never stored in history.',
                  'Social Security numbers, card numbers, passwords, and codes are hidden before any AI analysis.',
                  'The AI service key is kept on a secure server — never inside the app.',
                ]),
                const SizedBox(height: Gap.sm),
                const SensitiveDataNotice(),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),

          // ── Responsible AI ──
          const SectionTitle('Responsible AI', icon: Icons.balance_rounded),
          const SectionCard(child: BulletList(responsibleAiPoints)),
          const SizedBox(height: Gap.md),
          const DisclaimerBox(),
          const SizedBox(height: Gap.md),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How TruthArmor decides', style: t.titleMedium),
                const SizedBox(height: Gap.xs),
                Text(
                  'Every check combines (1) built-in safety rules, (2) your answers, (3) AI contextual analysis, and '
                  '(4) link reputation checks where available. Rules use fixed, published weights, so a single AI '
                  'opinion can never decide the result on its own. Risk level and analysis confidence are shown '
                  'separately.',
                  style: t.bodyMedium,
                ),
                const SizedBox(height: Gap.sm),
                Text(kConfidenceExplanation, style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),

          // ── Analysis engine ──
          const SectionTitle('Analysis engine', icon: Icons.memory_rounded),
          SectionCard(
            child: Row(
              children: [
                Icon(
                  AppConfig.isDemoMode ? Icons.science_outlined : Icons.cloud_done_outlined,
                  color: AppConfig.isDemoMode ? const Color(0xFF6D28D9) : AppColors.riskLow,
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Text(
                    AppConfig.isDemoMode
                        ? 'DEMO MODE: Built-in safety rules are fully active. The AI step uses an offline demo '
                            'service (not live AI) because no secure backend is configured.'
                        : 'Connected to the TruthArmor secure analysis server.',
                    style: t.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.sm),
          SectionCard(
            onTap: () => Nav.push(context, const DemoExamplesScreen()),
            child: Row(
              children: [
                const Icon(Icons.play_circle_outline_rounded, color: AppColors.blue),
                const SizedBox(width: Gap.md),
                Expanded(child: Text('Demo examples', style: t.titleMedium)),
                const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),

          // ── Family & account ──
          const SectionTitle('Family & account', icon: Icons.family_restroom_rounded),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Family Safety', style: t.titleMedium)),
                    const Pill('COMING SOON'),
                  ],
                ),
                const SizedBox(height: Gap.xs),
                Text(
                  'Planned: optional parent/guardian accounts, shared education, and check history you choose to share. '
                  'TruthArmor will never secretly monitor anyone. Family features will be built on education, '
                  'consent, trusted-adult involvement, and privacy.',
                  style: t.bodyMedium,
                ),
                const SizedBox(height: Gap.sm),
                Text('No account is needed to use TruthArmor today.', style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: Gap.xl),

          // ── About ──
          const Center(child: TruthArmorLogo(markSize: 34, showTagline: true)),
          const SizedBox(height: Gap.sm),
          Center(
            child: Text(
              'AI-powered protection for the moments when something just doesn\'t feel right.',
              textAlign: TextAlign.center,
              style: t.bodySmall,
            ),
          ),
          const SizedBox(height: Gap.xs),
          Center(child: Text('Version 0.1.0 (MVP)', style: t.bodySmall)),
        ],
      ),
    );
  }
}
