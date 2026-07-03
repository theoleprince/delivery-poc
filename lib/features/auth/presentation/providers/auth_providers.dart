import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/providers/firebase_providers.dart';
import 'package:poc_uber/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:poc_uber/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';
import 'package:poc_uber/features/auth/domain/repositories/auth_repository.dart';
import 'package:poc_uber/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:poc_uber/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:poc_uber/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:poc_uber/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:poc_uber/features/auth/domain/usecases/watch_auth_state_usecase.dart';

part 'auth_providers.g.dart';

// --- Infrastructure (composition root de la feature Auth) ---------------
// `firebaseAuthProvider`/`firestoreProvider` sont partagés depuis
// `core/providers/firebase_providers.dart` (voir ARCHITECTURE.md §4.3).

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
}

// --- Usecases -------------------------------------------------------------

@riverpod
SignInUseCase signInUseCase(Ref ref) =>
    SignInUseCase(ref.watch(authRepositoryProvider));

@riverpod
SignUpUseCase signUpUseCase(Ref ref) =>
    SignUpUseCase(ref.watch(authRepositoryProvider));

@riverpod
SignOutUseCase signOutUseCase(Ref ref) =>
    SignOutUseCase(ref.watch(authRepositoryProvider));

@riverpod
ResetPasswordUseCase resetPasswordUseCase(Ref ref) =>
    ResetPasswordUseCase(ref.watch(authRepositoryProvider));

@riverpod
WatchAuthStateUseCase watchAuthStateUseCase(Ref ref) =>
    WatchAuthStateUseCase(ref.watch(authRepositoryProvider));

// --- État d'authentification (consommé par le router + SplashPage) -------

@riverpod
Stream<UserEntity?> authState(Ref ref) {
  return ref.watch(watchAuthStateUseCaseProvider).call();
}

// --- Contrôleurs d'écran ---------------------------------------------------

@riverpod
class SignInController extends _$SignInController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signInUseCaseProvider)
        .call(SignInParams(email: email, password: password));
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (Failure f) => AsyncError<void>(f, StackTrace.current),
    );
  }
}

@riverpod
class SignUpController extends _$SignUpController {
  @override
  FutureOr<void> build() {}

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signUpUseCaseProvider)
        .call(
          SignUpParams(
            email: email,
            password: password,
            displayName: displayName,
          ),
        );
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (Failure f) => AsyncError<void>(f, StackTrace.current),
    );
  }
}

@riverpod
class ResetPasswordController extends _$ResetPasswordController {
  @override
  FutureOr<void> build() {}

  Future<void> resetPassword({required String email}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(resetPasswordUseCaseProvider)
        .call(ResetPasswordParams(email: email));
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (Failure f) => AsyncError<void>(f, StackTrace.current),
    );
  }
}
