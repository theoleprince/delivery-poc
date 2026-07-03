import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams {
  const ResetPasswordParams({required this.email});

  final String email;
}

class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(ResetPasswordParams params) {
    return _repository.resetPassword(email: params.email);
  }
}
