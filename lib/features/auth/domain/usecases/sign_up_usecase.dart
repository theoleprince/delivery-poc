import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';
import 'package:poc_uber/features/auth/domain/repositories/auth_repository.dart';

class SignUpParams {
  const SignUpParams({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;
}

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserEntity>> call(SignUpParams params) {
    return _repository.signUp(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
