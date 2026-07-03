import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_draft_provider.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/usecases/get_route_usecase.dart';
import 'package:poc_uber/features/map/presentation/pages/location_picker_page.dart';
import 'package:poc_uber/features/map/presentation/providers/location_providers.dart';
import 'package:poc_uber/shared/widgets/card_widget.dart';
import 'package:poc_uber/shared/widgets/primary_button.dart';
import 'package:poc_uber/shared/widgets/secondary_button.dart';

/// Étape 1 du flux de création : choix du point de départ et de la
/// destination (via `LocationPickerPage`, poussée avec le `Navigator`
/// standard plutôt qu'une route GoRouter dédiée — c'est un sous-flux
/// réutilisable, pas une destination profonde de l'app).
class DeliveryRoutePage extends ConsumerWidget {
  const DeliveryRoutePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeliveryDraft draft = ref.watch(deliveryDraftControllerProvider);
    final DeliveryDraftController controller = ref.read(
      deliveryDraftControllerProvider.notifier,
    );

    Future<void> pickPickup() async {
      final AddressEntity? address = await Navigator.of(context)
          .push<AddressEntity>(
            MaterialPageRoute<AddressEntity>(
              builder: (_) => const LocationPickerPage(title: 'Point de départ'),
            ),
          );
      if (address != null) controller.setPickup(address);
    }

    Future<void> pickDestination() async {
      final AddressEntity? address = await Navigator.of(context)
          .push<AddressEntity>(
            MaterialPageRoute<AddressEntity>(
              builder: (_) => const LocationPickerPage(title: 'Destination'),
            ),
          );
      if (address != null) controller.setDestination(address);
    }

    Future<void> next() async {
      if (draft.pickup == null || draft.destination == null) return;
      final result = await ref
          .read(getRouteUseCaseProvider)
          .call(
            GetRouteParams(
              origin: draft.pickup!.coordinates,
              destination: draft.destination!.coordinates,
            ),
          );
      result.when(
        success: (route) {
          controller.setRoute(route);
          context.push(AppRoutes.deliveryPackage);
        },
        failure: (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.toString())));
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trajet de la livraison')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardWidget(
              title: 'Point de départ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(draft.pickup?.formattedAddress ?? 'Non défini'),
                  const SizedBox(height: Spacing.sm),
                  SecondaryButton(label: 'Choisir', onPressed: pickPickup),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
            CardWidget(
              title: 'Destination',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(draft.destination?.formattedAddress ?? 'Non définie'),
                  const SizedBox(height: Spacing.sm),
                  SecondaryButton(label: 'Choisir', onPressed: pickDestination),
                ],
              ),
            ),
            if (draft.route != null) ...<Widget>[
              const SizedBox(height: Spacing.md),
              Text(
                'Distance estimée : '
                '${(draft.route!.distanceMeters / 1000).toStringAsFixed(1)} km',
              ),
            ],
            const SizedBox(height: Spacing.lg),
            PrimaryButton(
              label: 'Suivant',
              onPressed: draft.pickup != null && draft.destination != null
                  ? next
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
