import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fivethreeone_log/app/interactor/providers/workout_provider.dart';
import 'package:fivethreeone_log/app/interactor/providers/preferences_provider.dart'; // Import PreferencesProvider
import 'package:fivethreeone_log/app/utils/utils.dart'; // Import utility functions

class ChartsPage extends ConsumerStatefulWidget {
  const ChartsPage({super.key});

  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends ConsumerState<ChartsPage> {
  String? selectedExercise;

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(workoutProvider);
    final preferences = ref.watch(preferencesProvider);

    // Filter workouts by selected exercise
    final filteredWorkouts = selectedExercise == null
        ? workouts
        : workouts.where((w) => w.exerciseName == selectedExercise).toList();

    // Prepare data for charts
    final oneRMData = <FlSpot>[];
    final volumeData = <FlSpot>[];

    final cycleMaxOneRM = <int, double>{};
    final cycleVolume = <int, double>{};

    for (var workout in filteredWorkouts) {
      final cycle = workout.cycle;
      final oneRM = calculate1RM(workout.sets.last.weight, workout.sets.last.reps);
      final volume = workout.sets.fold(0.0, (sum, set) => sum + set.weight * set.reps);

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
        title: const Text('Workout Charts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text('Select Exercise'),
              value: selectedExercise,
              onChanged: (String? newValue) {
                setState(() {
                  selectedExercise = newValue;
                });
              },
              items: preferences.rmData.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            const Text('1RM Progression',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: oneRMData,
                      isCurved: true,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('Cycle ${value.toInt()}');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            const Text('Volume Progression',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: volumeData,
                      isCurved: true,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('Cycle ${value.toInt()}');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
