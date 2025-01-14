import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../interactor/models/workout_model.dart';
import '../../interactor/repository/workout_repository.dart';
import '../adapters/workout_adapter.dart';

class SharedPreferencesWorkoutRepository implements WorkoutRepository {
  static const String _workoutsKey = 'workouts';

  @override
  Future<List<WorkoutModel?>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsString = prefs.getString(_workoutsKey);
    if (workoutsString != null) {
      final workoutsList = List<Map<String, dynamic>>.from(
        jsonDecode(workoutsString) as List<dynamic>,
      );
      return workoutsList.map((workoutMap) => WorkoutAdapter.fromMap(workoutMap)).toList();
    }
    return [];
  }

  @override
  Future<WorkoutModel?> get(int id) async {
    final workouts = await getAll();
    return workouts.firstWhere((workout) => workout?.id == id.toString(), orElse: () => null);
  }

  @override
  Future<WorkoutModel> insert(WorkoutModel workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getAll();
    workouts.add(workout);
    final workoutsString = jsonEncode(workouts.map((workout) => workout == null ? null : WorkoutAdapter.toMap(workout)).toList());
    await prefs.setString(_workoutsKey, workoutsString);
    return workout;
  }

  @override
  Future<WorkoutModel> update(WorkoutModel workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getAll();
    final index = workouts.indexWhere((w) => w?.id == workout.id);
    if (index != -1) {
      workouts[index] = workout;
      final workoutsString = jsonEncode(workouts.map((workout) => workout == null ? null : WorkoutAdapter.toMap(workout)).toList());
      await prefs.setString(_workoutsKey, workoutsString);
    }
    return workout;
  }

  @override
  Future<bool> delete(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getAll();
    final updatedWorkouts = workouts.where((workout) => workout?.id != id.toString()).toList();
    final workoutsString = jsonEncode(updatedWorkouts.map((workout) => workout == null ? null : WorkoutAdapter.toMap(workout)).toList());
    await prefs.setString(_workoutsKey, workoutsString);
    return true;
  }
}
