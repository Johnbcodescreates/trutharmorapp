import 'package:flutter/widgets.dart';

import 'question.dart';

/// A step in "How to verify safely".
class VerifyStep {
  const VerifyStep(this.title, this.detail);
  final String title;
  final String detail;
}

/// An official place to get help or report (all publicly listed resources).
class HelpResource {
  const HelpResource({required this.name, required this.detail, this.url, this.phone});
  final String name;
  final String detail;
  final String? url;
  final String? phone;
}

/// Everything TruthArmor needs to know about one kind of check.
///
/// This is the "category engine": the UI, rule engine, and AI service all
/// read from these configs, so adding a new category = adding one config.
///
/// NOTE: The AI *system instructions* for each category live on the secure
/// backend (functions/src/categoryPrompts.ts) keyed by [id]. They are kept
/// server-side so the app can't be used as an open AI proxy and prompts
/// can be improved without shipping a new app version.
class ScanCategory {
  const ScanCategory({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.simpleDescription,
    required this.icon,
    required this.questions,
    required this.recommendedActions,
    required this.verifySteps,
    required this.detectionKeywords,
    required this.articleId,
    this.resources = const [],
    this.headlines = const {},
    this.specialNotice,
    this.phase = 1,
  });

  final String id;
  final String title;
  final String shortTitle;
  final String description;
  final String simpleDescription;
  final IconData icon;
  final List<Question> questions;

  /// Baseline "What to do next" actions for this category.
  final List<String> recommendedActions;

  /// Category-specific "How to verify safely" steps.
  final List<VerifyStep> verifySteps;

  /// Words that suggest content belongs to this category (Quick Scan).
  final List<String> detectionKeywords;

  /// Safety Center article for this category.
  final String articleId;

  final List<HelpResource> resources;

  /// Optional per-risk-level headline overrides, keyed by RiskLevel.name.
  /// Used for careful wording (e.g. romance, youth safety).
  final Map<String, String> headlines;

  /// Shown on the result screen for this category (e.g. responsible-AI notes).
  final String? specialNotice;

  /// MVP build phase (for the roadmap / judges' demo).
  final int phase;

  List<String> get sections {
    final seen = <String>[];
    for (final q in questions) {
      if (!seen.contains(q.section)) seen.add(q.section);
    }
    return seen;
  }
}
