import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';
import 'package:poc_uber/features/map/domain/entities/route_entity.dart';

/// Contrat d'accès à la localisation/géocodage, implémenté par
/// `LocationRepositoryImpl`. Contrat public de la feature `map`,
/// consommable par d'autres features (`delivery`, `tracking`) sans
/// dépendre d'un détail d'implémentation.
abstract interface class LocationRepository {
  Future<Result<CoordinatesEntity>> getCurrentPosition();

  Future<Result<List<AddressEntity>>> searchAddress(String query);

  Future<Result<AddressEntity>> reverseGeocode(CoordinatesEntity coordinates);

  Future<Result<RouteEntity>> getRoute({
    required CoordinatesEntity origin,
    required CoordinatesEntity destination,
  });
}
