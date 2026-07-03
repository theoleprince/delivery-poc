import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/entities/wallet_entity.dart';

abstract interface class WalletRepository {
  /// Crée le wallet de `uid` s'il n'existe pas encore, avec un bonus de
  /// bienvenue simulé (voir ARCHITECTURE.md §10.1). Idempotent : sans effet
  /// si le wallet existe déjà — peut être appelé à chaque connexion.
  Future<Result<void>> ensureWalletExists(String uid);

  Stream<WalletEntity?> watchWallet(String uid);

  /// Transactions de `uid`, les plus récentes en premier.
  Stream<List<TransactionEntity>> watchTransactions(String uid);

  Stream<TransactionEntity?> watchTransactionById(String id);

  /// Crée une transaction et met à jour le solde du wallet de façon
  /// atomique (transaction Firestore). Échoue avec `Failure.server` si un
  /// débit dépasse le solde disponible.
  Future<Result<TransactionEntity>> createTransaction({
    required String uid,
    required TransactionType type,
    required double amount,
    required String description,
    String? relatedDeliveryId,
  });
}
