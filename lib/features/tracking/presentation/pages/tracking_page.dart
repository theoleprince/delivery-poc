import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:poc_uber/features/delivery/presentation/utils/delivery_status_label.dart';
import 'package:poc_uber/features/tracking/domain/usecases/simulate_delivery_tracking_usecase.dart';
import 'package:poc_uber/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:poc_uber/shared/widgets/app_error_widget.dart';
import 'package:poc_uber/shared/widgets/loading_widget.dart';
import 'package:poc_uber/shared/widgets/map_widget.dart' as widgets;
import 'package:poc_uber/shared/widgets/primary_button.dart';

/// Suivi en temps réel (simulé) d'une livraison. Écoute
/// `deliveryByIdProvider` (contrat public de `delivery`) pour les mises à
/// jour de position/statut, et anime le marqueur du livreur entre deux
/// positions Firestore plutôt que de le faire "sauter" (voir
/// ARCHITECTURE.md §11.3).
class TrackingPage extends HookConsumerWidget {
  const TrackingPage({required this.deliveryId, super.key});

  final String deliveryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DeliveryEntity?> deliveryState = ref.watch(
      deliveryByIdProvider(deliveryId),
    );

    final AnimationController animationController = useAnimationController(
      duration: const Duration(seconds: 2),
    );
    final ValueNotifier<widgets.LatLng?> animationFrom =
        useState<widgets.LatLng?>(null);
    final ValueNotifier<widgets.LatLng?> animationTo =
        useState<widgets.LatLng?>(null);

    ref.listen<AsyncValue<DeliveryEntity?>>(deliveryByIdProvider(deliveryId), (
      AsyncValue<DeliveryEntity?>? previous,
      AsyncValue<DeliveryEntity?> next,
    ) {
      final coordinates = next.valueOrNull?.courierPosition;
      if (coordinates == null) return;
      final widgets.LatLng newTarget = widgets.LatLng(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );
      if (newTarget == animationTo.value) return;
      animationFrom.value = animationTo.value ?? newTarget;
      animationTo.value = newTarget;
      animationController.forward(from: 0);
    });

    final AsyncValue<void> trackState = ref.watch(
      trackDeliveryControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi en temps réel')),
      body: deliveryState.when(
        data: (DeliveryEntity? delivery) {
          if (delivery == null) {
            return const AppErrorWidget(message: 'Livraison introuvable.');
          }

          final widgets.LatLng pickupPoint = widgets.LatLng(
            latitude: delivery.pickup.coordinates.latitude,
            longitude: delivery.pickup.coordinates.longitude,
          );
          final widgets.LatLng destinationPoint = widgets.LatLng(
            latitude: delivery.destination.coordinates.latitude,
            longitude: delivery.destination.coordinates.longitude,
          );

          return Column(
            children: <Widget>[
              Expanded(
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (BuildContext context, Widget? child) {
                    final widgets.LatLng? from = animationFrom.value;
                    final widgets.LatLng? to = animationTo.value;
                    final widgets.LatLng? courierPosition = to == null
                        ? null
                        : from == null
                        ? to
                        : widgets.LatLng.lerp(
                            from,
                            to,
                            animationController.value,
                          );

                    return widgets.MapWidget(
                      initialCenter: pickupPoint,
                      markers: <widgets.MapMarkerData>[
                        widgets.MapMarkerData(
                          id: 'pickup',
                          position: pickupPoint,
                        ),
                        widgets.MapMarkerData(
                          id: 'destination',
                          position: destinationPoint,
                        ),
                        if (courierPosition != null)
                          widgets.MapMarkerData(
                            id: 'courier',
                            position: courierPosition,
                          ),
                      ],
                      routePoints: <widgets.LatLng>[
                        pickupPoint,
                        destinationPoint,
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      deliveryStatusLabel(delivery.status),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Spacing.md),
                    if (delivery.status == DeliveryStatus.pending)
                      PrimaryButton(
                        label: 'Démarrer le suivi (simulation)',
                        isLoading: trackState.isLoading,
                        onPressed: () => ref
                            .read(trackDeliveryControllerProvider.notifier)
                            .start(
                              SimulateDeliveryTrackingParams(
                                deliveryId: delivery.id!,
                                pickup: delivery.pickup.coordinates,
                                destination: delivery.destination.coordinates,
                              ),
                            ),
                      ),
                    if (trackState.hasError) ...<Widget>[
                      const SizedBox(height: Spacing.sm),
                      Text(
                        trackState.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (Object error, StackTrace stackTrace) =>
            AppErrorWidget(message: error.toString()),
      ),
    );
  }
}
