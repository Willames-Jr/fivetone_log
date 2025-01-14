import 'package:flutter/material.dart';
import 'package:fivethreeone_log/app/widgets/forms/initial_form.dart';

class FormPage extends StatelessWidget {
  const FormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea( // Prevent content from touching the status bar
        child: SingleChildScrollView(
          child: InitialForm(),
        ),
      ),
    );
  }
}
