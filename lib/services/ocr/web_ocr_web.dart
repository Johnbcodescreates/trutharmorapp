import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Screenshot reading in the browser using Tesseract.js (open source OCR).
///
/// The library is loaded on first use from the jsDelivr CDN. Recognition runs
/// entirely inside the user's browser: the image is NOT uploaded anywhere.
/// (Tesseract downloads its English language data the first time, so the
/// first screenshot can take up to a minute.)
const _tesseractUrl = 'https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js';

class WebOcrLoadException implements Exception {}

@JS('Tesseract')
external _Tesseract? get _tesseract;

extension type _Tesseract._(JSObject _) implements JSObject {
  external JSPromise<_Result> recognize(JSString image, JSString language);
}

extension type _Result._(JSObject _) implements JSObject {
  external _ResultData get data;
}

extension type _ResultData._(JSObject _) implements JSObject {
  external JSString? get text;
}

Future<void>? _loading;

Future<void> _ensureLoaded() {
  if (_tesseract != null) return Future.value();
  return _loading ??= _loadScript();
}

Future<void> _loadScript() {
  final completer = Completer<void>();
  final script = web.document.createElement('script') as web.HTMLScriptElement;
  script.src = _tesseractUrl;
  script.onload = ((web.Event _) {
    if (!completer.isCompleted) completer.complete();
  }).toJS;
  script.onerror = ((web.Event _) {
    _loading = null; // allow a retry later
    if (!completer.isCompleted) completer.completeError(WebOcrLoadException());
  }).toJS;
  web.document.head!.appendChild(script);
  return completer.future.timeout(
    const Duration(seconds: 30),
    onTimeout: () {
      _loading = null;
      throw WebOcrLoadException();
    },
  );
}

/// [imageUrl] is the blob URL that image_picker returns on the web.
Future<String> recognizeText(String imageUrl) async {
  await _ensureLoaded();
  final tesseract = _tesseract;
  if (tesseract == null) throw WebOcrLoadException();

  final result = await tesseract
      .recognize(imageUrl.toJS, 'eng'.toJS)
      .toDart
      .timeout(const Duration(seconds: 120));
  return result.data.text?.toDart ?? '';
}
