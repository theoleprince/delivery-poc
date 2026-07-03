import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/auth/presentation/providers/auth_providers.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:poc_uber/features/delivery/presentation/utils/delivery_status_label.dart';
import 'package:poc_uber/shared/widgets/app_error_widget.dart';
import 'package:poc_uber/shared/widgets/delivery_card.dart';
import 'package:poc_uber/shared/widgets/empty_state.dart';
import 'package:poc_uber/shared/widgets/loading_widget.dart';
import 'package:poc_uber/shared/widgets/search_field.dart';

String _typeLabel(DeliveryType type) {
  switch (type) {
    case DeliveryType.standard:
      return 'Standard';
    case DeliveryType.express:
      return 'Express';
  }
}

/// Liste des livraisons de l'utilisateur courant, avec filtre par type et
/// recherche texte. La recherche est un filtrage côté client sur les
/// résultats déjà chargés (pas de recherche plein texte côté serveur —
/// hors scope d'un POC Firestore, voir ARCHITECTURE.md).
class DeliveryHistoryPage extends HookConsumerWidget {
  const DeliveryHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<String> query = useState('');
    final ValueNotifier<DeliveryType?> typeFilter = useState<DeliveryType?>(
      null,
    );

    final String? senderId = ref.watch(authStateProvider).valueOrNull?.uid;
    if (senderId == null) {
      return const Scaffold(body: LoadingWidget());
    }

    final AsyncValue<List<DeliveryEntity>> deliveries = ref.watch(
      userDeliveriesProvider(senderId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des livraisons')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: SearchField(
              hintText: 'Rechercher un destinataire ou une adresse',
              onChanged: (String value) => query.value = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Row(
              children: <Widget>[
                ChoiceChip(
                  label: const Text('Tous'),
                  selected: typeFilter.value == null,
                  onSelected: (_) => typeFilter.value = null,
                ),
                const SizedBox(width: Spacing.sm),
                ChoiceChip(
                  label: const Text('Standard'),
                  selected: typeFilter.value == DeliveryType.standard,
                  onSelected: (_) => typeFilter.value = DeliveryType.standard,
                ),
                const SizedBox(width: Spacing.sm),
                ChoiceChip(
                  label: const Text('Express'),
                  selected: typeFilter.value == DeliveryType.express,
                  onSelected: (_) => typeFilter.value = DeliveryType.express,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Expanded(
            child: deliveries.when(
              data: (List<DeliveryEntity> all) {
                final String normalizedQuery = query.value.trim().toLowerCase();
                final List<DeliveryEntity> filtered = all.where((
                  DeliveryEntity delivery,
                ) {
                  final bool matchesType =
                      typeFilter.value == null ||
                      delivery.deliveryType == typeFilter.value;
                  final bool matchesQuery =
                      normalizedQuery.isEmpty ||
                      delivery.recipient.name.toLowerCase().contains(
                        normalizedQuery,
                      ) ||
                      delivery.destination.formattedAddress
                          .toLowerCase()
                          .contains(normalizedQuery);
                  return matchesType && matchesQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.local_shipping_outlined,
                    message: 'Aucune livraison pour l’instant',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(Spacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: Spacing.sm),
                  itemBuilder: (BuildContext context, int index) {
                    final DeliveryEntity delivery = filtered[index];
                    return DeliveryCard(
                      destination: delivery.destination.formattedAddress,
                      recipientName: delivery.recipient.name,
                      statusLabel:
                          '${deliveryStatusLabel(delivery.status)} · ${_typeLabel(delivery.deliveryType)}',
                      priceLabel:
                          '${delivery.estimatedPrice.toStringAsFixed(2)} €',
                      onTap: () => context.push(
                        AppRoutes.deliveryDetail(delivery.id!),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (Object error, StackTrace stackTrace) =>
                  AppErrorWidget(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
