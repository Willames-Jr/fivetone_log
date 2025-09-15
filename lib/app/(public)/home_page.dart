import 'package:fivethreeone_log/app/(public)/charts_page.dart';
import 'package:fivethreeone_log/app/(public)/info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fivethreeone_log/app/interactor/providers/preferences_provider.dart';
import 'package:fivethreeone_log/app/interactor/providers/workout_provider.dart'; // Import the WorkoutProvider
import 'package:fivethreeone_log/app/utils/utils.dart'; // Import the utility functions
import 'package:fivethreeone_log/app/(public)/workout_page.dart'; // Import the WorkoutPage
import 'package:fivethreeone_log/app/(public)/saved_workouts_page.dart'; // Import the SavedWorkoutsPage
import 'package:intl/intl.dart'; // Import DateFormat
import 'package:fivethreeone_log/app/(public)/export_import_page.dart'; // Import the ExportImportPage
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fivethreeone_log/app/utils/exercise_names.dart'; // Import the exercise names mapping

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final workouts = ref.watch(workoutProvider);
    final localizations = AppLocalizations.of(context)!;

    // Find the most recent workout
    final latestWorkout = workouts.isNotEmpty
        ? workouts.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homePageTitle),
        elevation: 4.0, // Adds a shadow at the bottom of the AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedWorkoutsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportImportPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.area_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChartsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InfoPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(localizations.selectExercise),
            if (latestWorkout != null) ...[
              const SizedBox(height: 16.0),
              Text(
                '${localizations.lastWorkout}: ${getTranslatedExerciseName(latestWorkout.exerciseName, localizations)} - ${DateFormat('EEEE, MMM d, yyyy').format(latestWorkout.date)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 16.0),
            for (var exercise in preferences.rmData.keys) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:  ListTile(
                      title: Text(getTranslatedExerciseName(exercise, localizations)),
                      subtitle: Text(
                        '1RM: ${'${preferences.rmData[exercise]} ${preferences.selectedUnit}' ?? ''}\n' 
                        '${localizations.cycle}: ${preferences.cycleWeekData[exercise]?['cycle'] ?? 1} ${localizations.week}: ${preferences.cycleWeekData[exercise]?['week'] ?? 1}',
                      ),
                      leading: const Icon(Icons.fitness_center),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutPage(exercise: exercise),
                            ),
                          );
                        },
                    ),
                  ),
                ),
              ),
              /* ListTile(
                title: Text(getTranslatedExerciseName(exercise, localizations)),
                subtitle: Text(
                  '1RM: ${'${preferences.rmData[exercise]} ${preferences.selectedUnit}' ?? ''}\n' 
                  '${localizations.cycle}: ${preferences.cycleWeekData[exercise]?['cycle'] ?? 1} ${localizations.week}: ${preferences.cycleWeekData[exercise]?['week'] ?? 1}',
                ),
                leading: const Icon(Icons.fitness_center),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutPage(exercise: exercise),
                      ),
                    );
                  },
                ),
                
              ), */ // Add a divider between the tiles
            ],
          ],
        ),
      ),
    );
  }
}