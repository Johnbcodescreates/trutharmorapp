import 'risk.dart';

/// Privacy-first scan history: stores ONLY metadata.
/// No message text, screenshots, answers, links, names, or numbers.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.date,
    required this.categoryId,
    required this.level,
    required this.title,
    this.isDemo = false,
  });

  final String id;
  final DateTime date;
  final String categoryId;
  final RiskLevel level;
  final String title;
  final bool isDemo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'categoryId': categoryId,
        'level': level.name,
        'title': title,
        'isDemo': isDemo,
      };

  static HistoryEntry? fromJson(Map<String, dynamic> json) {
    try {
      return HistoryEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        categoryId: json['categoryId'] as String,
        level: RiskLevel.values.byName(json['level'] as String),
        title: json['title'] as String,
        isDemo: (json['isDemo'] as bool?) ?? false,
      );
    } catch (_) {
      return null; // Skip corrupted entries rather than crashing.
    }
  }
}
