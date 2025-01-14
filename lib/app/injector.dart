import 'package:auto_injector/auto_injector.dart';
import 'package:fivethreeone_log/app/data/repositories/shared_preferences_repository.dart';
import 'package:fivethreeone_log/app/data/repositories/shared_preferences_workout_repository.dart';
import 'package:fivethreeone_log/app/interactor/repository/preferences_repository.dart';
import 'package:fivethreeone_log/app/interactor/repository/workout_repository.dart';

final injector = AutoInjector();

void setupInjector() {
  injector.add<PreferencesRepository>(SharedPreferencesRepository.new);
  injector.add<WorkoutRepository>(SharedPreferencesWorkoutRepository.new);
}