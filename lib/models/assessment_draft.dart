/// How the user provided the information.
enum InputSource { screenshot, photo, pastedText, url, questions, quickScan, demo }

/// Everything the user has provided so far, before analysis.
///
/// Drafts live in memory only. They are never written to disk.
class AssessmentDraft {
  AssessmentDraft({
    required this.categoryId,
    this.text = '',
    Map<String, dynamic>? answers,
    this.source = InputSource.pastedText,
    this.demoTitle,
  }) : answers = answers ?? <String, dynamic>{};

  String categoryId;

  /// Pasted text, OCR text (after the user reviewed it), or a URL.
  String text;

  /// Question id -> answer. Strings for text/yes-no/single choice,
  /// List<String> for multi choice.
  final Map<String, dynamic> answers;

  InputSource source;

  /// Set when this draft was loaded from a DEMO EXAMPLE.
  final String? demoTitle;

  bool get isDemoExample => demoTitle != null;

  int get answeredCount => answers.values.where((v) {
        if (v == null) return false;
        if (v is String) return v.trim().isNotEmpty;
        if (v is List) return v.isNotEmpty;
        return true;
      }).length;

  bool get hasContent => text.trim().isNotEmpty || answeredCount > 0;

  AssessmentDraft copyWith({String? categoryId, String? text}) => AssessmentDraft(
        categoryId: categoryId ?? this.categoryId,
        text: text ?? this.text,
        answers: Map<String, dynamic>.from(answers),
        source: source,
        demoTitle: demoTitle,
      );
}
