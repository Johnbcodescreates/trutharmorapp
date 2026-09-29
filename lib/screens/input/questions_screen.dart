import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/categories.dart';
import '../../models/assessment_draft.dart';
import '../../services/privacy/redactor.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/question_field.dart';

/// Guided questions for a category (built entirely from its configuration).
class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key, required this.draft});
  final AssessmentDraft draft;

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late final AssessmentDraft _draft = widget.draft.copyWith();
  late final bool _askForText = widget.draft.text.trim().isEmpty;
  bool _sensitive = false;

  void _setAnswer(String id, dynamic value) {
    setState(() {
      if (value == null || (value is String && value.trim().isEmpty) || (value is List && value.isEmpty)) {
        _draft.answers.remove(id);
      } else {
        _draft.answers[id] = value;
      }
      _sensitive = _checkSensitive();
    });
  }

  bool _checkSensitive() {
    const r = Redactor();
    if (r.containsSensitiveData(_draft.text)) return true;
    return _draft.answers.values.whereType<String>().any(r.containsSensitiveData);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final category = Categories.byId(_draft.categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(category.shortTitle)),
      body: PageBody(
        children: [
          Text('A few questions', style: t.headlineSmall),
          const SizedBox(height: Gap.xs),
          Text(
            context.simple
                ? 'Answer what you can. It is okay to skip questions.'
                : 'Answer what you know — every question is optional. More answers usually means a more confident assessment.',
            style: t.bodyLarge,
          ),
          const SizedBox(height: Gap.md),
          SensitiveDataNotice(detected: _sensitive),
          const SizedBox(height: Gap.md),
          if (_askForText) ...[
            const SectionTitle('The message (optional)', icon: Icons.chat_bubble_outline_rounded),
            SectionCard(
              child: TextFormField(
                minLines: 3,
                maxLines: 10,
                maxLength: 8000,
                style: t.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Paste the message or description here, if you have it',
                  counterText: '',
                ),
                onChanged: (v) => setState(() {
                  _draft.text = v;
                  _sensitive = _checkSensitive();
                }),
              ),
            ),
            const SizedBox(height: Gap.lg),
          ],
          for (final section in category.sections) ...[
            SectionTitle(section),
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: Gap.md + 2, vertical: Gap.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final q in category.questions.where((q) => q.section == section))
                    QuestionField(
                      key: ValueKey(q.id),
                      question: q,
                      value: _draft.answers[q.id],
                      onChanged: (v) => _setAnswer(q.id, v),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Gap.lg),
          ],
          WideButton(
            label: 'Analyze',
            icon: Icons.shield_outlined,
            onPressed: _draft.hasContent ? () => Nav.analyze(context, _draft.copyWith()) : null,
          ),
          if (!_draft.hasContent)
            Padding(
              padding: const EdgeInsets.only(top: Gap.sm),
              child: Text(
                'Answer at least one question or paste the message to continue.',
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(color: AppColors.mutedText),
              ),
            ),
        ],
      ),
    );
  }
}
