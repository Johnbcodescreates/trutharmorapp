import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/navigation.dart';
import '../../models/assessment_draft.dart';
import '../../services/ocr/ocr_service.dart';
import '../../theme/app_theme.dart';
import 'ocr_review_screen.dart';

/// Screenshot → OCR → user review. Shared by category checks and Quick Scan.
///
/// The image is read on-device and then discarded; it is never uploaded or
/// stored. Only the text the user approves moves forward.
class ScreenshotFlow {
  ScreenshotFlow._();

  static const _ocr = OcrService();

  /// Returns the recognized text, or null if the user cancelled or OCR failed
  /// (a friendly message is shown in that case).
  static Future<String?> pickAndRead(BuildContext context, {ImageSource source = ImageSource.gallery}) async {
    if (!_ocr.isSupported) {
      _showMessage(context, 'Screenshot reading is not available on this device. Please paste the text instead.');
      return null;
    }

    XFile? file;
    try {
      file = await ImagePicker().pickImage(source: source, imageQuality: 95);
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          source == ImageSource.camera
              ? "We couldn't open the camera. Please check TruthArmor's camera permission in Settings."
              : "We couldn't open your photos. Please check TruthArmor's photo permission in Settings.",
        );
      }
      return null;
    }
    if (file == null || !context.mounted) return null; // User cancelled.

    _showProgress(context);
    try {
      final text = await _ocr.extractText(file.path);
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      return text;
    } on OcrException catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showMessage(context, e.userMessage);
      }
      return null;
    }
  }

  /// Full flow: pick, read, then open the review screen.
  static Future<void> start(
    BuildContext context, {
    required String categoryId,
    ImageSource source = ImageSource.gallery,
    bool quickScan = false,
  }) async {
    final text = await pickAndRead(context, source: source);
    if (text == null || !context.mounted) return;
    Nav.push(
      context,
      OcrReviewScreen(
        draft: AssessmentDraft(
          categoryId: categoryId,
          text: text,
          source: source == ImageSource.camera ? InputSource.photo : InputSource.screenshot,
        ),
        quickScan: quickScan,
      ),
    );
  }

  static void _showProgress(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Dialog(
          child: Padding(
            padding: EdgeInsets.all(Gap.lg),
            child: Row(
              children: [
                SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
                SizedBox(width: Gap.md + 4),
                Expanded(
                  child: Text(
                    'Reading the text in your screenshot…\nThe first time can take up to a minute.',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showMessage(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Heads up'),
        content: Text(message, style: const TextStyle(fontSize: 17)),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
      ),
    );
  }
}
