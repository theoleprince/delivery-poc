import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:poc_uber/features/wallet/data/models/transaction_model.dart';
import 'package:poc_uber/features/wallet/data/models/wallet_model.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/entities/wallet_entity.dart';
import 'package:poc_uber/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(this._remoteDataSource);

  final WalletRemoteDataSource _remoteDataSource;

  @override
  Future<Result<void>> ensureWalletExists(String uid) async {
    try {
      await _remoteDataSource.ensureWalletExists(uid);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Stream<WalletEntity?> watchWallet(String uid) {
    return _remoteDataSource
        .watchWallet(uid)
        .map((WalletModel? model) => model?.toEntity());
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions(String uid) {
    return _remoteDataSource
        .watchTransactions(uid)
        .map(
          (List<TransactionModel> models) => models
              .map((TransactionModel model) => model.toEntity())
              .toList(),
        );
  }

  @override
  Stream<TransactionEntity?> watchTransactionById(String id) {
    return _remoteDataSource
        .watchTransactionById(id)
        .map((TransactionModel? model) => model?.toEntity());
  }

  @override
  Future<Result<TransactionEntity>> createTransaction({
    required String uid,
    required TransactionType type,
    required double amount,
    required String description,
    String? relatedDeliveryId,
  }) async {
    try {
      final TransactionModel model = await _remoteDataSource.createTransaction(
        uid: uid,
        type: type,
        amount: amount,
        description: description,
        relatedDeliveryId: relatedDeliveryId,
      );
      return Result.success(model.toEntity());
    } on InsufficientBalanceException {
      return const Result.failure(Failure.server('Solde insuffisant.'));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
