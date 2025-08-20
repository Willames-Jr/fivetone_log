import 'package:flutter/foundation.dart';

@immutable
class PreferencesModel {
  final String selectedUnit;
  final Map<String, double> rmData; // Changed to store 1RM values
  final Map<String, Map<String, double>> percData;
  final Map<String, Map<String, int>> cycleWeekData; // New field
  final Map<String, double> tmData; // Add this field

  const PreferencesModel({
    required this.selectedUnit,
    required this.rmData,
    required this.percData,
    required this.cycleWeekData, // New field
    required this.tmData,
  });

  PreferencesModel copyWith({
    String? selectedUnit,
    Map<String, double>? rmData, // Changed to store 1RM values
    Map<String, Map<String, double>>? percData,
    Map<String, Map<String, int>>? cycleWeekData, // New field
    Map<String, double>? tmData,
  }) {
    return PreferencesModel(
      selectedUnit: selectedUnit ?? this.selectedUnit,
      rmData: rmData ?? this.rmData, // Changed to store 1RM values
      percData: percData ?? this.percData,
      cycleWeekData: cycleWeekData ?? this.cycleWeekData, // New field
      tmData: tmData ?? this.tmData,
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
          mapEquals(cycleWeekData, other.cycleWeekData) && // New field
          mapEquals(tmData, other.tmData); // Add this line

  @override
  int get hashCode =>
      selectedUnit.hashCode ^ rmData.hashCode ^ percData.hashCode ^ cycleWeekData.hashCode ^ tmData.hashCode; // Add tmData to hashCode
}