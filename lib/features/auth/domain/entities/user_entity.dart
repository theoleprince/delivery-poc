import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// Représentation métier d'un utilisateur authentifié. Pure (pas de JSON,
/// pas de dépendance Firebase) — voir ARCHITECTURE.md §4.6 pour la
/// séparation Entity/Model.
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String uid,
    required String email,
    String? displayName,
  }) = _UserEntity;
}
