import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../models/assessment_draft.dart';
import '../../models/scan_category.dart';
import '../../services/privacy/redactor.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'questions_screen.dart';

/// Paste a message, job description, email, conversation, or link.
class PasteTextScreen extends StatefulWidget {
  const PasteTextScreen({super.key, required this.category});
  final ScanCategory category;

  @override
  State<PasteTextScreen> createState() => _PasteTextScreenState();
}

class _PasteTextScreenState extends State<PasteTextScreen> {
  final _controller = TextEditingController();
  bool _sensitive = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final s = const Redactor().containsSensitiveData(_controller.text);
      setState(() => _sensitive = s);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AssessmentDraft get _draft => AssessmentDraft(
        categoryId: widget.category.id,
        text: _controller.text.trim(),
        source: widget.category.id == 'website' ? InputSource.url : InputSource.pastedText,
      );

  String get _hint => switch (widget.category.id) {
        'job' => 'Paste the job description or recruiter message…',
        'website' => 'Paste the link, e.g. https://example.com/login',
        'youth' => 'Paste the conversation…',
        'romance' => 'Paste some of the messages…',
        _ => 'Paste the message, email, or text…',
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final hasText = _controller.text.trim().isNotEmpty;
    final isLink = widget.category.id == 'website';

    return Scaffold(
      appBar: AppBar(title: Text(isLink ? 'Paste a link' : 'Paste information')),
      body: PageBody(
        children: [
          Text(widget.category.title, style: t.headlineSmall),
          const SizedBox(height: Gap.md),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: isLink ? 1 : 8,
            maxLines: isLink ? 3 : 18,
            maxLength: 8000,
            keyboardType: isLink ? TextInputType.url : TextInputType.multiline,
            style: t.bodyLarge,
            decoration: InputDecoration(hintText: _hint),
          ),
          const SizedBox(height: Gap.sm),
          SensitiveDataNotice(detected: _sensitive),
          if (isLink) ...[
            const SizedBox(height: Gap.sm),
            Text(
              'TruthArmor checks the link\'s address — it does not open the website on your phone.',
              style: t.bodySmall,
            ),
          ],
          const SizedBox(height: Gap.lg),
          WideButton(
            label: 'Analyze now',
            icon: Icons.shield_outlined,
            onPressed: hasText ? () => Nav.analyze(context, _draft) : null,
          ),
          const SizedBox(height: Gap.sm + 4),
          WideButton(
            label: 'Answer a few questions too (more accurate)',
            outlined: true,
            onPressed: hasText ? () => Nav.push(context, QuestionsScreen(draft: _draft)) : null,
          ),
        ],
      ),
    );
  }
}
