import 'package:flutter/material.dart';
import 'package:poc_uber/config/theme/app_colors.dart';
import 'package:poc_uber/shared/widgets/card_widget.dart';

/// Carte de résumé d'une transaction (liste du wallet). `isCredit` pilote
/// la couleur et le signe du montant déjà formaté — même règle que
/// `DeliveryCard`/`WalletCard` (paramètres génériques, pas d'entité).
class TransactionCard extends StatelessWidget {
  const TransactionCard({
    required this.description,
    required this.amountLabel,
    required this.dateLabel,
    required this.isCredit,
    this.onTap,
    super.key,
  });

  final String description;
  final String amountLabel;
  final String dateLabel;
  final bool isCredit;
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
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(dateLabel, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            amountLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
