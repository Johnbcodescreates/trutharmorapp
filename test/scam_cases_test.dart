import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truth_armor/data/categories.dart';
import 'package:truth_armor/models/risk.dart';
import 'package:truth_armor/services/risk/risk_scorer.dart';
import 'package:truth_armor/services/rules/rule_engine.dart';

/// Runs every message in test/fixtures/scam_cases.json through the rules.
/// Scams must reach at least their "min" level; normal messages must stay at
/// or below their "max" level. Add new real-world examples to the JSON file.
void main() {
  final data = jsonDecode(File('test/fixtures/scam_cases.json').readAsStringSync()) as Map<String, dynamic>;
  const engine = RuleEngine();
  const scorer = RiskScorer();

  Assessment assess(String categoryId, String text) {
    final category = Categories.byId(categoryId);
    return scorer.score(
      id: 't',
      category: category,
      rules: engine.evaluate(category: category, text: text, answers: const {}),
      ai: null,
      answeredCount: 0,
      textLength: text.length,
    );
  }

  group('Scam messages reach their minimum level', () {
    for (final c in (data['scams'] as List).cast<Map<String, dynamic>>()) {
      test(c['id'] as String, () {
        final a = assess(c['category'] as String, c['text'] as String);
        final min = RiskLevel.values.byName(c['min'] as String);
        expect(a.level.index, greaterThanOrEqualTo(min.index),
            reason: 'Got ${a.level.label} (${a.score}) with ${a.signals.map((s) => s.id).join(', ')}');
      });
    }
  });

  group('Normal messages stay at or below their maximum level', () {
    for (final c in (data['normal'] as List).cast<Map<String, dynamic>>()) {
      test(c['id'] as String, () {
        final a = assess(c['category'] as String, c['text'] as String);
        final max = RiskLevel.values.byName(c['max'] as String);
        expect(a.level.index, lessThanOrEqualTo(max.index),
            reason: 'Got ${a.level.label} (${a.score}) with ${a.signals.map((s) => s.id).join(', ')}');
      });
    }
  });
}
