import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../data/categories.dart';
import '../models/history_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/risk_widgets.dart';

/// HISTORY — privacy-first: date, category, risk level, short title only.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September',
    'October', 'November', 'December'];

  static String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context).textTheme;
    final items = state.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (items.isNotEmpty)
            TextButton(onPressed: () => _confirmClear(context), child: const Text('Clear all')),
        ],
      ),
      body: PageBody(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.mutedText),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(
                  'Only the date, category, and risk level are saved — on this device. '
                  'Messages, screenshots, and answers are never stored.',
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          if (!state.saveHistory)
            const Padding(
              padding: EdgeInsets.only(bottom: Gap.md),
              child: FriendlyError('Saving history is turned off in Settings.'),
            ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xl),
              child: Column(
                children: [
                  const Icon(Icons.history_rounded, size: 56, color: AppColors.border),
                  const SizedBox(height: Gap.md),
                  Text('No checks yet', style: t.titleLarge),
                  const SizedBox(height: Gap.xs),
                  Text('Your past assessments will appear here.', style: t.bodyMedium),
                ],
              ),
            )
          else
            for (final e in items) _HistoryRow(entry: e),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This permanently removes every saved assessment from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true && context.mounted) await context.read<AppState>().clearHistory();
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final category = Categories.byId(entry.categoryId);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm + 2),
      child: Dismissible(
        key: ValueKey(entry.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: Gap.lg),
          decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(Gap.radius)),
          child: const Icon(Icons.delete_outline_rounded, color: AppColors.white),
        ),
        onDismissed: (_) => context.read<AppState>().deleteScan(entry.id),
        child: SectionCard(
          child: Row(
            children: [
              Icon(category.icon, color: AppColors.blue, size: 28),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(HistoryScreen.formatDate(entry.date), style: t.bodySmall),
                    Text(category.title, style: t.titleMedium),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: Gap.sm,
                      runSpacing: Gap.xs,
                      children: [
                        RiskChip(level: entry.level),
                        if (entry.isDemo) const Pill.demo('DEMO'),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete this scan',
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.mutedText),
                onPressed: () => context.read<AppState>().deleteScan(entry.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
