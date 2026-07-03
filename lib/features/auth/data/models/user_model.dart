import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/core/firestore/server_timestamp_converter.dart';
import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// DTO Firestore pour le document `users/{uid}`. Distinct de [UserEntity]
/// (voir ARCHITECTURE.md §4.6) : ce modèle porte les champs de persistance
/// (`createdAt`/`updatedAt`) que le domaine n'a pas besoin de connaître.
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    @ServerTimestampConverter() DateTime? createdAt,
    @ServerTimestampConverter() DateTime? updatedAt,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    uid: entity.uid,
    email: entity.email,
    displayName: entity.displayName,
  );

  UserEntity toEntity() =>
      UserEntity(uid: uid, email: email, displayName: displayName);
}
