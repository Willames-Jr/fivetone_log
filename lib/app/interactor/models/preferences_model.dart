import 'package:flutter/foundation.dart';

@immutable
class PreferencesModel {
  final String selectedUnit;
  final Map<String, double> rmData; // Changed to store 1RM values
  final Map<String, Map<String, double>> percData;
  final Map<String, Map<String, int>> cycleWeekData; // New field

  const PreferencesModel({
    required this.selectedUnit,
    required this.rmData,
    required this.percData,
    required this.cycleWeekData, // New field
  });

  PreferencesModel copyWith({
    String? selectedUnit,
    Map<String, double>? rmData, // Changed to store 1RM values
    Map<String, Map<String, double>>? percData,
    Map<String, Map<String, int>>? cycleWeekData, // New field
  }) {
    return PreferencesModel(
      selectedUnit: selectedUnit ?? this.selectedUnit,
      rmData: rmData ?? this.rmData, // Changed to store 1RM values
      percData: percData ?? this.percData,
      cycleWeekData: cycleWeekData ?? this.cycleWeekData, // New field
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferencesModel &&
          runtimeType == other.runtimeType &&
          selectedUnit == other.selectedUnit &&
          mapEquals(rmData, other.rmData) && // Changed to store 1RM values
          mapEquals(percData, other.percData) &&
          mapEquals(cycleWeekData, other.cycleWeekData); // New field

  @override
  int get hashCode =>
      selectedUnit.hashCode ^ rmData.hashCode ^ percData.hashCode ^ cycleWeekData.hashCode; // New field
}