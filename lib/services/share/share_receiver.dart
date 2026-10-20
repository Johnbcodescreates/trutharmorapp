import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Something another app shared to TruthArmor ("Share → TruthArmor").
class SharedItem {
  const SharedItem({this.text, this.imagePath});

  /// Shared text or link (from Messages, Gmail, Chrome, WhatsApp, …).
  final String? text;

  /// A temporary copy of a shared screenshot. It is read on the device and
  /// deleted right after — never uploaded or kept.
  final String? imagePath;

  bool get isEmpty => (text == null || text!.trim().isEmpty) && imagePath == null;

  static SharedItem? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final item = SharedItem(text: raw['text'] as String?, imagePath: raw['imagePath'] as String?);
    return item.isEmpty ? null : item;
  }
}

/// Receives items shared from other Android apps.
///
/// The Android side lives in android/app/src/main/kotlin/.../MainActivity.kt
/// and talks to this class over the "trutharmor/share" channel.
class ShareReceiver {
  ShareReceiver._() {
    if (isSupported) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onShare') {
          final item = SharedItem.fromMap(call.arguments);
          if (item == null) return;
          // If nothing is listening yet (app still starting), keep it for initialShare().
          if (_controller.hasListener) {
            _controller.add(item);
          } else {
            _pending = item;
          }
        }
      });
    }
  }

  static final instance = ShareReceiver._();

  static const _channel = MethodChannel('trutharmor/share');
  final _controller = StreamController<SharedItem>.broadcast();
  SharedItem? _pending;

  bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// True once the Android side has answered (so "Share → TruthArmor" works).
  bool get isAvailable => _available;
  bool _available = false;

  /// Items shared while the app is already open.
  Stream<SharedItem> get onShare => _controller.stream;

  /// The item that opened the app, if any (asked once at start-up).
  Future<SharedItem?> initialShare() async {
    if (!isSupported) return null;
    if (_pending != null) {
      final p = _pending;
      _pending = null;
      _available = true;
      return p;
    }
    try {
      final raw = await _channel.invokeMethod<Object?>('getInitialShare');
      _available = true;
      return SharedItem.fromMap(raw);
    } catch (_) {
      return null; // Older build without the Android side — sharing just isn't available.
    }
  }

  /// Deletes the temporary screenshot copy.
  static Future<void> deleteTempImage(String? path) async {
    if (path == null || kIsWeb) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
