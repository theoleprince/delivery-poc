import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/features/delivery/domain/entities/package_entity.dart';

part 'package_model.freezed.dart';
part 'package_model.g.dart';

@freezed
class PackageDimensionsModel with _$PackageDimensionsModel {
  const factory PackageDimensionsModel({
    required double lengthCm,
    required double widthCm,
    required double heightCm,
  }) = _PackageDimensionsModel;

  const PackageDimensionsModel._();

  factory PackageDimensionsModel.fromJson(Map<String, dynamic> json) =>
      _$PackageDimensionsModelFromJson(json);

  factory PackageDimensionsModel.fromEntity(PackageDimensions entity) =>
      PackageDimensionsModel(
        lengthCm: entity.lengthCm,
        widthCm: entity.widthCm,
        heightCm: entity.heightCm,
      );

  PackageDimensions toEntity() => PackageDimensions(
    lengthCm: lengthCm,
    widthCm: widthCm,
    heightCm: heightCm,
  );
}

@freezed
class PackageModel with _$PackageModel {
  const factory PackageModel({
    required String name,
    required String description,
    required double weightKg,
    required PackageDimensionsModel dimensions,
    required double declaredValue,
    String? specialInstructions,
  }) = _PackageModel;

  const PackageModel._();

  factory PackageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageModelFromJson(json);

  factory PackageModel.fromEntity(PackageEntity entity) => PackageModel(
    name: entity.name,
    description: entity.description,
    weightKg: entity.weightKg,
    dimensions: PackageDimensionsModel.fromEntity(entity.dimensions),
    declaredValue: entity.declaredValue,
    specialInstructions: entity.specialInstructions,
  );

  PackageEntity toEntity() => PackageEntity(
    name: name,
    description: description,
    weightKg: weightKg,
    dimensions: dimensions.toEntity(),
    declaredValue: declaredValue,
    specialInstructions: specialInstructions,
  );
}
