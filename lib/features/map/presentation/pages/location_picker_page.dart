import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';
import 'package:poc_uber/features/map/domain/usecases/reverse_geocode_usecase.dart';
import 'package:poc_uber/features/map/presentation/providers/location_providers.dart';
import 'package:poc_uber/shared/widgets/loading_widget.dart';
import 'package:poc_uber/shared/widgets/map_widget.dart' as widgets;
import 'package:poc_uber/shared/widgets/primary_button.dart';
import 'package:poc_uber/shared/widgets/search_field.dart';

/// Écran de sélection d'un point (recherche d'adresse ou tap sur la carte).
/// Renvoie une [AddressEntity] via `Navigator.pop`. Réutilisé par
/// `delivery` pour choisir le départ puis la destination — aucun état n'est
/// conservé dans un provider global (voir `location_providers.dart`).
class LocationPickerPage extends HookConsumerWidget {
  const LocationPickerPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<AddressEntity?> selected =
        useState<AddressEntity?>(null);
    final ValueNotifier<widgets.LatLng> center = useState(
      const widgets.LatLng(latitude: 48.8566, longitude: 2.3522),
    );
    final searchController = useTextEditingController();

    useEffect(() {
      Future<void> loadCurrentPosition() async {
        final result = await ref
            .read(getCurrentPositionUseCaseProvider)
            .call(const NoParams());
        result.when(
          success: (CoordinatesEntity coordinates) {
            center.value = widgets.LatLng(
              latitude: coordinates.latitude,
              longitude: coordinates.longitude,
            );
          },
          failure: (_) {},
        );
      }

      loadCurrentPosition();
      return null;
    }, const <Object?>[]);

    Future<void> onMapTap(widgets.LatLng point) async {
      final CoordinatesEntity coordinates = CoordinatesEntity(
        latitude: point.latitude,
        longitude: point.longitude,
      );
      final result = await ref
          .read(reverseGeocodeUseCaseProvider)
          .call(ReverseGeocodeParams(coordinates: coordinates));
      result.when(
        success: (AddressEntity address) => selected.value = address,
        failure: (_) => selected.value = AddressEntity(
          formattedAddress:
              '${coordinates.latitude.toStringAsFixed(5)}, '
              '${coordinates.longitude.toStringAsFixed(5)}',
          coordinates: coordinates,
        ),
      );
    }

    final AsyncValue<List<AddressEntity>> searchResults = ref.watch(
      addressSearchControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: SearchField(
              hintText: 'Rechercher une adresse',
              controller: searchController,
              onSubmitted: (String query) => ref
                  .read(addressSearchControllerProvider.notifier)
                  .search(query),
            ),
          ),
          searchResults.when(
            data: (List<AddressEntity> addresses) => Column(
              children: addresses
                  .map(
                    (AddressEntity address) => ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(address.formattedAddress),
                      onTap: () {
                        selected.value = address;
                        center.value = widgets.LatLng(
                          latitude: address.coordinates.latitude,
                          longitude: address.coordinates.longitude,
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(Spacing.sm),
              child: LoadingWidget(),
            ),
            error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
          ),
          Expanded(
            child: widgets.MapWidget(
              initialCenter: center.value,
              markers: selected.value == null
                  ? const <widgets.MapMarkerData>[]
                  : <widgets.MapMarkerData>[
                      widgets.MapMarkerData(
                        id: 'selected',
                        position: widgets.LatLng(
                          latitude: selected.value!.coordinates.latitude,
                          longitude: selected.value!.coordinates.longitude,
                        ),
                      ),
                    ],
              onTap: onMapTap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              children: <Widget>[
                Text(
                  selected.value?.formattedAddress ??
                      'Recherche une adresse ou touche la carte',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.sm),
                PrimaryButton(
                  label: 'Confirmer',
                  onPressed: selected.value == null
                      ? null
                      : () => Navigator.of(context).pop(selected.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
