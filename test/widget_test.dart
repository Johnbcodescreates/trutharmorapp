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

  testWidgets('Home screen shows the main question and Quick Scan', (tester) async {
    final state = AppState();
    await state.load();
    await tester.pumpWidget(_wrap(const AppShell(), state));
    await tester.pumpAndSettle();

    expect(find.text('What would you like to check?'), findsOneWidget);
    expect(find.text('QUICK SCAN'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Results screen shows risk, reasons, actions and disclaimer', (tester) async {
    final state = AppState();
    await state.load();
    const pipeline = AssessmentPipeline(ai: DemoAnalysisService(delay: Duration.zero));
    final assessment = await pipeline.run(kDemoExamples.firstWhere((e) => e.id == 'demo_irs').toDraft());

    await tester.pumpWidget(_wrap(ResultsScreen(assessment: assessment), state));
    await tester.pumpAndSettle();

    expect(find.text('HIGH RISK'), findsOneWidget);
    expect(find.text('WHY THIS WAS FLAGGED'), findsOneWidget);
    expect(find.text('WHAT TO DO NEXT'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('It is not a guarantee'), 400);
    expect(find.textContaining('It is not a guarantee'), findsOneWidget);
  });
}
