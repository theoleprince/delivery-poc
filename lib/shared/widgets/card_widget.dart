import 'package:flutter/material.dart';
import 'package:poc_uber/config/theme/spacing.dart';

/// Carte générique du Design System (ex. sections du récapitulatif de
/// livraison). S'appuie sur `CardTheme` (voir `AppTheme`) pour la couleur
/// et l'élévation — ne jamais redéfinir un `Card` ad hoc dans une feature.
class CardWidget extends StatelessWidget {
  const CardWidget({required this.child, this.title, this.onTap, super.key});

  final Widget child;
  final String? title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(title!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Spacing.sm),
          ],
          child,
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
