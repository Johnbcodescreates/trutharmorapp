import 'package:flutter/material.dart';

import '../data/recovery_steps.dart';
import '../models/scan_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'resource_card.dart';

/// PROTECT ME NOW — the next steps as a tappable checklist.
class ProtectChecklist extends StatefulWidget {
  const ProtectChecklist({super.key, required this.actions});
  final List<String> actions;

  @override
  State<ProtectChecklist> createState() => _ProtectChecklistState();
}

class _ProtectChecklistState extends State<ProtectChecklist> {
  final _done = <int>{};

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final allDone = widget.actions.isNotEmpty && _done.length == widget.actions.length;
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: Gap.sm, horizontal: Gap.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widget.actions.length; i++)
            CheckboxListTile(
              value: _done.contains(i),
              onChanged: (v) => setState(() {
                if (v == true) {
                  _done.add(i);
                } else {
                  _done.remove(i);
                }
              }),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: Gap.sm),
              title: Text(
                widget.actions[i],
                style: t.bodyLarge?.copyWith(
                  decoration: _done.contains(i) ? TextDecoration.lineThrough : null,
                  color: _done.contains(i) ? AppColors.mutedText : AppColors.text,
                ),
              ),
            ),
          if (allDone)
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.md, Gap.sm),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: AppColors.blue),
                  const SizedBox(width: Gap.sm),
                  Expanded(child: Text('Nice work — you\'ve taken the key steps to protect yourself.', style: t.titleSmall)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// ALREADY RESPONDED? — what to do if you already clicked, paid, or shared.
class AlreadyRespondedCard extends StatelessWidget {
  const AlreadyRespondedCard({super.key, required this.category, required this.signalIds});
  final ScanCategory category;
  final Set<String> signalIds;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scenarios = recoveryScenariosFor(category, signalIds);
    final youth = category.id == 'youth';

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            youth
                ? 'If something was already shared, it is not your fault — and help is available.'
                : 'Already clicked, paid, or shared something? It happens to careful people too. Acting quickly can limit the damage.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: Gap.xs),
          for (final (scenario, relevant) in scenarios)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: Gap.md),
                title: Text(scenario.title, style: t.titleSmall),
                subtitle: relevant
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: const Align(alignment: Alignment.centerLeft, child: Pill('LIKELY RELEVANT')),
                      )
                    : null,
                children: [
                  for (var i = 0; i < scenario.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 26,
                            child: Text('${i + 1}.', style: t.titleSmall?.copyWith(color: AppColors.blue)),
                          ),
                          Expanded(child: Text(scenario.steps[i], style: t.bodyMedium)),
                        ],
                      ),
                    ),
                  if (scenario.resources.isNotEmpty) ...[
                    const SizedBox(height: Gap.sm),
                    for (final r in scenario.resources) ResourceCard(resource: r),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
