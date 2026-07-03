import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/repositories/delivery_repository.dart';

class WatchDeliveryByIdUseCase {
  const WatchDeliveryByIdUseCase(this._repository);

  final DeliveryRepository _repository;

  Stream<DeliveryEntity?> call(String id) => _repository.watchDeliveryById(id);
}
