import 'package:flutter/material.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/shared/widgets/secondary_button.dart';

/// Affichage d'erreur standard du Design System, avec action de
/// nouvelle tentative optionnelle.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: Spacing.xxl,
            ),
            const SizedBox(height: Spacing.sm),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: Spacing.md),
              SecondaryButton(label: 'Réessayer', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
