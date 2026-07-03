import 'package:poc_uber/features/wallet/domain/entities/wallet_entity.dart';
import 'package:poc_uber/features/wallet/domain/repositories/wallet_repository.dart';

class WatchWalletUseCase {
  const WatchWalletUseCase(this._repository);

  final WalletRepository _repository;

  Stream<WalletEntity?> call(String uid) => _repository.watchWallet(uid);
}
