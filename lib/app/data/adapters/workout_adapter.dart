import '../../interactor/models/workout_model.dart';
import '../../interactor/models/set_model.dart';
import 'set_adapter.dart';

class WorkoutAdapter {
  // Convert a Map to WorkoutModel
  static WorkoutModel fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      exerciseName: map['exerciseName'] as String,
      numberOfSets: map['numberOfSets'] as int,
      sets: (map['sets'] as List<dynamic>).map((set) => SetAdapter.fromMap(set as Map<String, dynamic>)).toList(),
      notes: map['notes'] as String? ?? '', // Handle missing field
      oneRM: map['oneRM'] as double? ?? 0.0, // Handle missing field
      volume: map['volume'] as double? ?? 0.0, // Handle missing field
      timeSpent: Duration(seconds: map['timeSpent'] as int? ?? 0), // Handle missing field
      cycle: map['cycle'] as int? ?? 1, // Handle missing field
      week: map['week'] as int? ?? 1, // Handle missing field
    );
  }

  // Convert WorkoutModel to a Map
  static Map<String, dynamic> toMap(WorkoutModel workout) {
    return {
      'id': workout.id,
      'date': workout.date.toIso8601String(),
      'exerciseName': workout.exerciseName,
      'numberOfSets': workout.numberOfSets,
      'sets': workout.sets.map((set) => SetAdapter.toMap(set)).toList(),
      'notes': workout.notes, // New field
      'oneRM': workout.oneRM, // New field
      'volume': workout.volume, // New field
      'timeSpent': workout.timeSpent.inSeconds, // New field
      'cycle': workout.cycle, // New field
      'week': workout.week, // New field
    };
  }
}
