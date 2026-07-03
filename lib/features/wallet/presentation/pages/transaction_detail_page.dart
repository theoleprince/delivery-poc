import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:poc_uber/shared/widgets/app_error_widget.dart';
import 'package:poc_uber/shared/widgets/card_widget.dart';
import 'package:poc_uber/shared/widgets/loading_widget.dart';
import 'package:poc_uber/shared/widgets/secondary_button.dart';

class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({required this.transactionId, super.key});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TransactionEntity?> transaction = ref.watch(
      transactionByIdProvider(transactionId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la transaction')),
      body: transaction.when(
        data: (TransactionEntity? entity) {
          if (entity == null) {
            return const AppErrorWidget(message: 'Transaction introuvable.');
          }
          final bool isCredit = entity.type == TransactionType.credit;
          return Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: CardWidget(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${isCredit ? '+' : '-'}${entity.amount.toStringAsFixed(2)} €',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(entity.description),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    isCredit ? 'Crédit' : 'Débit',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (entity.createdAt != null) ...<Widget>[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy à HH:mm',
                      ).format(entity.createdAt!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (entity.relatedDeliveryId != null) ...<Widget>[
                    const SizedBox(height: Spacing.md),
                    SecondaryButton(
                      label: 'Voir la livraison associée',
                      onPressed: () => context.push(
                        AppRoutes.deliveryDetail(entity.relatedDeliveryId!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (Object error, StackTrace stackTrace) =>
            AppErrorWidget(message: error.toString()),
      ),
    );
  }
}
