import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';
import 'package:poc_uber/features/map/domain/repositories/location_repository.dart';

class GetCurrentPositionUseCase implements UseCase<CoordinatesEntity, NoParams> {
  const GetCurrentPositionUseCase(this._repository);

  final LocationRepository _repository;

  @override
  Future<Result<CoordinatesEntity>> call(NoParams params) {
    return _repository.getCurrentPosition();
  }
}
