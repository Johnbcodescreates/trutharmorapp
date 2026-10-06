/// Non-web builds never call this (see ocr_service.dart). It exists so the
/// app compiles on Android and iOS, where `dart:js_interop` isn't available.
class WebOcrLoadException implements Exception {}

Future<String> recognizeText(String imageUrl) =>
    Future.error(UnsupportedError('Web OCR is only available in a browser.'));
