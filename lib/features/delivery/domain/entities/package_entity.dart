import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_entity.freezed.dart';

@freezed
class PackageDimensions with _$PackageDimensions {
  const factory PackageDimensions({
    required double lengthCm,
    required double widthCm,
    required double heightCm,
  }) = _PackageDimensions;
}

@freezed
class PackageEntity with _$PackageEntity {
  const factory PackageEntity({
    required String name,
    required String description,
    required double weightKg,
    required PackageDimensions dimensions,
    required double declaredValue,
    String? specialInstructions,
  }) = _PackageEntity;
}
