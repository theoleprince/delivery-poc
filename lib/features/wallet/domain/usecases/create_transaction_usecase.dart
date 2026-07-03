import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/repositories/wallet_repository.dart';

class CreateTransactionParams {
  const CreateTransactionParams({
    required this.uid,
    required this.type,
    required this.amount,
    required this.description,
    this.relatedDeliveryId,
  });

  final String uid;
  final TransactionType type;
  final double amount;
  final String description;
  final String? relatedDeliveryId;
}

class CreateTransactionUseCase
    implements UseCase<TransactionEntity, CreateTransactionParams> {
  const CreateTransactionUseCase(this._repository);

  final WalletRepository _repository;

  @override
  Future<Result<TransactionEntity>> call(CreateTransactionParams params) {
    return _repository.createTransaction(
      uid: params.uid,
      type: params.type,
      amount: params.amount,
      description: params.description,
      relatedDeliveryId: params.relatedDeliveryId,
    );
  }
}
