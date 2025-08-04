import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fivethreeone_log/app/interactor/models/set_model.dart';
import 'package:fivethreeone_log/app/interactor/models/workout_model.dart';
import 'package:fivethreeone_log/app/interactor/providers/preferences_provider.dart';
import 'package:fivethreeone_log/app/interactor/providers/workout_provider.dart';
import 'package:fivethreeone_log/app/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fivethreeone_log/app/utils/exercise_names.dart'; // Import the exercise names mapping

// TODO: Resolver bug: os pesos não estão sendo atualizados corretamente quando o usuário finaliza um ciclo.

class WorkoutPage extends ConsumerStatefulWidget {
  final String exercise;

  const WorkoutPage({super.key, required this.exercise});

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  final Map<int, bool> _isCompleted = {};
  final Map<int, int> _reps = {};
  final Map<int, double> _weights = {};
  late Stopwatch _stopwatch;
  late Timer _timer;
  final TextEditingController _notesController = TextEditingController();
  late Timer _setTimer;
  Duration _setTimerDuration = Duration.zero;
  Duration _selectedSetTimerDuration = const Duration(minutes: 2); // Default value

  void _showNotesDialog(AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.notes),
          content: TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: localizations.enterNotes,
            ),
            maxLines: 5,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(localizations.ok.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSetTimerDialog(AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.selectTimerDuration),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Duration>(
                title: Text('30 ${localizations.seconds}'),
                value: const Duration(seconds: 30),
                groupValue: _selectedSetTimerDuration,
                onChanged: (Duration? value) {
                  setState(() {
                    _selectedSetTimerDuration = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<Duration>(
                title: Text('60 ${localizations.seconds}'),
                value: const Duration(seconds: 60),
                groupValue: _selectedSetTimerDuration,
                onChanged: (Duration? value) {
                  setState(() {
                    _selectedSetTimerDuration = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<Duration>(
                title: Text('90 ${localizations.seconds}'),
                value: const Duration(seconds: 90),
                groupValue: _selectedSetTimerDuration,
                onChanged: (Duration? value) {
                  setState(() {
                    _selectedSetTimerDuration = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<Duration>(
                title: Text('2 ${localizations.minutes}'),
                value: const Duration(minutes: 2),
                groupValue: _selectedSetTimerDuration,
                onChanged: (Duration? value) {
                  setState(() {
                    _selectedSetTimerDuration = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<Duration>(
                title: Text('3 ${localizations.minutes}'),
                value: const Duration(minutes: 3),
                groupValue: _selectedSetTimerDuration,
                onChanged: (Duration? value) {
                  setState(() {
                    _selectedSetTimerDuration = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<Duration>(
                title: Text('5 ${localizations.minutes}'),
                value: const Duration(minutes: 5),
                groupValue: _selectedSetTimerDuration,
                onChanged: (Duration? value) {
                  setState(() {
                    _selectedSetTimerDuration = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startSetTimer() {
    _setTimer.cancel();
    _setTimerDuration = _selectedSetTimerDuration;
    _setTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_setTimerDuration.inSeconds > 0) {
        setState(() {
          _setTimerDuration -= const Duration(seconds: 1);
        });
      } else {
        _setTimer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _stopwatch.start();
    _setTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });

    // Initialize _isCompleted with false for every set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final preferences = ref.read(preferencesProvider);
      final week = preferences.cycleWeekData[widget.exercise]?['week'] ?? 1;
      final sets = preferences.percData['Semana $week']?.entries.toList() ?? [];
      setState(() {
        for (int i = 0; i < sets.length; i++) {
          _isCompleted[i] = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    _setTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _showWeightDialog(int index, double currentWeight, AppLocalizations localizations) {
    final TextEditingController controller =
        TextEditingController(text: currentWeight.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.enterWeight),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: localizations.enterWeight),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(localizations.ok.toUpperCase()),
              onPressed: () {
                setState(() {
                  _weights[index] =
                      double.tryParse(controller.text) ?? currentWeight;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<int> _getRepsForWeek(int week) {
    switch (week) {
      case 1:
      case 4:
        return [5, 5, 5];
      case 2:
        return [3, 3, 3];
      case 3:
        return [5, 3, 1];
      default:
        return [5, 5, 5];
    }
  }

  bool _allSetsCompleted() {
    return _isCompleted.values.every((completed) => completed) && _isCompleted.isNotEmpty;
  }

  Future<void> _saveData(
      int week,
      int cycle,
      double oneRM,
      String exercise,
      List<MapEntry<String, double>> sets,
      Function(WorkoutModel) onSave,
      Function(String, int, int) updateCycleAndWeek,
      Function(String, double) updateOneRM) async {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    final List<SetModel> setsData = [];
    final String notes = _notesController.text; // Get notes from the controller
    final Duration totalTime = _stopwatch.elapsed; // Get total time

    double totalVolume = 0.0;

    _isCompleted.forEach((index, completed) {
      if (completed) {
        final reps = _reps[index] ?? _getRepsForWeek(week)[index];
        final weight = _weights[index] ?? (oneRM * (sets[index].value / 100)).ceilToDouble();
        setsData.add(SetModel(
          setNumber: index + 1,
          reps: reps,
          weight: weight,
        ));
        totalVolume += weight * reps;
      }
    });

    final lastSet = setsData.last;
    final calculated1RM = calculate1RM(lastSet.weight, lastSet.reps);

    final workout = WorkoutModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: now,
      exerciseName: exercise,
      numberOfSets: setsData.length,
      sets: setsData,
      notes: notes, // Store notes
      oneRM: calculated1RM, // Store calculated 1RM
      volume: totalVolume, // Store total volume
      timeSpent: totalTime, // Store total time
      cycle: cycle, // Store cycle
      week: week, // Store week
    );

    onSave(workout);

    int newWeek = week + 1;
    int newCycle = cycle;
    
    if (newWeek > 4) {
      newWeek = 1;
      newCycle += 1;

      // Update 1RM
      double increment =
          (exercise == 'Levantamento terra' || exercise == 'Agachamento')
              ? 5.0
              : 2.5;
      oneRM += increment;
      await updateOneRM(exercise, oneRM);
    }

    await updateCycleAndWeek(exercise, newCycle, newWeek);
  }
  
  String getTranslatedExerciseName(String exercise, AppLocalizations localizations) {
    switch (exercise) {
      case 'Agachamento':
        return localizations.squat;
      case 'Supino':
        return localizations.bench;
      case 'Levantamento terra':
        return localizations.deadLift;
      case 'Desenvolvimento militar':
        return localizations.militaryPress;
      default:
        return exercise; // Fallback to the original name if not found
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);
    final workouts = ref.watch(workoutProvider);
    final localizations = AppLocalizations.of(context)!;
    final oneRM = preferences.rmData[widget.exercise] ?? 0.0;
    final percData = preferences.percData;
    final cycleWeekData = preferences.cycleWeekData[widget.exercise] ??
        {'cycle': 1, 'week': 1}; 
    
    if (oneRM == 0.0) {
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslatedExerciseName(widget.exercise, localizations)),
        ),
        body: Center(
          child: Text('${localizations.noDataAvailable} ${getTranslatedExerciseName(widget.exercise, localizations)}'),
        ),
      );
    }

    final week = cycleWeekData['week']!;
    final sets = percData['Semana $week']?.entries.toList() ?? [];
    final repsForWeek = _getRepsForWeek(week);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                getTranslatedExerciseName(widget.exercise, localizations),
                style: const TextStyle(
                    fontSize: 16), // Keep the font a little bigger
                overflow: TextOverflow
                    .ellipsis, // Limit the size of the exercise title
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _setTimerDuration.inSeconds > 0 ? _formatDuration(_setTimerDuration) : _formatDuration(_stopwatch.elapsed),
              style: const TextStyle(
                  fontSize: 16), // Keep the font a little bigger
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () =>  _showSetTimerDialog(localizations),
          ),
          IconButton(
            icon: const Icon(Icons.comment),
            onPressed: () => _showNotesDialog(localizations),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.cycle}: ${cycleWeekData['cycle']}'),
            Text('${localizations.week}: $week'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ExpansionTile(
                    title: Text(localizations.mainLift),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 10.0,
                          columns: [
                            DataColumn(
                              numeric: false,
                              tooltip: localizations.set,
                              onSort: (columnIndex, ascending) {},
                              label: Center(child: Text(localizations.set)),
                            ),
                            DataColumn(
                              numeric: false,
                              tooltip: localizations.reps,
                              onSort: (columnIndex, ascending) {},
                              label: Center(child: Text(localizations.reps)),
                            ),
                            DataColumn(
                              numeric: false,
                              tooltip: preferences.selectedUnit,
                              label:
                                  Center(child: Text(preferences.selectedUnit)),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            sets.length,
                            (index) {
                              final setName =
                                  sets[index].key.replaceAll('Série ', '');
                              final percentage = sets[index].value;
                              final initialWeight =
                                  (oneRM * (percentage / 100)).ceilToDouble();
                              final isCompleted = _isCompleted[index] ?? false;
                              final reps = _reps[index] ?? repsForWeek[index];
                              final weight = _weights[index] ?? initialWeight;
                              
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                          value: isCompleted,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _isCompleted[index] =
                                                  value ?? false;
                                              if (value == true) {
                                                _startSetTimer();
                                              }
                                            });
                                          },
                                        ),
                                        Text(setName),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          iconSize: 16.0,
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              _reps[index] =
                                                  (reps > 0) ? reps - 1 : 0;
                                            });
                                          },
                                        ),
                                        Text('$reps'),
                                        IconButton(
                                          iconSize: 16.0,
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              _reps[index] = reps + 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onLongPress: () {
                                            _showWeightDialog(index, weight, localizations);
                                          },
                                          child: IconButton(
                                            iconSize: 16.0,
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                              setState(() {
                                                _weights[index] = (weight > 0)
                                                    ? weight - 1
                                                    : 0;
                                              });
                                            },
                                          ),
                                        ),
                                        GestureDetector(
                                          onLongPress: () {
                                            _showWeightDialog(index, weight, localizations);
                                          },
                                          child: Text('$weight'),
                                        ),
                                        GestureDetector(
                                          onLongPress: () {
                                            _showWeightDialog(index, weight, localizations);
                                          },
                                          child: IconButton(
                                            iconSize: 16.0,
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              setState(() {
                                                _weights[index] = weight + 1;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _allSetsCompleted()
                    ? () => _saveData(
                        week,
                        cycleWeekData['cycle'] ?? 1,
                        oneRM,
                        widget.exercise,
                        sets,
                        (workout) => ref
                            .read(workoutProvider.notifier)
                            .addWorkout(workout),
                        (exercise, cycle, week) => ref
                            .read(preferencesProvider.notifier)
                            .updateCycleAndWeek(exercise, cycle, week),
                        (exercise, oneRM) => ref
                            .read(preferencesProvider.notifier)
                            .updateOneRM(exercise, oneRM))
                    : null,
                child: Text(localizations.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
