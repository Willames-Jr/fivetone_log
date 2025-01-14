import 'package:auto_injector/auto_injector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fivethreeone_log/app/injector.dart';
import '../models/preferences_model.dart';
import '../repository/preferences_repository.dart';

class PreferencesNotifier extends StateNotifier<PreferencesModel> {
  final PreferencesRepository _repository;

  PreferencesNotifier(this._repository)
      : super(const PreferencesModel(
          selectedUnit: 'kg',
          rmData: {},
          percData: {},
          cycleWeekData: {}, // New field
        ));

  Future<void> loadPreferences() async {
    final preferences = await _repository.get();
    if (preferences != null) {
      state = preferences;
    }
  }

  // Create or Update Preferences
  Future<void> setPreferences(PreferencesModel newPreferences) async {
    await _repository.insert(newPreferences);
    state = newPreferences;
  }

  // Read Preferences
  PreferencesModel getPreferences() {
    return state;
  }

  // Update selected unit
  Future<void> updateSelectedUnit(String newUnit) async {
    final updatedPreferences = state.copyWith(selectedUnit: newUnit);
    await _repository.update(updatedPreferences);
    state = updatedPreferences;
  }

  // Update 1RM Data
  Future<void> updateOneRM(String key, double newOneRM) async {
    final updatedRmData = Map<String, double>.from(state.rmData)
      ..[key] = newOneRM;
    final updatedPreferences = state.copyWith(rmData: updatedRmData);
    await _repository.update(updatedPreferences);
    state = updatedPreferences;
  }

  // Update Percentage Data
  Future<void> updatePercData(String key, Map<String, double> newData) async {
    final updatedPercData =
        Map<String, Map<String, double>>.from(state.percData)..[key] = newData;
    final updatedPreferences = state.copyWith(percData: updatedPercData);
    await _repository.update(updatedPreferences);
    state = updatedPreferences;
  }

  // Delete 1RM Data
  Future<void> deleteRmData(String key) async {
    final updatedRmData = Map<String, double>.from(state.rmData)
      ..remove(key);
    final updatedPreferences = state.copyWith(rmData: updatedRmData);
    await _repository.update(updatedPreferences);
    state = updatedPreferences;
  }

  // Delete Percentage Data
  Future<void> deletePercData(String key) async {
    final updatedPercData =
        Map<String, Map<String, double>>.from(state.percData)..remove(key);
    final updatedPreferences = state.copyWith(percData: updatedPercData);
    await _repository.update(updatedPreferences);
    state = updatedPreferences;
  }

  Future<void> delete() async {
    await _repository.delete();
    state = const PreferencesModel(
      selectedUnit: 'kg',
      rmData: {},
      percData: {},
      cycleWeekData: {}, // New field
    );
  }

  // Update Cycle and Week Data
  Future<void> updateCycleAndWeek(String exercise, int cycle, int week) async {
    final updatedCycleWeekData = Map<String, Map<String, int>>.from(state.cycleWeekData)
      ..[exercise] = {'cycle': cycle, 'week': week};
    final updatedPreferences = state.copyWith(cycleWeekData: updatedCycleWeekData);
    await _repository.update(updatedPreferences);
    state = updatedPreferences;
  }

  Future<void> setImportedPreferences(PreferencesModel importedPreferences) async {
    state = importedPreferences;
    await _repository.insert(importedPreferences);
  }
}

final preferencesProvider =
  StateNotifierProvider<PreferencesNotifier, PreferencesModel>((ref) {
  final repository = injector.get<PreferencesRepository>();
  return PreferencesNotifier(repository);
});
