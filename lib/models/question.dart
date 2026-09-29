/// A single question in a category's guided questionnaire.
///
/// Questions are pure configuration — the rule engine reads [signalIfYes],
/// [signalIfNo], [optionSignals] and [role] to turn answers into risk
/// signals, so new questions can be added without writing new logic.
enum QuestionType { text, longText, email, phone, url, yesNo, singleChoice, multiChoice }

/// Tells the rule engine what a field *means*, so generic checks
/// (free email domain, domain mismatch, link analysis) work in every category.
enum FieldRole {
  none,
  claimedOrganization,
  senderEmail,
  senderPhone,
  officialWebsite,
  suspiciousUrl,
  messageText,
}

/// Standard values stored for yes/no questions.
class YesNo {
  YesNo._();
  static const String yes = 'yes';
  static const String no = 'no';
  static const String unsure = 'unsure';
}

class Question {
  const Question({
    required this.id,
    required this.label,
    this.simpleLabel,
    this.hint,
    this.type = QuestionType.yesNo,
    this.options = const [],
    this.signalIfYes,
    this.signalIfNo,
    this.optionSignals = const {},
    this.role = FieldRole.none,
    this.section = 'Details',
  });

  final String id;
  final String label;

  /// Plainer wording shown in Simple Mode.
  final String? simpleLabel;
  final String? hint;
  final QuestionType type;
  final List<String> options;

  /// Signal id raised when a yes/no question is answered "yes".
  final String? signalIfYes;

  /// Signal id raised when a yes/no question is answered "no".
  final String? signalIfNo;

  /// Signal id raised when a specific choice option is selected.
  final Map<String, String> optionSignals;

  final FieldRole role;

  /// Questions are grouped under section headings on the form.
  final String section;

  bool get isFreeText =>
      type == QuestionType.text ||
      type == QuestionType.longText ||
      type == QuestionType.email ||
      type == QuestionType.phone ||
      type == QuestionType.url;
}
