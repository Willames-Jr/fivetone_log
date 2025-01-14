import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fivethreeone_log/app/interactor/models/workout_model.dart';
import 'package:fivethreeone_log/app/interactor/repository/workout_repository.dart';
import 'package:fivethreeone_log/app/injector.dart';

class WorkoutNotifier extends StateNotifier<List<WorkoutModel>> {
  final WorkoutRepository _repository;

  WorkoutNotifier(this._repository) : super([]) {
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts = await _repository.getAll();
    state = workouts.whereType<WorkoutModel>().toList();
  }

  Future<void> addWorkout(WorkoutModel workout) async {
    await _repository.insert(workout);
    state = [...state, workout];
  }

  Future<void> updateWorkout(WorkoutModel workout) async {
    await _repository.update(workout);
    state = [
      for (final w in state)
        if (w.id == workout.id) workout else w,
    ];
  }

  Future<void> deleteWorkout(String id) async {
    await _repository.delete(int.parse(id));
    state = state.where((workout) => workout.id != id).toList();
  }

  Future<List<WorkoutModel?>> getAllWorkouts() async {
    return await _repository.getAll();
  }

  Future<void> setImportedWorkouts(List<WorkoutModel> importedWorkouts) async {
    state = importedWorkouts;
    for (final workout in importedWorkouts) {
      await _repository.insert(workout);
    }
  }
}

final workoutProvider = StateNotifierProvider<WorkoutNotifier, List<WorkoutModel>>((ref) {
  final repository = injector.get<WorkoutRepository>();
  return WorkoutNotifier(repository);
});
