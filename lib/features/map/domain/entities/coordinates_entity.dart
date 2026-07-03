import 'package:freezed_annotation/freezed_annotation.dart';

part 'coordinates_entity.freezed.dart';

@freezed
class CoordinatesEntity with _$CoordinatesEntity {
  const factory CoordinatesEntity({
    required double latitude,
    required double longitude,
  }) = _CoordinatesEntity;
}
