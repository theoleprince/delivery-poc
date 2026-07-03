import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/auth/presentation/providers/auth_providers.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/entities/wallet_entity.dart';
import 'package:poc_uber/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:poc_uber/shared/widgets/app_error_widget.dart';
import 'package:poc_uber/shared/widgets/empty_state.dart';
import 'package:poc_uber/shared/widgets/loading_widget.dart';
import 'package:poc_uber/shared/widgets/transaction_card.dart';
import 'package:poc_uber/shared/widgets/wallet_card.dart';

/// Solde + historique des transactions de l'utilisateur courant. Le wallet
/// est provisionné automatiquement à la connexion (voir `main.dart` et
/// ARCHITECTURE.md §10.1) : cette page ne le crée jamais elle-même.
class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) {
      return const Scaffold(body: LoadingWidget());
    }

    final AsyncValue<WalletEntity?> wallet = ref.watch(walletProvider(uid));
    final AsyncValue<List<TransactionEntity>> transactions = ref.watch(
      walletTransactionsProvider(uid),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mon wallet')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: <Widget>[
          wallet.when(
            data: (WalletEntity? entity) => WalletCard(
              balanceLabel: entity == null
                  ? '—'
                  : '${entity.balance.toStringAsFixed(2)} €',
            ),
            loading: () => const LoadingWidget(),
            error: (Object error, StackTrace stackTrace) =>
                AppErrorWidget(message: error.toString()),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'Transactions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Spacing.sm),
          transactions.when(
            data: (List<TransactionEntity> items) {
              if (items.isEmpty) {
                return const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  message: 'Aucune transaction pour l’instant',
                );
              }
              return Column(
                children: items
                    .map(
                      (TransactionEntity transaction) => Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.sm),
                        child: TransactionCard(
                          description: transaction.description,
                          amountLabel:
                              '${transaction.type == TransactionType.credit ? '+' : '-'}'
                              '${transaction.amount.toStringAsFixed(2)} €',
                          dateLabel: transaction.createdAt == null
                              ? ''
                              : DateFormat(
                                  'dd/MM/yyyy à HH:mm',
                                ).format(transaction.createdAt!),
                          isCredit: transaction.type == TransactionType.credit,
                          onTap: () => context.push(
                            AppRoutes.transactionDetail(transaction.id!),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const LoadingWidget(),
            error: (Object error, StackTrace stackTrace) =>
                AppErrorWidget(message: error.toString()),
          ),
        ],
      ),
    );
  }
}
