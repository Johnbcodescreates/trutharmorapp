import 'package:flutter/foundation.dart';

import '../models/history_entry.dart';
import '../models/risk.dart';
import '../services/history/history_repository.dart';

/// App-wide state: accessibility settings + privacy-first scan history.
class AppState extends ChangeNotifier {
  AppState({HistoryRepository? history, SettingsRepository? settings})
      : _historyRepo = history ?? HistoryRepository(),
        _settingsRepo = settings ?? SettingsRepository();

  final HistoryRepository _historyRepo;
  final SettingsRepository _settingsRepo;

  bool _simpleMode = false;
  bool _saveHistory = true;
  List<HistoryEntry> _history = [];
  int _tabIndex = 0;

  bool get simpleMode => _simpleMode;
  bool get saveHistory => _saveHistory;
  List<HistoryEntry> get history => List.unmodifiable(_history);
  int get tabIndex => _tabIndex;

  Future<void> load() async {
    final s = await _settingsRepo.load();
    _simpleMode = s.simpleMode;
    _saveHistory = s.saveHistory;
    _history = await _historyRepo.load();
    notifyListeners();
  }

  void setTab(int index) {
    if (index == _tabIndex) return;
    _tabIndex = index;
    notifyListeners();
  }

  Future<void> setSimpleMode(bool value) async {
    _simpleMode = value;
    notifyListeners();
    await _settingsRepo.setSimpleMode(value);
  }

  Future<void> setSaveHistory(bool value) async {
    _saveHistory = value;
    notifyListeners();
    await _settingsRepo.setSaveHistory(value);
  }

  /// Records ONLY metadata about an assessment (never its content).
  Future<void> record(Assessment a) async {
    if (!_saveHistory) return;
    _history = [
      HistoryEntry(
        id: a.id,
        date: a.createdAt,
        categoryId: a.categoryId,
        level: a.level,
        title: a.title,
        isDemo: a.isDemoExample,
      ),
      ..._history.where((e) => e.id != a.id),
    ];
    notifyListeners();
    await _historyRepo.save(_history);
  }

  bool isInHistory(String id) => _history.any((e) => e.id == id);

  Future<void> deleteScan(String id) async {
    _history = _history.where((e) => e.id != id).toList();
    notifyListeners();
    await _historyRepo.save(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _historyRepo.save(_history);
  }
}
