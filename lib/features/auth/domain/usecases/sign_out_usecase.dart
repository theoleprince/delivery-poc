import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.signOut();
  }
}
