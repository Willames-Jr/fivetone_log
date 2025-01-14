import 'package:flutter/material.dart';

class DefaultOptionButton extends StatelessWidget {
  final String labelText;
  final String selectedValue; // Valor selecionado (kg ou lbs)
  final List<String> options; // Lista de opções ('kg', 'lbs')
  final void Function(String) onChanged; // Função callback para quando o valor mudar

  const DefaultOptionButton({
    Key? key,
    required this.labelText,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue, // Passa o valor atual selecionado
      items: options
          .map((unit) => DropdownMenuItem(
                value: unit,
                child: Text(unit),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value); // Chama a função de callback quando o valor mudar
        }
      },
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }
}
