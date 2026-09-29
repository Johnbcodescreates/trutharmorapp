import 'package:flutter/material.dart';

import '../../data/categories.dart';
import '../../models/scan_category.dart';
import '../../services/category_detector.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Quick Scan confirmation:
///   "This appears to be related to a job opportunity.
///    Would you like to analyze it as a Job/Work Opportunity?"
/// Returns the chosen category, or null if dismissed.
Future<ScanCategory?> confirmCategory(BuildContext context, String text) {
  final guess = const CategoryDetector().detect(text);
  return showModalBottomSheet<ScanCategory>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.background,
    builder: (ctx) => _ConfirmSheet(guess: guess),
  );
}

class _ConfirmSheet extends StatefulWidget {
  const _ConfirmSheet({required this.guess});
  final CategoryGuess guess;

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  bool _choosing = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = widget.guess.category;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xl),
        child: _choosing
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose a category', style: t.headlineSmall),
                  const SizedBox(height: Gap.md),
                  for (final cat in Categories.all)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 12,
                      leading: Icon(cat.icon, color: AppColors.blue, size: 28),
                      title: Text(cat.title, style: t.titleMedium),
                      onTap: () => Navigator.of(context).pop(cat),
                    ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(c.icon, color: AppColors.blue, size: 30),
                      const SizedBox(width: Gap.sm + 4),
                      Expanded(
                        child: Text(
                          widget.guess.confident
                              ? 'This appears to be related to: ${c.shortTitle.toLowerCase()}.'
                              : "We couldn't tell exactly what kind of message this is.",
                          style: t.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.md),
                  Text(
                    widget.guess.confident
                        ? 'Would you like to analyze it as ${c.title}?'
                        : 'We can analyze it as a general suspicious message, or you can choose a category.',
                    style: t.bodyLarge,
                  ),
                  const SizedBox(height: Gap.lg),
                  WideButton(
                    label: 'Yes, analyze as ${c.shortTitle}',
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.of(context).pop(c),
                  ),
                  const SizedBox(height: Gap.sm + 4),
                  WideButton(
                    label: 'Choose a different category',
                    outlined: true,
                    onPressed: () => setState(() => _choosing = true),
                  ),
                ],
              ),
      ),
    );
  }
}
