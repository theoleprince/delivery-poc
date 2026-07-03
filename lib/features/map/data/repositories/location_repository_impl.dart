import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/map/data/datasources/location_remote_datasource.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';
import 'package:poc_uber/features/map/domain/entities/route_entity.dart';
import 'package:poc_uber/features/map/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._remoteDataSource);

  final LocationRemoteDataSource _remoteDataSource;

  @override
  Future<Result<CoordinatesEntity>> getCurrentPosition() async {
    try {
      final CoordinatesEntity coordinates = await _remoteDataSource
          .getCurrentPosition();
      return Result.success(coordinates);
    } on LocationServiceDisabledException {
      return const Result.failure(
        Failure.server('Le service de localisation est désactivé.'),
      );
    } on PermissionDeniedException catch (e) {
      return Result.failure(Failure.server(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<List<AddressEntity>>> searchAddress(String query) async {
    try {
      final List<AddressEntity> results = await _remoteDataSource
          .searchAddress(query);
      return Result.success(results);
    } catch (e) {
      return Result.failure(
        Failure.server('Adresse introuvable pour « $query ».'),
      );
    }
  }

  @override
  Future<Result<AddressEntity>> reverseGeocode(
    CoordinatesEntity coordinates,
  ) async {
    try {
      final AddressEntity address = await _remoteDataSource.reverseGeocode(
        coordinates,
      );
      return Result.success(address);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<RouteEntity>> getRoute({
    required CoordinatesEntity origin,
    required CoordinatesEntity destination,
  }) async {
    final double distance = _remoteDataSource.distanceBetween(
      origin,
      destination,
    );
    return Result.success(
      RouteEntity(distanceMeters: distance, points: <CoordinatesEntity>[origin, destination]),
    );
  }
}
