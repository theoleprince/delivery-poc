import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/app_colors.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/auth/presentation/providers/auth_providers.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/services/delivery_pricing.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_draft_provider.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/entities/wallet_entity.dart';
import 'package:poc_uber/features/wallet/domain/usecases/create_transaction_usecase.dart';
import 'package:poc_uber/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:poc_uber/shared/widgets/card_widget.dart';
import 'package:poc_uber/shared/widgets/primary_button.dart';

/// Étape 4 (finale) du flux de création : récapitulatif complet, choix du
/// type de livraison et du mode de paiement (simulé — voir `CLAUDE.md`
/// "Paiement : simulation uniquement"), puis confirmation.
class DeliverySummaryPage extends ConsumerWidget {
  const DeliverySummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeliveryDraft draft = ref.watch(deliveryDraftControllerProvider);
    final DeliveryDraftController draftController = ref.read(
      deliveryDraftControllerProvider.notifier,
    );

    if (!draft.isComplete) {
      return const Scaffold(
        body: Center(child: Text('Étapes précédentes incomplètes.')),
      );
    }

    final DeliveryEstimate estimate = DeliveryPricing.estimate(
      distanceMeters: draft.route!.distanceMeters,
      deliveryType: draft.deliveryType,
    );

    final String? senderId = ref.watch(authStateProvider).valueOrNull?.uid;
    final bool paysBeforeDelivery =
        draft.paymentMethod == PaymentMethod.beforeDelivery;
    final AsyncValue<WalletEntity?> walletState =
        senderId == null || !paysBeforeDelivery
        ? const AsyncValue<WalletEntity?>.data(null)
        : ref.watch(walletProvider(senderId));
    final double? availableBalance = walletState.valueOrNull?.balance;
    final bool hasInsufficientBalance =
        paysBeforeDelivery &&
        availableBalance != null &&
        availableBalance < estimate.price;

    ref.listen<AsyncValue<DeliveryEntity?>>(createDeliveryControllerProvider, (
      AsyncValue<DeliveryEntity?>? previous,
      AsyncValue<DeliveryEntity?> next,
    ) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
        return;
      }
      final DeliveryEntity? created = next.valueOrNull;
      if (created == null) return;

      // Débite le wallet séparément de la création de la livraison (voir
      // ARCHITECTURE.md §10.3) : la vérification de solde avant confirmation
      // rend ce débit quasi certain de réussir, mais un échec ici (rare)
      // laisse la livraison créée sans compensation automatique — limitation
      // assumée pour ce POC (pas de saga/transaction distribuée).
      if (created.paymentMethod == PaymentMethod.beforeDelivery) {
        unawaited(
          ref
              .read(createTransactionUseCaseProvider)
              .call(
                CreateTransactionParams(
                  uid: created.senderId,
                  type: TransactionType.debit,
                  amount: created.estimatedPrice,
                  description:
                      'Livraison vers ${created.destination.formattedAddress}',
                  relatedDeliveryId: created.id,
                ),
              ),
        );
      }

      draftController.reset();
      context.go(AppRoutes.home);
    });

    final AsyncValue<DeliveryEntity?> createState = ref.watch(
      createDeliveryControllerProvider,
    );

    void confirm() {
      if (senderId == null) return;

      if (hasInsufficientBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Solde insuffisant pour payer avant livraison. Choisis "À la livraison" ou recharge ton wallet.',
            ),
          ),
        );
        return;
      }

      final DeliveryEntity delivery = draft.toEntity(
        senderId: senderId,
        estimatedPrice: estimate.price,
        estimatedDurationMinutes: estimate.durationMinutes,
      );

      ref.read(createDeliveryControllerProvider.notifier).submit(delivery);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Récapitulatif')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: <Widget>[
          CardWidget(
            title: 'Trajet',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Départ : ${draft.pickup!.formattedAddress}'),
                Text('Destination : ${draft.destination!.formattedAddress}'),
                Text(
                  'Distance : ${(draft.route!.distanceMeters / 1000).toStringAsFixed(1)} km',
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          CardWidget(
            title: 'Colis',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(draft.package!.name),
                Text(draft.package!.description),
                Text('${draft.package!.weightKg} kg'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          CardWidget(
            title: 'Destinataire',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(draft.recipient!.name),
                Text(draft.recipient!.phone),
                Text(draft.recipient!.address),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          CardWidget(
            title: 'Type de livraison',
            child: SegmentedButton<DeliveryType>(
              segments: const <ButtonSegment<DeliveryType>>[
                ButtonSegment<DeliveryType>(
                  value: DeliveryType.standard,
                  label: Text('Standard'),
                ),
                ButtonSegment<DeliveryType>(
                  value: DeliveryType.express,
                  label: Text('Express'),
                ),
              ],
              selected: <DeliveryType>{draft.deliveryType},
              onSelectionChanged: (Set<DeliveryType> selection) =>
                  draftController.setDeliveryType(selection.first),
            ),
          ),
          const SizedBox(height: Spacing.md),
          CardWidget(
            title: 'Mode de paiement',
            child: SegmentedButton<PaymentMethod>(
              segments: const <ButtonSegment<PaymentMethod>>[
                ButtonSegment<PaymentMethod>(
                  value: PaymentMethod.beforeDelivery,
                  label: Text('Avant livraison'),
                ),
                ButtonSegment<PaymentMethod>(
                  value: PaymentMethod.onDelivery,
                  label: Text('À la livraison'),
                ),
              ],
              selected: <PaymentMethod>{draft.paymentMethod},
              onSelectionChanged: (Set<PaymentMethod> selection) =>
                  draftController.setPaymentMethod(selection.first),
            ),
          ),
          if (paysBeforeDelivery) ...<Widget>[
            const SizedBox(height: Spacing.sm),
            Text(
              availableBalance == null
                  ? 'Chargement du solde...'
                  : 'Solde disponible : ${availableBalance.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hasInsufficientBalance ? AppColors.error : null,
              ),
            ),
          ],
          const SizedBox(height: Spacing.md),
          CardWidget(
            title: 'Estimation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Prix estimé : ${estimate.price.toStringAsFixed(2)} €'),
                Text('Durée estimée : ${estimate.durationMinutes} min'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          PrimaryButton(
            label: 'Confirmer la livraison',
            isLoading: createState.isLoading,
            onPressed: hasInsufficientBalance ? null : confirm,
          ),
        ],
      ),
    );
  }
}
