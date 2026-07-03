import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/features/delivery/domain/entities/recipient_entity.dart';

part 'recipient_model.freezed.dart';
part 'recipient_model.g.dart';

@freezed
class RecipientModel with _$RecipientModel {
  const factory RecipientModel({
    required String name,
    required String phone,
    required String address,
    String? instructions,
  }) = _RecipientModel;

  const RecipientModel._();

  factory RecipientModel.fromJson(Map<String, dynamic> json) =>
      _$RecipientModelFromJson(json);

  factory RecipientModel.fromEntity(RecipientEntity entity) => RecipientModel(
    name: entity.name,
    phone: entity.phone,
    address: entity.address,
    instructions: entity.instructions,
  );

  RecipientEntity toEntity() => RecipientEntity(
    name: name,
    phone: phone,
    address: address,
    instructions: instructions,
  );
}
