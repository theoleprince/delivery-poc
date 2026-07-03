import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';
import 'package:poc_uber/features/map/domain/repositories/location_repository.dart';
import 'package:poc_uber/features/map/domain/usecases/get_current_position_usecase.dart';

class _MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late _MockLocationRepository repository;
  late GetCurrentPositionUseCase useCase;

  setUp(() {
    repository = _MockLocationRepository();
    useCase = GetCurrentPositionUseCase(repository);
  });

  const CoordinatesEntity coordinates = CoordinatesEntity(
    latitude: 48.8566,
    longitude: 2.3522,
  );

  test('retourne les coordonnées quand le repository réussit', () async {
    when(
      () => repository.getCurrentPosition(),
    ).thenAnswer((_) async => const Result<CoordinatesEntity>.success(coordinates));

    final Result<CoordinatesEntity> result = await useCase(const NoParams());

    expect(result, const Result<CoordinatesEntity>.success(coordinates));
    verify(() => repository.getCurrentPosition()).called(1);
  });
}
