import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/repositories/delivery_repository.dart';

class CreateDeliveryParams {
  const CreateDeliveryParams({required this.delivery});

  final DeliveryEntity delivery;
}

class CreateDeliveryUseCase
    implements UseCase<DeliveryEntity, CreateDeliveryParams> {
  const CreateDeliveryUseCase(this._repository);

  final DeliveryRepository _repository;

  @override
  Future<Result<DeliveryEntity>> call(CreateDeliveryParams params) {
    return _repository.createDelivery(params.delivery);
  }
}
