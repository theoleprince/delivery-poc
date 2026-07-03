import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';

class SimulateDeliveryTrackingParams {
  const SimulateDeliveryTrackingParams({
    required this.deliveryId,
    required this.pickup,
    required this.destination,
  });

  final String deliveryId;
  final CoordinatesEntity pickup;
  final CoordinatesEntity destination;
}

/// Simule le déplacement d'un livreur entre le point de départ et la
/// destination, en écrivant périodiquement la position + le statut dans
/// Firestore via le contrat public de `delivery` (`DeliveryRepository`).
///
/// **Piloté côté client** : c'est l'app de l'expéditeur qui fait avancer la
/// simulation pendant qu'elle est ouverte — pas un livreur réel ni un
/// service serveur. Limitation assumée pour ce POC (voir ARCHITECTURE.md
/// §11.1) ; une vraie plateforme utiliserait la position GPS du livreur ou
/// une Cloud Function.
class SimulateDeliveryTrackingUseCase {
  /// `stepInterval` est injectable (défaut 2s) pour permettre aux tests de
  /// faire tourner la simulation sans attendre plusieurs dizaines de
  /// secondes (`Duration.zero`).
  const SimulateDeliveryTrackingUseCase(
    this._deliveryRepository, {
    Duration stepInterval = const Duration(seconds: 2),
  }) : _stepInterval = stepInterval;

  final DeliveryRepository _deliveryRepository;
  final Duration _stepInterval;

  static const int _steps = 12;

  Future<Result<void>> call(SimulateDeliveryTrackingParams params) async {
    try {
      await _push(
        params.deliveryId,
        DeliveryStatus.pickedUp,
        params.pickup,
      );

      for (int step = 1; step <= _steps; step++) {
        await Future<void>.delayed(_stepInterval);
        final double t = step / _steps;
        final CoordinatesEntity position = CoordinatesEntity(
          latitude:
              params.pickup.latitude +
              (params.destination.latitude - params.pickup.latitude) * t,
          longitude:
              params.pickup.longitude +
              (params.destination.longitude - params.pickup.longitude) * t,
        );
        final DeliveryStatus status = step == _steps
            ? DeliveryStatus.delivered
            : DeliveryStatus.inTransit;
        await _push(params.deliveryId, status, position);
      }

      return const Result.success(null);
    } on _TrackingStepFailedException catch (e) {
      return Result.failure(e.failure);
    }
  }

  Future<void> _push(
    String deliveryId,
    DeliveryStatus status,
    CoordinatesEntity position,
  ) async {
    final Result<void> result = await _deliveryRepository.updateTrackingState(
      id: deliveryId,
      status: status,
      courierPosition: position,
    );
    result.when(
      success: (_) {},
      failure: (Failure failure) => throw _TrackingStepFailedException(failure),
    );
  }
}

class _TrackingStepFailedException implements Exception {
  const _TrackingStepFailedException(this.failure);

  final Failure failure;
}
