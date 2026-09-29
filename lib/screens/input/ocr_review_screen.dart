import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../models/assessment_draft.dart';
import '../../services/privacy/redactor.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'category_confirm_sheet.dart';
import 'questions_screen.dart';

/// "We found the following text. Please review it before analysis."
/// OCR is never trusted blindly — the user can edit, delete, or add text.
class OcrReviewScreen extends StatefulWidget {
  const OcrReviewScreen({super.key, required this.draft, this.quickScan = false});
  final AssessmentDraft draft;
  final bool quickScan;

  @override
  State<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends State<OcrReviewScreen> {
  late final TextEditingController _controller = TextEditingController(text: widget.draft.text);
  bool _sensitive = false;

  @override
  void initState() {
    super.initState();
    _sensitive = const Redactor().containsSensitiveData(_controller.text);
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    // Also refreshes the enabled state of the buttons.
    setState(() => _sensitive = const Redactor().containsSensitiveData(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AssessmentDraft _draft([String? categoryId]) =>
      widget.draft.copyWith(text: _controller.text.trim(), categoryId: categoryId);

  Future<void> _analyze() async {
    if (widget.quickScan) {
      final cat = await confirmCategory(context, _controller.text);
      if (cat == null || !mounted) return;
      Nav.analyze(context, _draft(cat.id));
    } else {
      Nav.analyze(context, _draft());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final hasText = _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Review the text')),
      body: PageBody(
        children: [
          Text('We found the following text.', style: t.headlineSmall),
          const SizedBox(height: Gap.xs),
          Text(
            'Please review it before analysis. Screenshot reading can make mistakes — fix anything that looks wrong, '
            'delete anything private, or add missing text.',
            style: t.bodyLarge,
          ),
          const SizedBox(height: Gap.md),
          TextField(
            controller: _controller,
            minLines: 8,
            maxLines: 18,
            maxLength: 8000,
            keyboardType: TextInputType.multiline,
            style: t.bodyLarge,
            decoration: InputDecoration(
              hintText: 'The text from your screenshot will appear here.',
              suffixIcon: hasText
                  ? IconButton(
                      tooltip: 'Delete all text',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _controller.clear(),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: Gap.sm),
          SensitiveDataNotice(detected: _sensitive),
          const SizedBox(height: Gap.lg),
          WideButton(
            label: widget.quickScan ? 'Continue' : 'Analyze now',
            icon: Icons.shield_outlined,
            onPressed: hasText ? _analyze : null,
          ),
          if (!widget.quickScan) ...[
            const SizedBox(height: Gap.sm + 4),
            WideButton(
              label: 'Answer a few questions too (more accurate)',
              outlined: true,
              onPressed: hasText ? () => Nav.push(context, QuestionsScreen(draft: _draft())) : null,
            ),
          ],
        ],
      ),
    );
  }
}
