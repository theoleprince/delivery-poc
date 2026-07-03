import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';
import 'package:poc_uber/features/auth/domain/repositories/auth_repository.dart';

class SignInParams {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;
}

class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserEntity>> call(SignInParams params) {
    return _repository.signIn(email: params.email, password: params.password);
  }
}
