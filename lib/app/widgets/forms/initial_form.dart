import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routefly/routefly.dart';
import 'package:fivethreeone_log/app/interactor/models/preferences_model.dart';
import 'package:fivethreeone_log/app/interactor/providers/preferences_provider.dart';
import 'package:fivethreeone_log/app/widgets/default_option_button.dart';
import 'package:fivethreeone_log/app/utils/utils.dart'; // Import the utility functions

class InitialForm extends ConsumerStatefulWidget {
  const InitialForm({super.key});

  @override
  InitialFormState createState() => InitialFormState();
}

class InitialFormState extends ConsumerState<InitialForm> {
  final _formKey = GlobalKey<FormState>();
  String selectedUnit = 'Kg'; // Valor selecionado inicialmente
  final List<String> weightUnits = ['lbs', 'Kg'];
  final Map<String, Map<String, double>> _rmData = {
    'Agachamento': {'peso': 0, 'repeticoes': 0},
    'Levantamento terra': {'peso': 0, 'repeticoes': 0},
    'Supino': {'peso': 0, 'repeticoes': 0},
    'Press militar': {'peso': 0, 'repeticoes': 0},
  };
  final Map<String, Map<String, double>> _percData = {
    'Semana 1': {
      'Série 1': 65,
      'Série 2': 75,
      'Série 3': 85,
    },
    'Semana 2': {
      'Série 1': 70,
      'Série 2': 80,
      'Série 3': 90,
    },
    'Semana 3': {
      'Série 1': 75,
      'Série 2': 85,
      'Série 3': 95,
    },
    'Semana 4': {
      'Série 1': 40,
      'Série 2': 50,
      'Série 3': 60,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          children: [
            DefaultOptionButton(
              labelText: 'Unidade de medida',
              selectedValue: selectedUnit,
              options: weightUnits,
              onChanged: (value) {
                setState(() {
                  selectedUnit = value;
                });
                // Você pode adicionar aqui lógica para salvar a seleção
              },
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              maintainState: true,
              title: const Text(
                'Informe o seu 1RM',
              ),
              children: [
                for (var exercise in _rmData.keys)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            exercise,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Center(
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText:
                                            'Peso ($selectedUnit)', // Dynamic unit
                                        border: const OutlineInputBorder(),
                                      ),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(5),
                                      ],
                                      validator: (value) => value!.isEmpty
                                          ? 'Insira um valor'
                                          : null,
                                      onChanged: (value) {
                                        setState(() {
                                          _rmData[exercise]!['peso'] =
                                              double.tryParse(value) ?? 0;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      validator: (value) => value!.isEmpty
                                          ? 'Insira um valor'
                                          : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Repetições',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _rmData[exercise]!['repeticoes'] =
                                              double.tryParse(value) ?? 0;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Center(
                                child: Text(
                                  _rmData[exercise]!['repeticoes']! == 0
                                      ? '1RM: 0.00'
                                      : '1RM: ${calculate1RM(_rmData[exercise]!['peso']!, _rmData[exercise]!['repeticoes']!.toInt()).toStringAsFixed(2)}',
                                ),
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              maintainState: true,
              title: const Text(
                'Ajuste os percentuais',
              ),
              children: [
                for (var week in _percData.keys)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              week,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Center(
                            child: Row(
                              children: [
                                for (var exerciceSet in _percData[week]!.keys)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue:
                                            _percData[week]![exerciceSet]
                                                .toString(),
                                        decoration: InputDecoration(
                                          labelText:
                                              exerciceSet, // Dynamic unit
                                          border: const OutlineInputBorder(),
                                          suffix: const Text(
                                            '%',
                                          ),
                                        ),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(3),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _percData[week]![exerciceSet] =
                                                double.tryParse(value) ?? 0;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () async {
                    print('começando a salvar');
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      print('salvando');
                      
                      print('salvando no provider');
                      // If the form is valid, display a snackbar. In the real world,
                      final Map<String, double> rmData = {
                        for (var exercise in _rmData.keys) 
                          exercise: calculate1RM(_rmData[exercise]!['peso']!, _rmData[exercise]!['repeticoes']!.toInt())
                      };
                      final Map<String, Map<String, int>> cycleWeekData = {
                        for (var exercise in _rmData.keys) exercise: {'cycle': 1, 'week': 1}
                      };
                      await ref.read(preferencesProvider.notifier).setPreferences(PreferencesModel(selectedUnit: selectedUnit, rmData: rmData, percData: _percData, cycleWeekData: cycleWeekData));
                      print('salvo');
                      // Redirect to home page using Routefly
                      Routefly.navigate('/home');
                      print('redirecionar');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Verifique os dados inseridos')),
                      );
                    }
                  },
                  child: const Text('GERAR TREINO'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
