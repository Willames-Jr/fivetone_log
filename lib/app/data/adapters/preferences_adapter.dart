import '../../interactor/models/preferences_model.dart';

class PreferencesAdapter {
  // Convert a Map to PreferencesModel
  static PreferencesModel fromMap(Map<String, dynamic> map) {
    return PreferencesModel(
      selectedUnit: map['selectedUnit'] as String,
      rmData: Map<String, double>.from(map['rmData'] as Map), // Changed to store 1RM values
      percData: (map['percData'] as Map<String, dynamic>).map((key, value) => MapEntry(key, Map<String, double>.from(value as Map))),
      cycleWeekData: (map['cycleWeekData'] as Map<String, dynamic>).map((key, value) => MapEntry(key, Map<String, int>.from(value as Map))), // New field
      tmData: Map<String, double>.from(map['tmData'] ?? {}), // New field
    );
  }

  // Convert PreferencesModel to a Map
  static Map<String, dynamic> toMap(PreferencesModel model) {
    return {
      'selectedUnit': model.selectedUnit,
      'rmData': model.rmData, // Changed to store 1RM values
      'percData': model.percData,
      'cycleWeekData': model.cycleWeekData, // New field
      'tmData': model.tmData, // New field
    };
  }
}