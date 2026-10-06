import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../app/navigation.dart';
import '../data/categories.dart';
import '../models/assessment_draft.dart';
import '../models/risk.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/example_content_card.dart';
import '../widgets/resource_card.dart';
import '../widgets/risk_widgets.dart';
import 'verify_safely_screen.dart';

/// TRUTHARMOR ASSESSMENT — the explainable result.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.assessment, this.demoDraft});
  final Assessment assessment;

  /// Set only for DEMO EXAMPLES, so viewers can see what was checked.
  final AssessmentDraft? demoDraft;

  @override
  Widget build(BuildContext context) {
    final a = assessment;
    final t = Theme.of(context).textTheme;
    final simple = context.simple;
    final category = Categories.byId(a.categoryId);
    final reasons = simple ? a.simpleReasons : a.reasons;
    final actions = simple ? a.simpleActions : a.actions;
    final found = a.breakdown.where((b) => b.level != GroupLevel.none).toList();
    final showHelp = a.level == RiskLevel.high ||
        a.level == RiskLevel.elevated ||
        (category.id == 'youth' && a.level != RiskLevel.low);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment'),
        leading: IconButton(
          tooltip: 'Done',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
      body: PageBody(
        children: [
          // ── Labels ──
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              Pill(category.shortTitle.toUpperCase(), icon: category.icon),
              if (a.isDemoExample) const Pill.demo('DEMO EXAMPLE'),
              if (a.isDemoAi) const Pill.demo('DEMO AI — NOT LIVE AI'),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text('TRUTHARMOR ASSESSMENT',
              style: t.labelSmall?.copyWith(color: AppColors.mutedText, fontSize: 13, letterSpacing: 1.4)),
          const SizedBox(height: Gap.sm),
          RiskHero(level: a.level, headline: a.headline, score: a.score),
          const SizedBox(height: Gap.md),

          if (a.summary.isNotEmpty) ...[
            Text(a.summary, style: t.bodyLarge),
            const SizedBox(height: Gap.md),
          ],
          if (demoDraft != null) ...[
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: Gap.md + 2, vertical: Gap.xs),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: Gap.md),
                  leading: const Icon(Icons.science_outlined, color: Color(0xFF6D28D9)),
                  title: Text('The example that was checked', style: t.titleMedium),
                  subtitle: Text(demoDraft!.demoTitle ?? '', style: t.bodySmall),
                  children: [
                    ExampleContentCard(
                      categoryId: demoDraft!.categoryId,
                      text: demoDraft!.text,
                      answers: demoDraft!.answers,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Gap.md),
          ],
          if (a.aiUnavailableReason != null) ...[
            FriendlyError(a.aiUnavailableReason!),
            const SizedBox(height: Gap.md),
          ],
          if (category.specialNotice != null) ...[
            SectionCard(
              color: AppColors.lightBlue,
              borderColor: AppColors.lightBlue,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.navy),
                  const SizedBox(width: Gap.sm + 4),
                  Expanded(child: Text(category.specialNotice!, style: t.bodyMedium)),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
          ],
          const SizedBox(height: Gap.sm),

          // ── Why this was flagged ──
          SectionTitle(
            a.level == RiskLevel.low && reasons.isEmpty ? 'What we checked' : 'Why this was flagged',
            icon: Icons.flag_outlined,
          ),
          SectionCard(
            child: reasons.isEmpty
                ? Text(
                    'No specific warning signs were found in what you shared. This does not guarantee it is '
                    'legitimate — verify anything important through an official source.',
                    style: t.bodyLarge,
                  )
                : BulletList(reasons, icon: Icons.warning_amber_rounded, iconColor: AppColors.navy, iconSize: 20),
          ),
          if (a.additionalConcerns.isNotEmpty) ...[
            const SizedBox(height: Gap.sm + 4),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Other things worth considering', style: t.titleSmall),
                  const SizedBox(height: Gap.xs),
                  BulletList(a.additionalConcerns),
                ],
              ),
            ),
          ],
          const SizedBox(height: Gap.lg),

          // ── What to do next ──
          const SectionTitle('What to do next', icon: Icons.task_alt_rounded),
          SectionCard(
            child: BulletList(actions, icon: Icons.check_circle_outline_rounded, iconColor: AppColors.blue, iconSize: 20),
          ),
          const SizedBox(height: Gap.md),
          WideButton(
            label: 'HOW TO VERIFY SAFELY',
            icon: Icons.verified_user_outlined,
            onPressed: () => Nav.push(context, VerifySafelyScreen(category: category)),
          ),
          const SizedBox(height: Gap.lg),

          if (showHelp) ...[
            SectionTitle(category.id == 'youth' ? 'Get help from trusted adults' : 'Where to get help',
                icon: Icons.support_agent_rounded),
            for (final r in category.resources) ResourceCard(resource: r),
            const SizedBox(height: Gap.lg - 8),
          ],

          // ── What we found ──
          const SectionTitle('What we found', icon: Icons.insights_rounded),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (found.isEmpty)
                  Text('No risk signals found in any area.', style: t.bodyLarge)
                else
                  for (final b in found) GroupRow(breakdown: b, simple: simple),
                if (a.signals.isNotEmpty && !simple) ...[
                  const Divider(height: Gap.lg),
                  _Expandable(
                    title: 'Details for each signal',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [for (final s in a.signals) _SignalDetail(signal: s)],
                    ),
                  ),
                ],
                const Divider(height: Gap.lg),
                _Expandable(
                  title: 'How was this calculated?',
                  child: Column(
                    children: [
                      for (final step in a.scoreSteps)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(step.label, style: t.bodyMedium)),
                              Text(step.value, style: t.titleSmall),
                            ],
                          ),
                        ),
                      const SizedBox(height: Gap.sm),
                      Text(
                        'Signals found by built-in rules count fully. Signals found only by AI count at 70%. '
                        'The AI\'s overall opinion can only nudge the score a little, and known high-risk combinations '
                        'set a minimum score.',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),

          if (a.reassuringFactors.isNotEmpty) ...[
            const SectionTitle('Things that look normal', icon: Icons.thumb_up_alt_outlined),
            SectionCard(child: BulletList(a.reassuringFactors)),
            const SizedBox(height: Gap.lg),
          ],

          // ── Confidence ──
          const SectionTitle('Analysis confidence', icon: Icons.speed_rounded),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.confidence.label.toUpperCase(), style: t.headlineSmall?.copyWith(color: AppColors.navy)),
                const SizedBox(height: Gap.xs),
                Text(kConfidenceExplanation, style: t.bodyMedium),
                if (a.confidence == ConfidenceLevel.low) ...[
                  const SizedBox(height: Gap.sm),
                  Text(
                    'Tip: adding the full message or answering more questions can improve confidence.',
                    style: t.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),

          if (a.redactionCount > 0) ...[
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.mutedText),
                const SizedBox(width: Gap.sm),
                Expanded(
                  child: Text(
                    '${a.redactionCount} private item${a.redactionCount == 1 ? ' was' : 's were'} hidden before analysis.',
                    style: t.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.md),
          ],

          const DisclaimerBox(),
          const SizedBox(height: Gap.md),
          Text(
            'You make the final decision. TruthArmor helps you pause and verify.',
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: AppColors.mutedText, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: Gap.lg),
          WideButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
          const SizedBox(height: Gap.sm),
          TextButton.icon(
            onPressed: () => _deleteScan(context),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete this scan'),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteScan(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this scan?'),
        content: const Text('This removes it from your history on this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<AppState>().deleteScan(assessment.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scan deleted.')));
    Navigator.of(context).popUntil((r) => r.isFirst);
  }
}

class _Expandable extends StatelessWidget {
  const _Expandable({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: Gap.sm),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.blue)),
        children: [child],
      ),
    );
  }
}

class _SignalDetail extends StatelessWidget {
  const _SignalDetail({required this.signal});
  final DetectedSignal signal;

  String get _source => switch (signal.source) {
        SignalSource.answers => 'From your answers',
        SignalSource.text => 'Found in the text',
        SignalSource.link => 'Link check',
        SignalSource.ai => 'AI analysis',
        SignalSource.reputation => 'Security reputation service',
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(signal.definition.reason, style: t.titleSmall),
          Text('$_source · ${signal.definition.group.label} · +${signal.definition.weight}', style: t.bodySmall),
          if (signal.evidence != null && signal.evidence!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('"${signal.evidence}"', style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }
}
