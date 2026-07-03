import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/map/data/datasources/location_remote_datasource.dart';
import 'package:poc_uber/features/map/data/repositories/location_repository_impl.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';
import 'package:poc_uber/features/map/domain/entities/route_entity.dart';

class _MockLocationRemoteDataSource extends Mock
    implements LocationRemoteDataSource {}

void main() {
  late _MockLocationRemoteDataSource dataSource;
  late LocationRepositoryImpl repository;

  setUp(() {
    dataSource = _MockLocationRemoteDataSource();
    repository = LocationRepositoryImpl(dataSource);
  });

  const CoordinatesEntity origin = CoordinatesEntity(
    latitude: 48.8566,
    longitude: 2.3522,
  );
  const CoordinatesEntity destination = CoordinatesEntity(
    latitude: 45.7640,
    longitude: 4.8357,
  );

  group('getCurrentPosition', () {
    test('mappe PermissionDeniedException en Failure.server', () async {
      when(
        () => dataSource.getCurrentPosition(),
      ).thenThrow(const PermissionDeniedException('refusée'));

      final Result<CoordinatesEntity> result = await repository
          .getCurrentPosition();

      expect(
        result,
        isA<ResultFailure<CoordinatesEntity>>().having(
          (ResultFailure<CoordinatesEntity> r) => r.failure,
          'failure',
          isA<ServerFailure>(),
        ),
      );
    });
  });

  group('getRoute', () {
    test('renvoie une RouteEntity avec la distance du datasource', () async {
      when(
        () => dataSource.distanceBetween(origin, destination),
      ).thenReturn(391000);

      final Result<RouteEntity> result = await repository.getRoute(
        origin: origin,
        destination: destination,
      );

      expect(
        result,
        const Result<RouteEntity>.success(
          RouteEntity(
            distanceMeters: 391000,
            points: <CoordinatesEntity>[origin, destination],
          ),
        ),
      );
    });
  });
}
