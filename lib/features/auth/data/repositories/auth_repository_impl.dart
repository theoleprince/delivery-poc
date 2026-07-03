import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:poc_uber/features/auth/data/models/user_model.dart';
import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';
import 'package:poc_uber/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<UserEntity?> watchAuthState() {
    return _remoteDataSource.watchAuthState().map(
      (UserModel? model) => model?.toEntity(),
    );
  }

  @override
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserModel model = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Result.success(model.toEntity());
    } on fb.FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final UserModel model = await _remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Result.success(model.toEntity());
    } on fb.FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      await _remoteDataSource.resetPassword(email: email);
      return const Result.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  Failure _mapAuthException(fb.FirebaseAuthException e) {
    if (e.code == 'network-request-failed') {
      return Failure.network('Erreur réseau, vérifie ta connexion.');
    }
    return Failure.auth(_authMessage(e));
  }

  String _authMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'user-not-found':
        return 'Aucun compte ne correspond à cet email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      default:
        return e.message ?? 'Une erreur d\'authentification est survenue.';
    }
  }
}
