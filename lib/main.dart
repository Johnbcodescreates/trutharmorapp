import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'app/app_state.dart';
import 'services/assessment_pipeline.dart';

/// TruthArmor — Pause. Verify. Protect.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = AppState();
  await state.load();

  // DEMO MODE if no backend URL was provided at build time (see AppConfig).
  final pipeline = AssessmentPipeline(ai: AppConfig.createAnalysisService());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        Provider<AssessmentPipeline>.value(value: pipeline),
      ],
      child: const TruthArmorApp(),
    ),
  );
}
