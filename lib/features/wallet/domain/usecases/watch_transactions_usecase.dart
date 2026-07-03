import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/repositories/wallet_repository.dart';

class WatchTransactionsUseCase {
  const WatchTransactionsUseCase(this._repository);

  final WalletRepository _repository;

  Stream<List<TransactionEntity>> call(String uid) =>
      _repository.watchTransactions(uid);
}
