import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:poc_uber/core/providers/firebase_providers.dart';
import 'package:poc_uber/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:poc_uber/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/entities/wallet_entity.dart';
import 'package:poc_uber/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:poc_uber/features/wallet/domain/usecases/create_transaction_usecase.dart';
import 'package:poc_uber/features/wallet/domain/usecases/ensure_wallet_exists_usecase.dart';
import 'package:poc_uber/features/wallet/domain/usecases/watch_transaction_by_id_usecase.dart';
import 'package:poc_uber/features/wallet/domain/usecases/watch_transactions_usecase.dart';
import 'package:poc_uber/features/wallet/domain/usecases/watch_wallet_usecase.dart';

part 'wallet_providers.g.dart';

@riverpod
WalletRemoteDataSource walletRemoteDataSource(Ref ref) {
  return WalletRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider));
}

@riverpod
WalletRepository walletRepository(Ref ref) {
  return WalletRepositoryImpl(ref.watch(walletRemoteDataSourceProvider));
}

@riverpod
EnsureWalletExistsUseCase ensureWalletExistsUseCase(Ref ref) =>
    EnsureWalletExistsUseCase(ref.watch(walletRepositoryProvider));

@riverpod
WatchWalletUseCase watchWalletUseCase(Ref ref) =>
    WatchWalletUseCase(ref.watch(walletRepositoryProvider));

@riverpod
WatchTransactionsUseCase watchTransactionsUseCase(Ref ref) =>
    WatchTransactionsUseCase(ref.watch(walletRepositoryProvider));

@riverpod
WatchTransactionByIdUseCase watchTransactionByIdUseCase(Ref ref) =>
    WatchTransactionByIdUseCase(ref.watch(walletRepositoryProvider));

@riverpod
CreateTransactionUseCase createTransactionUseCase(Ref ref) =>
    CreateTransactionUseCase(ref.watch(walletRepositoryProvider));

@riverpod
Stream<WalletEntity?> wallet(Ref ref, String uid) {
  return ref.watch(watchWalletUseCaseProvider).call(uid);
}

@riverpod
Stream<List<TransactionEntity>> walletTransactions(Ref ref, String uid) {
  return ref.watch(watchTransactionsUseCaseProvider).call(uid);
}

@riverpod
Stream<TransactionEntity?> transactionById(Ref ref, String id) {
  return ref.watch(watchTransactionByIdUseCaseProvider).call(id);
}
