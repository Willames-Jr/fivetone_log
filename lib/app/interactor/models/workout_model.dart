import 'package:flutter/foundation.dart';
import 'set_model.dart';

@immutable
class WorkoutModel {
  final String id;
  final DateTime date;
  final String exerciseName;
  final int numberOfSets;
  final List<SetModel> sets;
  final String notes; // New field
  final double oneRM; // New field
  final double volume; // New field
  final Duration timeSpent; // New field
  final int cycle; // New field
  final int week; // New field

  const WorkoutModel({
    required this.id,
    required this.date,
    required this.exerciseName,
    required this.numberOfSets,
    required this.sets,
    this.notes = '', // Initialize with an empty string
    required this.oneRM, // New field
    required this.volume, // New field
    required this.timeSpent, // New field
    required this.cycle, // New field
    required this.week, // New field
  });

  WorkoutModel copyWith({
    String? id,
    DateTime? date,
    String? exerciseName,
    int? numberOfSets,
    List<SetModel>? sets,
    String? notes, // New field
    double? oneRM, // New field
    double? volume, // New field
    Duration? timeSpent, // New field
    int? cycle, // New field
    int? week, // New field
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      date: date ?? this.date,
      exerciseName: exerciseName ?? this.exerciseName,
      numberOfSets: numberOfSets ?? this.numberOfSets,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes, // New field
      oneRM: oneRM ?? this.oneRM, // New field
      volume: volume ?? this.volume, // New field
      timeSpent: timeSpent ?? this.timeSpent, // New field
      cycle: cycle ?? this.cycle, // New field
      week: week ?? this.week, // New field
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          exerciseName == other.exerciseName &&
          numberOfSets == other.numberOfSets &&
          listEquals(sets, other.sets) &&
          notes == other.notes && // New field
          oneRM == other.oneRM && // New field
          volume == other.volume && // New field
          timeSpent == other.timeSpent && // New field
          cycle == other.cycle && // New field
          week == other.week; // New field

  @override
  int get hashCode =>
      id.hashCode ^ date.hashCode ^ exerciseName.hashCode ^ numberOfSets.hashCode ^ sets.hashCode ^ notes.hashCode ^ oneRM.hashCode ^ volume.hashCode ^ timeSpent.hashCode ^ cycle.hashCode ^ week.hashCode; // New fields
}