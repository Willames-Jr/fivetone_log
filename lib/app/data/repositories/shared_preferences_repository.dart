import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../interactor/models/preferences_model.dart';
import '../../interactor/repository/preferences_repository.dart';
import '../adapters/preferences_adapter.dart';

class SharedPreferencesRepository implements PreferencesRepository {
  static const String _preferencesKey = 'preferences';

  @override
  Future<PreferencesModel?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesString = prefs.getString(_preferencesKey);
    if (preferencesString != null) {
      final preferencesMap = Map<String, dynamic>.from(
        jsonDecode(preferencesString) as Map<String, dynamic>,
      );
      return PreferencesAdapter.fromMap(preferencesMap);
    }
    return null;
  }

  @override
  Future<PreferencesModel> insert(PreferencesModel preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesMap = PreferencesAdapter.toMap(preferences);
    final preferencesString = jsonEncode(preferencesMap);
    await prefs.setString(_preferencesKey, preferencesString);
    return preferences;
  }

  @override
  Future<PreferencesModel> update(PreferencesModel preferences) async {
    return insert(preferences); // In SharedPreferences, insert and update are the same
  }

  @override
  Future<bool> delete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_preferencesKey);
  }

  @override
  Future<void> updateCycleAndWeek(String exercise, int cycle, int week) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesString = prefs.getString(_preferencesKey);
    if (preferencesString != null) {
      final preferencesMap = Map<String, dynamic>.from(
        jsonDecode(preferencesString) as Map<String, dynamic>,
      );
      final preferences = PreferencesAdapter.fromMap(preferencesMap);
      final updatedCycleWeekData = Map<String, Map<String, int>>.from(preferences.cycleWeekData)
        ..[exercise] = {'cycle': cycle, 'week': week};
      final updatedPreferences = preferences.copyWith(cycleWeekData: updatedCycleWeekData);
      await insert(updatedPreferences);
    }
  }
}