import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truth_armor/app/app_shell.dart';
import 'package:truth_armor/app/app_state.dart';
import 'package:truth_armor/data/demo_examples.dart';
import 'package:truth_armor/services/ai/demo_analysis_service.dart';
import 'package:truth_armor/services/assessment_pipeline.dart';
import 'package:truth_armor/screens/results_screen.dart';
import 'package:truth_armor/theme/app_theme.dart';

Widget _wrap(Widget child, AppState state) => MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        Provider<AssessmentPipeline>.value(
          value: const AssessmentPipeline(ai: DemoAnalysisService(delay: Duration.zero)),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: child),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Home screen shows the main question and Quick Scan', timeout: const Timeout(Duration(minutes: 1)),
      (tester) async {
    final state = AppState();
    await state.load();
    await tester.pumpWidget(_wrap(const AppShell(), state));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('What would you like to check?'), findsOneWidget);
    expect(find.text('QUICK SCAN'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Results screen shows risk, reasons, actions and disclaimer', timeout: const Timeout(Duration(minutes: 1)),
      (tester) async {
    final state = AppState();
    await state.load();
    const pipeline = AssessmentPipeline(ai: DemoAnalysisService(delay: Duration.zero));
    // Screen tests freeze time, so run the (timer-based) demo analysis with real time.
    final assessment = (await tester.runAsync(
      () => pipeline.run(kDemoExamples.firstWhere((e) => e.id == 'demo_irs').toDraft()),
    ))!;

    await tester.pumpWidget(_wrap(ResultsScreen(assessment: assessment), state));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('HIGH RISK'), findsOneWidget);
    expect(assessment.checkedText, isNotEmpty);
    expect(assessment.knownFacts, isNotEmpty);
    expect(assessment.unknowns, isNotEmpty);

    // The results page is long; scroll to each section in order.
    for (final section in [
      'WHY THIS WAS FLAGGED',
      'DECEPTION BREAKDOWN',
      'WHAT WE KNOW — AND WHAT WE DON\'T',
      'PROTECT ME NOW: WHAT TO DO NEXT',
      'ALREADY RESPONDED?',
    ]) {
      await tester.scrollUntilVisible(find.text(section), 300, scrollable: find.byType(Scrollable).first);
      expect(find.text(section), findsOneWidget, reason: section);
    }
    await tester.scrollUntilVisible(find.textContaining('It is not a guarantee'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('It is not a guarantee'), findsOneWidget);
  });
}
