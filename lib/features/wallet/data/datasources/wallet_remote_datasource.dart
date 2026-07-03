import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poc_uber/core/constants/firestore_collections.dart';
import 'package:poc_uber/core/firestore/firestore_write_helpers.dart';
import 'package:poc_uber/features/wallet/data/models/transaction_model.dart';
import 'package:poc_uber/features/wallet/data/models/wallet_model.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';

/// Encapsule les accès Firestore `wallets`/`transactions`. Solde et
/// transaction sont toujours écrits ensemble via `runTransaction` (voir
/// ARCHITECTURE.md §10.2) pour éviter toute incohérence en cas d'écritures
/// concurrentes.
///
/// Ne traduit pas les erreurs génériques : laisse les exceptions Firestore
/// se propager. [InsufficientBalanceException] est levée explicitement ici
/// et convertie en `Failure` par `WalletRepositoryImpl`.
abstract interface class WalletRemoteDataSource {
  Future<void> ensureWalletExists(String uid);

  Stream<WalletModel?> watchWallet(String uid);

  Stream<List<TransactionModel>> watchTransactions(String uid);

  Stream<TransactionModel?> watchTransactionById(String id);

  Future<TransactionModel> createTransaction({
    required String uid,
    required TransactionType type,
    required double amount,
    required String description,
    String? relatedDeliveryId,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  WalletRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Bonus de bienvenue simulé accordé à la création du wallet — voir
  /// ARCHITECTURE.md §10.1. Aucun flux d'argent réel n'est impliqué.
  static const double _welcomeBonusAmount = 50;

  @override
  Future<void> ensureWalletExists(String uid) async {
    final DocumentReference<Map<String, dynamic>> walletRef = _firestore
        .collection(FirestoreCollections.wallets)
        .doc(uid);

    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction
          .get(walletRef);
      if (snapshot.exists) return;

      final DocumentReference<Map<String, dynamic>> transactionRef =
          _firestore.collection(FirestoreCollections.transactions).doc();

      transaction.set(
        walletRef,
        attachTimestamps(<String, Object?>{
          'uid': uid,
          'balance': _welcomeBonusAmount,
        }, isCreate: true),
      );
      transaction.set(
        transactionRef,
        attachTimestamps(<String, Object?>{
          'uid': uid,
          'type': TransactionType.credit.name,
          'amount': _welcomeBonusAmount,
          'description': 'Bonus de bienvenue',
          'relatedDeliveryId': null,
        }, isCreate: true),
      );
    });
  }

  @override
  Stream<WalletModel?> watchWallet(String uid) {
    return _firestore
        .collection(FirestoreCollections.wallets)
        .doc(uid)
        .snapshots()
        .map(
          (DocumentSnapshot<Map<String, dynamic>> doc) =>
              doc.exists ? WalletModel.fromJson(doc.data()!) : null,
        );
  }

  @override
  Stream<List<TransactionModel>> watchTransactions(String uid) {
    // Nécessite un index composite Firestore (uid + createdAt) — voir
    // FIRESTORE_SCHEMA.md.
    return _firestore
        .collection(FirestoreCollections.transactions)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    TransactionModel.fromJson(doc.data()).copyWith(id: doc.id),
              )
              .toList(),
        );
  }

  @override
  Stream<TransactionModel?> watchTransactionById(String id) {
    return _firestore
        .collection(FirestoreCollections.transactions)
        .doc(id)
        .snapshots()
        .map(
          (DocumentSnapshot<Map<String, dynamic>> doc) => doc.exists
              ? TransactionModel.fromJson(doc.data()!).copyWith(id: doc.id)
              : null,
        );
  }

  @override
  Future<TransactionModel> createTransaction({
    required String uid,
    required TransactionType type,
    required double amount,
    required String description,
    String? relatedDeliveryId,
  }) {
    final DocumentReference<Map<String, dynamic>> walletRef = _firestore
        .collection(FirestoreCollections.wallets)
        .doc(uid);
    final DocumentReference<Map<String, dynamic>> transactionRef = _firestore
        .collection(FirestoreCollections.transactions)
        .doc();

    return _firestore.runTransaction<TransactionModel>((
      Transaction transaction,
    ) async {
      final DocumentSnapshot<Map<String, dynamic>> walletSnapshot =
          await transaction.get(walletRef);
      if (!walletSnapshot.exists) {
        throw StateError('Wallet introuvable pour $uid.');
      }

      final double currentBalance = (walletSnapshot.data()!['balance'] as num)
          .toDouble();
      final double delta = type == TransactionType.credit ? amount : -amount;
      final double newBalance = currentBalance + delta;

      if (type == TransactionType.debit && newBalance < 0) {
        throw const InsufficientBalanceException();
      }

      transaction.update(walletRef, <String, Object?>{
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(
        transactionRef,
        attachTimestamps(<String, Object?>{
          'uid': uid,
          'type': type.name,
          'amount': amount,
          'description': description,
          'relatedDeliveryId': relatedDeliveryId,
        }, isCreate: true),
      );

      return TransactionModel(
        id: transactionRef.id,
        uid: uid,
        type: type,
        amount: amount,
        description: description,
        relatedDeliveryId: relatedDeliveryId,
      );
    });
  }
}

class InsufficientBalanceException implements Exception {
  const InsufficientBalanceException();
}
