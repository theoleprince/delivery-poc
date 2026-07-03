import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';

/// Encapsule `Geolocator` (position/permissions) et `geocoding`
/// (recherche/reverse geocoding).
///
/// Contrairement à `AuthRemoteDataSource`, ce datasource retourne
/// directement des entités `domain` plutôt qu'un DTO `data/models` : il n'y
/// a ici aucune sérialisation JSON/Firestore à isoler du domaine (voir
/// ARCHITECTURE.md §4.6 — la séparation Entity/Model existe pour découpler
/// un schéma de persistance du domaine, absent ici), donc introduire un
/// modèle supplémentaire serait une couche sans bénéfice réel.
///
/// Ne traduit pas les erreurs (permissions refusées, service désactivé,
/// adresse introuvable) : laisse les exceptions se propager,
/// `LocationRepositoryImpl` les convertit en `Failure`.
abstract interface class LocationRemoteDataSource {
  Future<CoordinatesEntity> getCurrentPosition();

  Future<List<AddressEntity>> searchAddress(String query);

  Future<AddressEntity> reverseGeocode(CoordinatesEntity coordinates);

  double distanceBetween(CoordinatesEntity origin, CoordinatesEntity destination);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  const LocationRemoteDataSourceImpl();

  @override
  Future<CoordinatesEntity> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException(
        'Permission de localisation refusée.',
      );
    }

    final Position position = await Geolocator.getCurrentPosition();
    return CoordinatesEntity(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Future<List<AddressEntity>> searchAddress(String query) async {
    // Le package `geocoding` est un géocodeur simple (pas d'autocomplete à
    // suggestions multiples classées comme une Places API). On renvoie le
    // meilleur résultat sous forme de liste à 1 élément, pour rester
    // compatible avec un futur fournisseur de géocodage plus riche —
    // voir API_DOCUMENTATION.md.
    final List<geocoding.Location> locations = await geocoding
        .locationFromAddress(query);
    if (locations.isEmpty) return const <AddressEntity>[];

    final geocoding.Location best = locations.first;
    final AddressEntity address = await reverseGeocode(
      CoordinatesEntity(latitude: best.latitude, longitude: best.longitude),
    );
    return <AddressEntity>[address];
  }

  @override
  Future<AddressEntity> reverseGeocode(CoordinatesEntity coordinates) async {
    final List<geocoding.Placemark> placemarks = await geocoding
        .placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
    final String formatted = placemarks.isEmpty
        ? '${coordinates.latitude}, ${coordinates.longitude}'
        : _formatPlacemark(placemarks.first);
    return AddressEntity(formattedAddress: formatted, coordinates: coordinates);
  }

  @override
  double distanceBetween(
    CoordinatesEntity origin,
    CoordinatesEntity destination,
  ) {
    return Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
  }

  String _formatPlacemark(geocoding.Placemark placemark) {
    final List<String> parts = <String>[
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.postalCode,
      placemark.country,
    ].whereType<String>().where((String part) => part.trim().isNotEmpty).toList();
    return parts.join(', ');
  }
}

class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
}

class PermissionDeniedException implements Exception {
  const PermissionDeniedException(this.message);

  final String message;
}
