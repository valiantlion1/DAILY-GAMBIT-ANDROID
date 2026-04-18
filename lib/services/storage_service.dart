import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../core/models.dart';

class StorageService {
  static const String _boxName = 'daily_gambit_box';
  static const String _profileKey = 'profile_json';
  static const String _gameKey = 'game_json';
  static const String _puzzleKey = 'puzzle_json';

  late final Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<AppProfile> loadProfile() async {
    final String? raw = _box.get(_profileKey);
    if (raw == null) {
      return AppProfile.initial();
    }
    return AppProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<PersistedGameState> loadGame() async {
    final String? raw = _box.get(_gameKey);
    if (raw == null) {
      return PersistedGameState.initial();
    }
    return PersistedGameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<PuzzleProgressState?> loadPuzzle() async {
    final String? raw = _box.get(_puzzleKey);
    if (raw == null) {
      return null;
    }
    return PuzzleProgressState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(AppProfile profile) async {
    await _box.put(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> saveGame(PersistedGameState state) async {
    await _box.put(_gameKey, jsonEncode(state.toJson()));
  }

  Future<void> savePuzzle(PuzzleProgressState state) async {
    await _box.put(_puzzleKey, jsonEncode(state.toJson()));
  }
}
