import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipient_entity.freezed.dart';

@freezed
class RecipientEntity with _$RecipientEntity {
  const factory RecipientEntity({
    required String name,
    required String phone,
    required String address,
    String? instructions,
  }) = _RecipientEntity;
}
