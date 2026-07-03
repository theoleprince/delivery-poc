import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';
import 'package:poc_uber/features/tracking/domain/usecases/simulate_delivery_tracking_usecase.dart';

class _MockDeliveryRepository extends Mock implements DeliveryRepository {}

void main() {
  late _MockDeliveryRepository repository;
  late SimulateDeliveryTrackingUseCase useCase;

  const CoordinatesEntity pickup = CoordinatesEntity(
    latitude: 48.8566,
    longitude: 2.3522,
  );
  const CoordinatesEntity destination = CoordinatesEntity(
    latitude: 45.7640,
    longitude: 4.8357,
  );

  setUp(() {
    repository = _MockDeliveryRepository();
    useCase = SimulateDeliveryTrackingUseCase(
      repository,
      stepInterval: Duration.zero,
    );
    when(
      () => repository.updateTrackingState(
        id: any(named: 'id'),
        status: any(named: 'status'),
        courierPosition: any(named: 'courierPosition'),
      ),
    ).thenAnswer((_) async => const Result<void>.success(null));
  });

  test(
    'passe par pickedUp puis inTransit et termine sur delivered à destination',
    () async {
      final Result<void> result = await useCase(
        const SimulateDeliveryTrackingParams(
          deliveryId: 'delivery-1',
          pickup: pickup,
          destination: destination,
        ),
      );

      expect(result, const Result<void>.success(null));

      verify(
        () => repository.updateTrackingState(
          id: 'delivery-1',
          status: DeliveryStatus.pickedUp,
          courierPosition: pickup,
        ),
      ).called(1);

      verify(
        () => repository.updateTrackingState(
          id: 'delivery-1',
          status: DeliveryStatus.delivered,
          courierPosition: destination,
        ),
      ).called(1);

      // 1 (pickedUp) + 12 (11 inTransit + 1 delivered)
      verify(
        () => repository.updateTrackingState(
          id: any(named: 'id'),
          status: any(named: 'status'),
          courierPosition: any(named: 'courierPosition'),
        ),
      ).called(13);
    },
  );

  test('propage un Failure si une étape échoue', () async {
    when(
      () => repository.updateTrackingState(
        id: any(named: 'id'),
        status: any(named: 'status'),
        courierPosition: any(named: 'courierPosition'),
      ),
    ).thenAnswer(
      (_) async =>
          const Result<void>.failure(Failure.server('Erreur Firestore.')),
    );

    final Result<void> result = await useCase(
      const SimulateDeliveryTrackingParams(
        deliveryId: 'delivery-1',
        pickup: pickup,
        destination: destination,
      ),
    );

    expect(
      result,
      isA<ResultFailure<void>>().having(
        (ResultFailure<void> r) => r.failure,
        'failure',
        isA<ServerFailure>(),
      ),
    );
  });
}
