import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';

abstract interface class DeliveryRepository {
  Future<Result<DeliveryEntity>> createDelivery(DeliveryEntity delivery);

  /// Livraisons de l'expéditeur `senderId`, les plus récentes en premier.
  /// En flux (pas un simple `Future`) pour refléter automatiquement une
  /// nouvelle livraison créée pendant que l'historique est ouvert.
  Stream<List<DeliveryEntity>> watchUserDeliveries(String senderId);

  /// `null` si le document n'existe pas (ou plus). En flux pour refléter,
  /// une fois `tracking` implémenté, les mises à jour de statut en direct.
  Stream<DeliveryEntity?> watchDeliveryById(String id);
}
