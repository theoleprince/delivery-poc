import 'package:flutter/material.dart';
import 'package:poc_uber/config/theme/spacing.dart';

/// Bouton d'action principal du Design System. Ne jamais recréer un
/// `ElevatedButton` ad hoc dans une feature — étendre ce widget si un
/// nouveau besoin apparaît.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: Spacing.md,
              width: Spacing.md,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
