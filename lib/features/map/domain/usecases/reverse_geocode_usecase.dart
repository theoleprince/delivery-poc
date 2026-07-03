import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';
import 'package:poc_uber/features/map/domain/repositories/location_repository.dart';

class ReverseGeocodeParams {
  const ReverseGeocodeParams({required this.coordinates});

  final CoordinatesEntity coordinates;
}

class ReverseGeocodeUseCase
    implements UseCase<AddressEntity, ReverseGeocodeParams> {
  const ReverseGeocodeUseCase(this._repository);

  final LocationRepository _repository;

  @override
  Future<Result<AddressEntity>> call(ReverseGeocodeParams params) {
    return _repository.reverseGeocode(params.coordinates);
  }
}
