import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../models/assessment_draft.dart';
import '../services/assessment_pipeline.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/truth_armor_logo.dart';
import 'results_screen.dart';

/// Runs the hybrid analysis and shows calm, honest progress.
class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key, required this.draft});
  final AssessmentDraft draft;

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  int _step = 0;
  String? _error;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (mounted && _step < 3) setState(() => _step++);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    setState(() => _error = null);
    final pipeline = context.read<AssessmentPipeline>();
    final state = context.read<AppState>();
    try {
      final assessment = await pipeline.run(widget.draft, simpleMode: state.simpleMode);
      await state.record(assessment);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultsScreen(assessment: assessment)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = "We couldn't analyze this right now. Please check your connection and try again.");
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isDemo = context.watch<AssessmentPipeline>().isDemo;
    final steps = [
      'Checking built-in safety rules',
      'Hiding private details',
      isDemo ? 'Preparing summary (demo AI)' : 'Running AI contextual analysis',
      'Calculating the risk assessment',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('TruthArmor assessment')),
      body: PageBody(
        children: [
          const SizedBox(height: Gap.xl),
          Center(
            child: ScaleTransition(
              scale: Tween(begin: 0.92, end: 1.04).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
              child: const TruthArmorMark(size: 96),
            ),
          ),
          const SizedBox(height: Gap.lg),
          Center(child: Text('Pause. Verify. Protect.', style: t.titleMedium?.copyWith(color: AppColors.mutedText))),
          const SizedBox(height: Gap.xl),
          if (_error != null) ...[
            FriendlyError(_error!),
            const SizedBox(height: Gap.md),
            WideButton(label: 'Try again', icon: Icons.refresh_rounded, onPressed: _run),
            const SizedBox(height: Gap.sm + 4),
            WideButton(label: 'Go back', outlined: true, onPressed: () => Navigator.of(context).pop()),
          ] else
            SectionCard(
              child: Column(
                children: [
                  for (var i = 0; i < steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 26,
                            height: 26,
                            child: i < _step
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.blue, size: 26)
                                : i == _step
                                    ? const Padding(
                                        padding: EdgeInsets.all(3),
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      )
                                    : const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.border, size: 26),
                          ),
                          const SizedBox(width: Gap.md),
                          Expanded(
                            child: Text(
                              steps[i],
                              style: t.bodyLarge?.copyWith(color: i <= _step ? AppColors.text : AppColors.mutedText),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
