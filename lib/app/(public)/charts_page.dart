import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fivethreeone_log/app/interactor/providers/workout_provider.dart';
import 'package:fivethreeone_log/app/interactor/providers/preferences_provider.dart'; // Import PreferencesProvider
import 'package:fivethreeone_log/app/utils/utils.dart'; // Import utility functions
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChartsPage extends ConsumerStatefulWidget {
  const ChartsPage({super.key});

  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends ConsumerState<ChartsPage> {
  String? selectedExercise;

  String getTranslatedExerciseName(String exercise, AppLocalizations localizations) {
    switch (exercise) {
      case 'Agachamento':
        return localizations.squat;
      case 'Supino':
        return localizations.bench;
      case 'Levantamento terra':
        return localizations.deadLift;
      case 'Press militar':
        return localizations.militaryPress;
      default:
        return exercise; // Fallback to the original name if not found
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final workouts = ref.watch(workoutProvider);
    final preferences = ref.watch(preferencesProvider);

    // Filter workouts by selected exercise
    final filteredWorkouts = selectedExercise == null
        ? []
        : workouts.where((w) => w.exerciseName == selectedExercise).toList();

    
    final oneRMData = <FlSpot>[];
    final volumeData = <FlSpot>[];

    final exerciseRMData = <FlSpot>[];
    final exerciseVolumeData = <FlSpot>[];

    final cycleMaxOneRM = <int, double>{};
    final cycleVolume = <int, double>{};

    for (var workout in filteredWorkouts) {
      final cycle = workout.cycle;
      final oneRM =
          calculate1RM(workout.sets.last.weight, workout.sets.last.reps);
      final volume =
          workout.sets.fold(0.0, (sum, set) => sum + set.weight * set.reps);

      exerciseRMData
          .add(FlSpot(filteredWorkouts.indexOf(workout).toDouble(), oneRM));
      exerciseVolumeData
          .add(FlSpot(filteredWorkouts.indexOf(workout).toDouble(), volume));

      if (cycleMaxOneRM.containsKey(cycle)) {
        if (oneRM > cycleMaxOneRM[cycle]!) {
          cycleMaxOneRM[cycle] = oneRM;
        }
        cycleVolume[cycle] = cycleVolume[cycle]! + volume;
      } else {
        cycleMaxOneRM[cycle] = oneRM;
        cycleVolume[cycle] = volume;
      }
    }
    cycleMaxOneRM.forEach((cycle, oneRM) {
      oneRMData.add(FlSpot(cycle.toDouble(), oneRM));
    });

    cycleVolume.forEach((cycle, volume) {
      volumeData.add(FlSpot(cycle.toDouble(), volume));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.workoutCharts),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              DropdownButton<String>(
                hint: Text(localizations.selectExerciseDropdown),
                value: selectedExercise,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedExercise = newValue;
                  });
                },
                items: preferences.rmData.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(getTranslatedExerciseName(value, localizations)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              if (exerciseRMData.isNotEmpty) ...[
                Text(localizations.oneRMProgression,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16.0),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: exerciseRMData,
                          isCurved: false,
                          barWidth: 4,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.blue,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
                      maxX: exerciseRMData.isNotEmpty
                          ? exerciseRMData.length.toDouble()
                          : 0,
                      minX: 0,
                      maxY: exerciseRMData.isNotEmpty
                          ? (exerciseRMData
                                  .map((e) => e.y)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.5).ceilToDouble()
                          : 0,
                      minY: exerciseRMData.isNotEmpty
                          ? (exerciseRMData
                                  .map((e) => e.y)
                                  .reduce((a, b) => a < b ? a : b) /
                              2).ceilToDouble()
                          : 0,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                            interval: 50,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                Text(localizations.volumeProgression,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16.0),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: exerciseVolumeData,
                          isCurved: false,
                          barWidth: 4,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.blue,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
                      maxX: exerciseVolumeData.isNotEmpty
                          ? exerciseVolumeData.length.toDouble()
                          : 0,
                      minX: 0,
                      maxY: exerciseVolumeData.isNotEmpty
                          ? (exerciseVolumeData
                                  .map((e) => e.y)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.5).ceilToDouble() 
                          : 0,
                      minY: exerciseVolumeData.isNotEmpty
                          ? (exerciseVolumeData
                                  .map((e) => e.y)
                                  .reduce((a, b) => a < b ? a : b) /
                              2).ceilToDouble()
                          : 0,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                            interval: 50,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (exerciseRMData.isEmpty) ...[
                Text(
                  localizations.noDataAvailableForSelectedExercise,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
