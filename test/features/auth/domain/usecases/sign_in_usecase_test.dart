import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';
import 'package:poc_uber/features/auth/domain/repositories/auth_repository.dart';
import 'package:poc_uber/features/auth/domain/usecases/sign_in_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late SignInUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = SignInUseCase(repository);
  });

  const String email = 'user@example.com';
  const String password = 'password123';
  const UserEntity user = UserEntity(uid: 'uid-1', email: email);

  test('retourne UserEntity quand le repository réussit', () async {
    when(
      () => repository.signIn(email: email, password: password),
    ).thenAnswer((_) async => const Result<UserEntity>.success(user));

    final Result<UserEntity> result = await useCase(
      const SignInParams(email: email, password: password),
    );

    expect(result, const Result<UserEntity>.success(user));
    verify(() => repository.signIn(email: email, password: password)).called(1);
  });

  test('propage le Failure quand le repository échoue', () async {
    const Failure failure = Failure.auth('Email ou mot de passe incorrect.');
    when(
      () => repository.signIn(email: email, password: password),
    ).thenAnswer((_) async => const Result<UserEntity>.failure(failure));

    final Result<UserEntity> result = await useCase(
      const SignInParams(email: email, password: password),
    );

    expect(result, const Result<UserEntity>.failure(failure));
  });
}
