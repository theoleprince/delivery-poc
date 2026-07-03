import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';
import 'package:poc_uber/features/map/domain/entities/route_entity.dart';
import 'package:poc_uber/features/map/domain/repositories/location_repository.dart';

class GetRouteParams {
  const GetRouteParams({required this.origin, required this.destination});

  final CoordinatesEntity origin;
  final CoordinatesEntity destination;
}

class GetRouteUseCase implements UseCase<RouteEntity, GetRouteParams> {
  const GetRouteUseCase(this._repository);

  final LocationRepository _repository;

  @override
  Future<Result<RouteEntity>> call(GetRouteParams params) {
    return _repository.getRoute(
      origin: params.origin,
      destination: params.destination,
    );
  }
}
