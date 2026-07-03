import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/wallet/domain/repositories/wallet_repository.dart';

class EnsureWalletExistsUseCase implements UseCase<void, String> {
  const EnsureWalletExistsUseCase(this._repository);

  final WalletRepository _repository;

  @override
  Future<Result<void>> call(String uid) => _repository.ensureWalletExists(uid);
}
