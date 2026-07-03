import 'package:flutter/material.dart';
import 'package:poc_uber/config/theme/spacing.dart';

/// État vide générique du Design System (ex. historique de livraisons sans
/// résultat).
class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, this.icon, super.key});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon ?? Icons.inbox_outlined,
              size: Spacing.xxl,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
