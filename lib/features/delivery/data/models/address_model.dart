import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

/// DTO Firestore pour une adresse embarquée dans un document `deliveries`
/// (départ ou destination). La feature `map` n'a pas de couche `data` liée
/// à Firestore (voir son datasource) : ce modèle vit dans `delivery`, seule
/// feature à persister une `AddressEntity`.
@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    required String formattedAddress,
    required double latitude,
    required double longitude,
  }) = _AddressModel;

  const AddressModel._();

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  factory AddressModel.fromEntity(AddressEntity entity) => AddressModel(
    formattedAddress: entity.formattedAddress,
    latitude: entity.coordinates.latitude,
    longitude: entity.coordinates.longitude,
  );

  AddressEntity toEntity() => AddressEntity(
    formattedAddress: formattedAddress,
    coordinates: CoordinatesEntity(latitude: latitude, longitude: longitude),
  );
}
