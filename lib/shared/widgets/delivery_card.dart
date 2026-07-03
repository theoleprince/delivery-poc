import 'package:flutter/material.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/shared/widgets/card_widget.dart';

/// Carte de résumé d'une livraison, utilisée dans l'historique. Paramètres
/// génériques (strings déjà formatées) plutôt qu'une `DeliveryEntity` :
/// `shared/` ne dépend jamais d'une feature (voir ARCHITECTURE.md §3) —
/// c'est à `features/delivery/presentation` de mapper son entité vers ces
/// champs, comme pour `MapWidget`/`LatLng`.
class DeliveryCard extends StatelessWidget {
  const DeliveryCard({
    required this.destination,
    required this.recipientName,
    required this.statusLabel,
    required this.priceLabel,
    this.onTap,
    super.key,
  });

  final String destination;
  final String recipientName;
  final String statusLabel;
  final String priceLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  destination,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  recipientName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(priceLabel, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
