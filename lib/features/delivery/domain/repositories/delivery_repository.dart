import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';

abstract interface class DeliveryRepository {
  Future<Result<DeliveryEntity>> createDelivery(DeliveryEntity delivery);

  /// Livraisons de l'expéditeur `senderId`, les plus récentes en premier.
  /// En flux (pas un simple `Future`) pour refléter automatiquement une
  /// nouvelle livraison créée pendant que l'historique est ouvert.
  Stream<List<DeliveryEntity>> watchUserDeliveries(String senderId);

  /// `null` si le document n'existe pas (ou plus). En flux pour refléter
  /// les mises à jour de statut/position en direct pendant `tracking`.
  Stream<DeliveryEntity?> watchDeliveryById(String id);

  /// Met à jour le statut et/ou la position simulée du livreur. Contrat
  /// public consommé par la feature `tracking` — voir ARCHITECTURE.md §11.
  Future<Result<void>> updateTrackingState({
    required String id,
    required DeliveryStatus status,
    CoordinatesEntity? courierPosition,
  });
}
