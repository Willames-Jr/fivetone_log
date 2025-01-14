import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fivethreeone_log/app/interactor/models/workout_model.dart';
import 'package:fivethreeone_log/app/interactor/models/set_model.dart';
import 'package:fivethreeone_log/app/interactor/providers/preferences_provider.dart';
import 'package:fivethreeone_log/app/interactor/providers/workout_provider.dart';
import 'package:fivethreeone_log/app/utils/utils.dart';

class EditWorkoutPage extends ConsumerStatefulWidget {
  final WorkoutModel workout;

  const EditWorkoutPage({super.key, required this.workout});

  @override
  _EditWorkoutPageState createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends ConsumerState<EditWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  late WorkoutModel _editableWorkout;
  final Map<int, double> _weights = {};
  late TextEditingController _notesController;
  late List<TextEditingController> _repsControllers;
  late List<TextEditingController> _weightsControllers;
  final Map<int, int> _reps = {};

  void _showWeightDialog(int index, double currentWeight) {
    final TextEditingController controller =
        TextEditingController(text: currentWeight.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Weight'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter weight"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  _weightsControllers[index].text =
                      double.tryParse(controller.text)?.toString() ?? currentWeight.toString();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _editableWorkout = widget.workout.copyWith(); // Create a copy of the workout
    _notesController = TextEditingController(text: _editableWorkout.notes);
    _repsControllers = _editableWorkout.sets
        .map((set) => TextEditingController(text: set.reps.toString()))
        .toList();
    _weightsControllers = _editableWorkout.sets
        .map((set) => TextEditingController(text: set.weight.toString()))
        .toList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    for (var controller in _weightsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      final updatedSets = List<SetModel>.generate(
        _editableWorkout.sets.length,
        (index) => SetModel(
          setNumber: index + 1,
          reps: int.tryParse(_repsControllers[index].text) ?? 0,
          weight: double.tryParse(_weightsControllers[index].text) ?? 0.0,
        ),
      );

      final lastSet = updatedSets.last;
      final calculated1RM = calculate1RM(lastSet.weight, lastSet.reps);
      final totalVolume = updatedSets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));

      final updatedWorkout = _editableWorkout.copyWith(
        sets: updatedSets,
        notes: _notesController.text,
        oneRM: calculated1RM,
        volume: totalVolume,
      );

      ref.read(workoutProvider.notifier).updateWorkout(updatedWorkout);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);
    final oneRM = preferences.rmData[_editableWorkout.exerciseName] ?? 0.0;
    final percData = preferences.percData;
    final cycleWeekData = preferences.cycleWeekData[_editableWorkout.exerciseName] ?? {'cycle': 1, 'week': 1};

    final week = cycleWeekData['week']!;
    final sets = percData['Semana $week']?.entries.toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ExpansionTile(
                      title: const Text('Main Lift'),
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 10.0,
                            columns: [
                              DataColumn(
                                numeric: false,
                                tooltip: 'Set',
                                onSort: (columnIndex, ascending) {},
                                label: Center(child: Text('Set')),
                              ),
                              DataColumn(
                                numeric: false,
                                tooltip: 'Reps',
                                onSort: (columnIndex, ascending) {},
                                label: Center(child: Text('Reps')),
                              ),
                              DataColumn(
                                numeric: false,
                                tooltip: preferences.selectedUnit,
                                label: Center(child: Text(preferences.selectedUnit)),
                              ),
                            ],
                            rows: List<DataRow>.generate(
                              sets.length,
                              (index) {
                                final setName = sets[index].key.replaceAll('Série ', '');
                                final percentage = sets[index].value;
                                final initialWeight = (oneRM * (percentage / 100)).ceilToDouble();

                                final reps = int.tryParse(_repsControllers[index].text) ?? 0;
                                final weight = double.tryParse(_weightsControllers[index].text) ?? initialWeight;

                                return DataRow(
                                  cells: [
                                    DataCell(Center(child: Text(setName))),
                                    DataCell(
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            iconSize: 16.0,
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              setState(() {
                                                _repsControllers[index].text = (reps > 0 ? reps - 1 : 0).toString();
                                              });
                                            },
                                          ),
                                          Text('$reps'),
                                          IconButton(
                                            iconSize: 16.0,
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              setState(() {
                                                _repsControllers[index].text = (reps + 1).toString();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onLongPress: () {
                                              _showWeightDialog(index, weight);
                                            },
                                            child: IconButton(
                                              iconSize: 16.0,
                                              icon: Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  _weightsControllers[index].text = (weight > 0 ? weight - 1 : 0).toString();
                                                });
                                              },
                                            ),
                                          ),
                                          GestureDetector(
                                            onLongPress: () {
                                              _showWeightDialog(index, weight);
                                            },
                                            child: Text('$weight'),
                                          ),
                                          GestureDetector(
                                            onLongPress: () {
                                              _showWeightDialog(index, weight);
                                            },
                                            child: IconButton(
                                              iconSize: 16.0,
                                              icon: Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  _weightsControllers[index].text = (weight + 1).toString();
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
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveWorkout,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
