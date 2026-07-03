import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';

part 'route_entity.freezed.dart';

/// Trajet entre deux points. Voir ARCHITECTURE.md §8 : `points` est une
/// ligne droite à 2 points (simulation POC), `distanceMeters` est un calcul
/// haversine réel via `Geolocator.distanceBetween`.
@freezed
class RouteEntity with _$RouteEntity {
  const factory RouteEntity({
    required double distanceMeters,
    required List<CoordinatesEntity> points,
  }) = _RouteEntity;
}
