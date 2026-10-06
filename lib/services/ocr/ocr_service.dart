import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// On the web, screenshots are read with Tesseract.js inside the browser.
// On Android/iOS, Google ML Kit is used. Either way the image never leaves
// the user's device — only the text they review and approve is analyzed.
import 'web_ocr_stub.dart' if (dart.library.js_interop) 'web_ocr_web.dart' as web_ocr;

/// Friendly OCR failure.
class OcrException implements Exception {
  const OcrException(this.userMessage);
  final String userMessage;
}

/// Reads text from a screenshot or photo, on the user's own device.
class OcrService {
  const OcrService();

  bool get isSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<String> extractText(String imagePath) async {
    if (!isSupported) {
      throw const OcrException(
        'Screenshot reading is not available on this device. Please paste the text instead.',
      );
    }

    final String text;
    if (kIsWeb) {
      text = await _extractOnWeb(imagePath);
    } else {
      text = await _extractWithMlKit(imagePath);
    }

    if (text.trim().isEmpty) {
      throw const OcrException(
        "We couldn't find readable text in this image. Try a clearer screenshot, or paste the text instead.",
      );
    }
    return text.trim();
  }

  Future<String> _extractOnWeb(String imagePath) async {
    try {
      return await web_ocr.recognizeText(imagePath);
    } on web_ocr.WebOcrLoadException {
      throw const OcrException(
        "We couldn't load the screenshot reader. Please check your internet connection, or paste the text instead.",
      );
    } catch (_) {
      throw const OcrException(
        "We couldn't read this image. Try a PNG or JPG screenshot, or paste the text instead.",
      );
    }
  }

  Future<String> _extractWithMlKit(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(imagePath));
      return result.text;
    } catch (_) {
      throw const OcrException(
        "We couldn't read this image. It may be unsupported or unclear. Try another screenshot, or paste the text.",
      );
    } finally {
      await recognizer.close();
    }
  }
}
