import 'package:flutter/material.dart';

class DefaultTextForm extends StatelessWidget {
  final String labelText; // Texto do rótulo do campo
  final TextEditingController? controller; // Para manipulação do texto
  final String? Function(String?)? validator; // Função de validação
  final TextInputType keyboardType; // Tipo de teclado (ex: numérico)
  final bool obscureText; // Para campos de senha
  final void Function(String)? onChanged; // Callback para mudanças no campo

  const DefaultTextForm({
    Key? key,
    required this.labelText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
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
