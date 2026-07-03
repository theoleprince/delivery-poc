import 'package:flutter/material.dart';
import 'package:poc_uber/config/theme/app_colors.dart';
import 'package:poc_uber/shared/widgets/card_widget.dart';

/// Carte de solde du Design System. Paramètre déjà formaté (`balanceLabel`)
/// plutôt qu'une `WalletEntity` — même règle que `DeliveryCard`/`MapWidget`
/// (voir ARCHITECTURE.md §3, §8.1, §9.3).
class WalletCard extends StatelessWidget {
  const WalletCard({required this.balanceLabel, super.key});

  final String balanceLabel;

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      title: 'Solde disponible',
      child: Text(
        balanceLabel,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
