import 'package:fivethreeone_log/app/interactor/models/workout_model.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutModel?>> getAll();
  Future<WorkoutModel?> get(int id);
  Future<WorkoutModel> insert(WorkoutModel workout);
  Future<WorkoutModel> update(WorkoutModel workout);
  Future<bool> delete(int id);
}