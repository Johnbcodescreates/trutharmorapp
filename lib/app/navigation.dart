import 'package:flutter/material.dart';

import '../models/assessment_draft.dart';
import '../models/scan_category.dart';
import '../screens/analyzing_screen.dart';
import '../screens/check_method_screen.dart';
import '../screens/quick_scan_screen.dart';

/// Central navigation helpers so screens stay decoupled.
class Nav {
  Nav._();

  static Future<void> push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  static Future<void> openCategory(BuildContext context, ScanCategory category) =>
      push(context, CheckMethodScreen(category: category));

  static Future<void> quickScan(BuildContext context) => push(context, const QuickScanScreen());

  /// Starts analysis. Uses push (not replace) so Back returns to the input.
  static Future<void> analyze(BuildContext context, AssessmentDraft draft) =>
      push(context, AnalyzingScreen(draft: draft));
}
