import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/repositories/location_repository.dart';

class SearchAddressParams {
  const SearchAddressParams({required this.query});

  final String query;
}

class SearchAddressUseCase
    implements UseCase<List<AddressEntity>, SearchAddressParams> {
  const SearchAddressUseCase(this._repository);

  final LocationRepository _repository;

  @override
  Future<Result<List<AddressEntity>>> call(SearchAddressParams params) {
    return _repository.searchAddress(params.query);
  }
}
