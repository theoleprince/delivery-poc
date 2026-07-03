import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';

/// Contrat d'accès à l'authentification, implémenté par la couche `data`
/// (`AuthRepositoryImpl`). Le domaine ne connaît que cette interface —
/// inversion de dépendance stricte.
abstract interface class AuthRepository {
  /// Émet l'utilisateur courant (`null` si déconnecté), y compris la
  /// session persistante restaurée au démarrage.
  Stream<UserEntity?> watchAuthState();

  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> resetPassword({required String email});
}
