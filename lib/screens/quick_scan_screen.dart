import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/navigation.dart';
import '../data/categories.dart';
import '../models/assessment_draft.dart';
import '../services/ocr/ocr_service.dart';
import '../services/privacy/redactor.dart';
import '../services/share/share_receiver.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'input/category_confirm_sheet.dart';
import 'input/screenshot_flow.dart';
import 'input/voice_message_screen.dart';

/// QUICK SCAN — screenshot, photo, pasted text, URL, or message.
/// TruthArmor suggests a category, and the user confirms it.
class QuickScanScreen extends StatefulWidget {
  const QuickScanScreen({super.key, this.initialText, this.shared = false});

  /// Text to start with (for example, shared from another app).
  final String? initialText;

  /// True when the text came from "Share → TruthArmor".
  final bool shared;

  @override
  State<QuickScanScreen> createState() => _QuickScanScreenState();
}

class _QuickScanScreenState extends State<QuickScanScreen> {
  late final _controller = TextEditingController(text: widget.initialText ?? '');
  bool _sensitive = false;

  @override
  void initState() {
    super.initState();
    _sensitive = const Redactor().containsSensitiveData(_controller.text);
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
          if (widget.shared) ...[
            SectionCard(
              color: const Color(0xFFEAF2FF),
              child: Row(
                children: [
                  const Icon(Icons.ios_share_rounded, color: AppColors.blue),
                  const SizedBox(width: Gap.sm + 4),
                  Expanded(
                    child: Text(
                      'Shared to TruthArmor. Review the text below, then tap Continue.',
                      style: t.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.lg),
          ],
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
          const SizedBox(height: Gap.sm + 4),
          SectionCard(
            onTap: () => Nav.push(context, const VoiceMessageScreen(category: Categories.aiMessage, quickScan: true)),
            child: Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, size: 30, color: AppColors.blue),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voice message', style: t.titleSmall),
                      Text('Check a voicemail or voice note', style: t.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
              ],
            ),
          ),
          if (!ocr)
            Padding(
              padding: const EdgeInsets.only(top: Gap.sm),
              child: Text('Screenshot reading is not available on this device.', style: t.bodySmall),
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
          if (ShareReceiver.instance.isAvailable && !widget.shared) ...[
            const SizedBox(height: Gap.md),
            Text(
              'Tip: in Messages, Gmail, or Chrome, tap Share → TruthArmor to check something without copying it.',
              style: t.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
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
