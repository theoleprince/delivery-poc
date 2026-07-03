import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:poc_uber/features/delivery/presentation/utils/delivery_status_label.dart';
import 'package:poc_uber/shared/widgets/app_error_widget.dart';
import 'package:poc_uber/shared/widgets/card_widget.dart';
import 'package:poc_uber/shared/widgets/loading_widget.dart';
import 'package:poc_uber/shared/widgets/map_widget.dart' as widgets;
import 'package:poc_uber/shared/widgets/primary_button.dart';

/// Détail complet d'une livraison : statut, carte (avec position du
/// livreur si le suivi a démarré), destinataire, colis. Timeline limitée à
/// "Créée le ..." — le cycle de vie complet des statuts est piloté par
/// `tracking` (voir `TrackingPage`).
class DeliveryDetailPage extends ConsumerWidget {
  const DeliveryDetailPage({required this.deliveryId, super.key});

  final String deliveryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DeliveryEntity?> delivery = ref.watch(
      deliveryByIdProvider(deliveryId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la livraison')),
      body: delivery.when(
        data: (DeliveryEntity? entity) {
          if (entity == null) {
            return const AppErrorWidget(message: 'Livraison introuvable.');
          }
          return _DeliveryDetailBody(delivery: entity);
        },
        loading: () => const LoadingWidget(),
        error: (Object error, StackTrace stackTrace) =>
            AppErrorWidget(message: error.toString()),
      ),
    );
  }
}

class _DeliveryDetailBody extends StatelessWidget {
  const _DeliveryDetailBody({required this.delivery});

  final DeliveryEntity delivery;

  @override
  Widget build(BuildContext context) {
    final widgets.LatLng pickupPoint = widgets.LatLng(
      latitude: delivery.pickup.coordinates.latitude,
      longitude: delivery.pickup.coordinates.longitude,
    );
    final widgets.LatLng destinationPoint = widgets.LatLng(
      latitude: delivery.destination.coordinates.latitude,
      longitude: delivery.destination.coordinates.longitude,
    );

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: <Widget>[
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: widgets.MapWidget(
              initialCenter: pickupPoint,
              markers: <widgets.MapMarkerData>[
                widgets.MapMarkerData(id: 'pickup', position: pickupPoint),
                widgets.MapMarkerData(
                  id: 'destination',
                  position: destinationPoint,
                ),
                if (delivery.courierPosition != null)
                  widgets.MapMarkerData(
                    id: 'courier',
                    position: widgets.LatLng(
                      latitude: delivery.courierPosition!.latitude,
                      longitude: delivery.courierPosition!.longitude,
                    ),
                  ),
              ],
              routePoints: <widgets.LatLng>[pickupPoint, destinationPoint],
            ),
          ),
        ),
        const SizedBox(height: Spacing.md),
        CardWidget(
          title: 'Statut',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(deliveryStatusLabel(delivery.status)),
              if (delivery.createdAt != null) ...<Widget>[
                const SizedBox(height: Spacing.xs),
                Text(
                  'Créée le '
                  '${DateFormat('dd/MM/yyyy à HH:mm').format(delivery.createdAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: Spacing.sm),
              PrimaryButton(
                label: delivery.status == DeliveryStatus.delivered
                    ? 'Livraison terminée'
                    : 'Suivre en temps réel',
                onPressed: delivery.status == DeliveryStatus.delivered
                    ? null
                    : () => context.push(
                        AppRoutes.deliveryTracking(delivery.id!),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        CardWidget(
          title: 'Trajet',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Départ : ${delivery.pickup.formattedAddress}'),
              Text('Destination : ${delivery.destination.formattedAddress}'),
              Text(
                'Distance : ${(delivery.distanceMeters / 1000).toStringAsFixed(1)} km',
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
              Text(delivery.package.name),
              Text(delivery.package.description),
              Text('${delivery.package.weightKg} kg'),
              if (delivery.package.specialInstructions != null)
                Text(delivery.package.specialInstructions!),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        CardWidget(
          title: 'Destinataire',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(delivery.recipient.name),
              Text(delivery.recipient.phone),
              Text(delivery.recipient.address),
              if (delivery.recipient.instructions != null)
                Text(delivery.recipient.instructions!),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        CardWidget(
          title: 'Estimation',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Prix : ${delivery.estimatedPrice.toStringAsFixed(2)} €'),
              Text('Durée : ${delivery.estimatedDurationMinutes} min'),
            ],
          ),
        ),
      ],
    );
  }
}
