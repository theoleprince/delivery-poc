import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/auth/presentation/providers/auth_providers.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/services/delivery_pricing.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_draft_provider.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_providers.dart';
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
      if (created != null) {
        draftController.reset();
        context.go(AppRoutes.home);
      }
    });

    final AsyncValue<DeliveryEntity?> createState = ref.watch(
      createDeliveryControllerProvider,
    );

    void confirm() {
      final String? senderId = ref.read(authStateProvider).valueOrNull?.uid;
      if (senderId == null) return;

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
            onPressed: confirm,
          ),
        ],
      ),
    );
  }
}
