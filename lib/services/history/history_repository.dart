import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/history_entry.dart';

/// Stores scan history on the device only, as metadata (date, category,
/// risk level, short title). Message content is never saved.
class HistoryRepository {
  static const _key = 'truth_armor.history.v1';
  static const maxEntries = 100;

  Future<List<HistoryEntry>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(HistoryEntry.fromJson)
          .whereType<HistoryEntry>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<HistoryEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trimmed = entries.take(maxEntries).map((e) => e.toJson()).toList();
      await prefs.setString(_key, jsonEncode(trimmed));
    } catch (_) {
      // History is a convenience; never crash if storage is unavailable.
    }
  }
}

/// Simple settings persistence (Simple Mode, onboarding seen, etc).
class SettingsRepository {
  static const _simpleMode = 'truth_armor.simple_mode';
  static const _saveHistory = 'truth_armor.save_history';

  Future<({bool simpleMode, bool saveHistory})> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (
        simpleMode: prefs.getBool(_simpleMode) ?? false,
        saveHistory: prefs.getBool(_saveHistory) ?? true,
      );
    } catch (_) {
      return (simpleMode: false, saveHistory: true);
    }
  }

  Future<void> setSimpleMode(bool v) async {
    try {
      (await SharedPreferences.getInstance()).setBool(_simpleMode, v);
    } catch (_) {}
  }

  Future<void> setSaveHistory(bool v) async {
    try {
      (await SharedPreferences.getInstance()).setBool(_saveHistory, v);
    } catch (_) {}
  }
}
