import 'package:flutter/material.dart';

/// Champ de saisie standard du Design System.
class InputField extends StatelessWidget {
  const InputField({
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.errorText,
    this.autofillHints,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? errorText;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autofillHints: autofillHints,
      decoration: InputDecoration(labelText: label, errorText: errorText),
    );
  }
}
