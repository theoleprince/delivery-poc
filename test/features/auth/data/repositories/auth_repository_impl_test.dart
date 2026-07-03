import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:poc_uber/features/auth/data/models/user_model.dart';
import 'package:poc_uber/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late _MockAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = _MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  const String email = 'user@example.com';
  const String password = 'password123';
  const UserModel model = UserModel(uid: 'uid-1', email: email);

  group('signIn', () {
    test('retourne un succès mappé en UserEntity', () async {
      when(
        () => dataSource.signIn(email: email, password: password),
      ).thenAnswer((_) async => model);

      final Result<UserEntity> result = await repository.signIn(
        email: email,
        password: password,
      );

      expect(
        result,
        const Result<UserEntity>.success(UserEntity(uid: 'uid-1', email: email)),
      );
    });

    test('mappe FirebaseAuthException(wrong-password) en Failure.auth', () async {
      when(() => dataSource.signIn(email: email, password: password)).thenThrow(
        fb.FirebaseAuthException(code: 'wrong-password'),
      );

      final Result<UserEntity> result = await repository.signIn(
        email: email,
        password: password,
      );

      expect(
        result,
        isA<ResultFailure<UserEntity>>().having(
          (ResultFailure<UserEntity> r) => r.failure,
          'failure',
          isA<AuthFailure>(),
        ),
      );
    });

    test('mappe FirebaseAuthException(network-request-failed) en Failure.network', () async {
      when(() => dataSource.signIn(email: email, password: password)).thenThrow(
        fb.FirebaseAuthException(code: 'network-request-failed'),
      );

      final Result<UserEntity> result = await repository.signIn(
        email: email,
        password: password,
      );

      expect(
        result,
        isA<ResultFailure<UserEntity>>().having(
          (ResultFailure<UserEntity> r) => r.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      );
    });
  });

  group('signOut', () {
    test('retourne un succès quand le datasource réussit', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      final Result<void> result = await repository.signOut();

      expect(result, const Result<void>.success(null));
    });
  });
}
