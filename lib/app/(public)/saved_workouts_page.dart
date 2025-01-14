import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fivethreeone_log/app/interactor/providers/workout_provider.dart';
import 'package:fivethreeone_log/app/interactor/providers/preferences_provider.dart';
import 'package:fivethreeone_log/app/interactor/models/workout_model.dart';
import 'package:fivethreeone_log/app/(public)/edit_workout_page.dart'; // Import the EditWorkoutPage
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fivethreeone_log/app/utils/exercise_names.dart'; // Import the exercise names mapping

class SavedWorkoutsPage extends ConsumerWidget {
  const SavedWorkoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutProvider);
    final preferences = ref.watch(preferencesProvider);
    final selectedUnit = preferences.selectedUnit;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.savedWorkouts),
      ),
      body: workouts.isEmpty
          ? Center(child: Text(localizations.noSavedWorkouts))
          : ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                final formattedDate =
                    DateFormat('EEEE, MMM d, yyyy').format(workout.date);
                final formattedTimeSpent =
                    _formatDuration(workout.timeSpent); // Format the time spent

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4.0,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(getTranslatedExerciseName(workout.exerciseName, localizations)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditWorkoutPage(workout: workout),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _deleteWorkout(ref, workout);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8.0),
                          Text('$formattedDate'),
                          ],
                        ),
                        const SizedBox(width: 8.0),
                        Row(
                          children: [
                          const Icon(Icons.repeat),
                          const SizedBox(width: 8.0),
                          Text('${localizations.cycle}: ${workout.cycle} ${localizations.week}: ${workout.week}'),
                          ],
                        ),
                        const SizedBox(width: 4.0),
                        Row(
                          children: [
                          const Icon(Icons.fitness_center_outlined),
                          const SizedBox(width: 8.0),
                          Text('${localizations.volume}: ${workout.volume} 1RM: ${workout.oneRM} $selectedUnit'),
                          ],
                        ),
                        const SizedBox(width: 4.0),
                        Row(
                          children: [
                          const Icon(Icons.history),
                          const SizedBox(width: 8.0),
                          Text('${localizations.timeSpent}: $formattedTimeSpent'),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${localizations.notes}: ${workout.notes}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (workout.notes.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(localizations.notes),
                                        content: Text(workout.notes),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _deleteWorkout(WidgetRef ref, WorkoutModel workout) async {
    final workoutNotifier = ref.read(workoutProvider.notifier);
    final preferencesNotifier = ref.read(preferencesProvider.notifier);

    await workoutNotifier.deleteWorkout(workout.id);

    // Check if the deleted workout was the most recent one for the cycle and week
    final workouts = ref.read(workoutProvider);
    if (workouts.isNotEmpty) {
      final mostRecentWorkout = workouts
          .where((w) => w.exerciseName == workout.exerciseName)
          .reduce((a, b) {
            final aCycleWeek = a.cycle * 4 + a.week;
            final bCycleWeek = b.cycle * 4 + b.week;
            return aCycleWeek > bCycleWeek ? a : b;
          });

      if (mostRecentWorkout != null) {
        final currentCycleWeek = mostRecentWorkout.cycle * 4 + mostRecentWorkout.week + 1;
        await preferencesNotifier.updateCycleAndWeek(
          workout.exerciseName,
          currentCycleWeek ~/ 4,
          currentCycleWeek % 4 == 0 ? 4 : currentCycleWeek % 4,
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
