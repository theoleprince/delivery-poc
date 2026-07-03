import 'package:flutter/material.dart';

/// Bouton d'action secondaire du Design System (actions non prioritaires,
/// annulation, navigation retour textuelle).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
