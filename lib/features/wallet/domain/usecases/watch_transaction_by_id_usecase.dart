import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/repositories/wallet_repository.dart';

class WatchTransactionByIdUseCase {
  const WatchTransactionByIdUseCase(this._repository);

  final WalletRepository _repository;

  Stream<TransactionEntity?> call(String id) =>
      _repository.watchTransactionById(id);
}
