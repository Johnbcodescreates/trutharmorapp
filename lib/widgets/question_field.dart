import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Renders one configured question. Large tap targets; every answer optional.
class QuestionField extends StatelessWidget {
  const QuestionField({super.key, required this.question, required this.value, required this.onChanged});

  final Question question;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final label = context.pick(question.label, question.simpleLabel);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.titleSmall?.copyWith(fontSize: 16.5)),
          const SizedBox(height: Gap.sm),
          _input(context),
        ],
      ),
    );
  }

  Widget _input(BuildContext context) {
    switch (question.type) {
      case QuestionType.yesNo:
        return _choices(
          context,
          const [(YesNo.yes, 'Yes'), (YesNo.no, 'No'), (YesNo.unsure, 'Not sure')],
          single: true,
        );
      case QuestionType.singleChoice:
        return _choices(context, [for (final o in question.options) (o, o)], single: true);
      case QuestionType.multiChoice:
        return _choices(context, [for (final o in question.options) (o, o)], single: false);
      case QuestionType.text:
      case QuestionType.longText:
      case QuestionType.email:
      case QuestionType.phone:
      case QuestionType.url:
        return TextFormField(
          initialValue: value is String ? value as String : null,
          onChanged: onChanged,
          minLines: question.type == QuestionType.longText ? 4 : 1,
          maxLines: question.type == QuestionType.longText ? 10 : 1,
          maxLength: question.type == QuestionType.longText ? 4000 : 300,
          keyboardType: switch (question.type) {
            QuestionType.email => TextInputType.emailAddress,
            QuestionType.phone => TextInputType.phone,
            QuestionType.url => TextInputType.url,
            QuestionType.longText => TextInputType.multiline,
            _ => TextInputType.text,
          },
          autocorrect: question.type == QuestionType.text || question.type == QuestionType.longText,
          decoration: InputDecoration(hintText: question.hint ?? 'Optional', counterText: ''),
          style: Theme.of(context).textTheme.bodyLarge,
        );
    }
  }

  Widget _choices(BuildContext context, List<(String, String)> options, {required bool single}) {
    final selected = <String>{
      if (single && value is String) value as String,
      if (!single && value is List) ...(value as List).whereType<String>(),
    };

    return Wrap(
      spacing: Gap.sm,
      runSpacing: Gap.sm,
      children: [
        for (final (val, text) in options)
          single
              ? ChoiceChip(
                  label: Text(text),
                  selected: selected.contains(val),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: selected.contains(val) ? FontWeight.w700 : FontWeight.w500,
                    color: selected.contains(val) ? AppColors.navy : AppColors.text,
                  ),
                  side: BorderSide(
                    color: selected.contains(val) ? AppColors.blue : AppColors.border,
                    width: selected.contains(val) ? 2 : 1,
                  ),
                  // Tapping the selected chip again clears the answer.
                  onSelected: (on) => onChanged(on ? val : null),
                )
              : FilterChip(
                  label: Text(text),
                  selected: selected.contains(val),
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: selected.contains(val) ? FontWeight.w700 : FontWeight.w500,
                    color: selected.contains(val) ? AppColors.navy : AppColors.text,
                  ),
                  side: BorderSide(
                    color: selected.contains(val) ? AppColors.blue : AppColors.border,
                    width: selected.contains(val) ? 2 : 1,
                  ),
                  onSelected: (on) {
                    final next = {...selected};
                    on ? next.add(val) : next.remove(val);
                    onChanged(next.toList());
                  },
                ),
      ],
    );
  }
}
