import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/navigation.dart';
import '../data/categories.dart';
import '../models/assessment_draft.dart';
import '../services/ocr/ocr_service.dart';
import '../services/privacy/redactor.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'input/category_confirm_sheet.dart';
import 'input/screenshot_flow.dart';

/// QUICK SCAN — screenshot, photo, pasted text, URL, or message.
/// TruthArmor suggests a category, and the user confirms it.
class QuickScanScreen extends StatefulWidget {
  const QuickScanScreen({super.key});

  @override
  State<QuickScanScreen> createState() => _QuickScanScreenState();
}

class _QuickScanScreenState extends State<QuickScanScreen> {
  final _controller = TextEditingController();
  bool _sensitive = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _sensitive = const Redactor().containsSensitiveData(_controller.text));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    final category = await confirmCategory(context, text);
    if (category == null || !mounted) return;
    Nav.analyze(
      context,
      AssessmentDraft(categoryId: category.id, text: text, source: InputSource.quickScan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ocr = const OcrService().isSupported;
    final hasText = _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Quick Scan')),
      body: PageBody(
        children: [
          Text('Add what you received', style: t.headlineSmall),
          const SizedBox(height: Gap.xs),
          Text("We'll suggest the right kind of check, and you confirm it.", style: t.bodyLarge),
          const SizedBox(height: Gap.lg),
          Row(
            children: [
              Expanded(
                child: _BigOption(
                  icon: Icons.image_outlined,
                  label: 'Screenshot',
                  enabled: ocr,
                  onTap: () => ScreenshotFlow.start(context, categoryId: Categories.aiMessage.id, quickScan: true),
                ),
              ),
              const SizedBox(width: Gap.sm + 4),
              Expanded(
                child: _BigOption(
                  icon: Icons.photo_camera_outlined,
                  label: 'Take photo',
                  enabled: ocr,
                  onTap: () => ScreenshotFlow.start(
                    context,
                    categoryId: Categories.aiMessage.id,
                    source: ImageSource.camera,
                    quickScan: true,
                  ),
                ),
              ),
            ],
          ),
          if (!ocr)
            Padding(
              padding: const EdgeInsets.only(top: Gap.sm),
              child: Text('Screenshot reading is available on Android and iPhone.', style: t.bodySmall),
            ),
          const SizedBox(height: Gap.lg),
          Text('Or paste a message, email, or link', style: t.titleMedium),
          const SizedBox(height: Gap.sm),
          TextField(
            controller: _controller,
            minLines: 5,
            maxLines: 14,
            maxLength: 8000,
            style: t.bodyLarge,
            decoration: const InputDecoration(hintText: 'Paste text or a link here…'),
          ),
          const SizedBox(height: Gap.sm),
          SensitiveDataNotice(detected: _sensitive),
          const SizedBox(height: Gap.lg),
          WideButton(label: 'Continue', icon: Icons.arrow_forward_rounded, onPressed: hasText ? _continue : null),
        ],
      ),
    );
  }
}

class _BigOption extends StatelessWidget {
  const _BigOption({required this.icon, required this.label, required this.onTap, this.enabled = true});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SectionCard(
        onTap: enabled ? onTap : null,
        padding: const EdgeInsets.symmetric(vertical: Gap.lg, horizontal: Gap.sm),
        child: Column(
          children: [
            Icon(icon, size: 34, color: AppColors.blue),
            const SizedBox(height: Gap.sm),
            Text(label, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
