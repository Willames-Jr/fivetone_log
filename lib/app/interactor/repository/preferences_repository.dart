import '../models/preferences_model.dart';

abstract class PreferencesRepository {
  Future<PreferencesModel?> get();
  Future<PreferencesModel> insert(PreferencesModel preferences);
  Future<PreferencesModel> update(PreferencesModel preferences);
  Future<bool> delete();
  Future<void> updateCycleAndWeek(String exercise, int cycle, int week);
}