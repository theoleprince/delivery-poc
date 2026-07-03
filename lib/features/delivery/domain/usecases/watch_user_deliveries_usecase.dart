import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/repositories/delivery_repository.dart';

/// Expose l'historique en continu — comme `WatchAuthStateUseCase` (feature
/// `auth`), ne suit pas le contrat `UseCase<Type, Params>` (`Future`-based)
/// car c'est un flux, pas une opération ponctuelle.
class WatchUserDeliveriesUseCase {
  const WatchUserDeliveriesUseCase(this._repository);

  final DeliveryRepository _repository;

  Stream<List<DeliveryEntity>> call(String senderId) =>
      _repository.watchUserDeliveries(senderId);
}
