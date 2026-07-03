import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';

part 'address_entity.freezed.dart';

@freezed
class AddressEntity with _$AddressEntity {
  const factory AddressEntity({
    required String formattedAddress,
    required CoordinatesEntity coordinates,
  }) = _AddressEntity;
}
