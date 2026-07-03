import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poc_uber/core/constants/firestore_collections.dart';
import 'package:poc_uber/core/firestore/firestore_write_helpers.dart';
import 'package:poc_uber/features/delivery/data/models/delivery_model.dart';

/// Encapsule l'écriture Firestore de la collection `deliveries` (voir
/// ARCHITECTURE.md §8 : 2e feature à utiliser `attachTimestamps`).
///
/// Ne traduit pas les erreurs : laisse les exceptions Firestore se
/// propager, `DeliveryRepositoryImpl` les convertit en `Failure`.
abstract interface class DeliveryRemoteDataSource {
  Future<DeliveryModel> createDelivery(DeliveryModel delivery);

  Stream<List<DeliveryModel>> watchUserDeliveries(String senderId);

  Stream<DeliveryModel?> watchDeliveryById(String id);
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  DeliveryRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<DeliveryModel> createDelivery(DeliveryModel delivery) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(FirestoreCollections.deliveries)
        .doc();

    final Map<String, dynamic> json = delivery.toJson()..remove('id');
    await docRef.set(attachTimestamps(json, isCreate: true));

    return delivery.copyWith(id: docRef.id);
  }

  @override
  Stream<List<DeliveryModel>> watchUserDeliveries(String senderId) {
    // Nécessite un index composite Firestore (senderId + createdAt) — voir
    // FIRESTORE_SCHEMA.md. Sans lui, Firestore lève `failed-precondition`
    // avec un lien direct pour le créer.
    return _firestore
        .collection(FirestoreCollections.deliveries)
        .where('senderId', isEqualTo: senderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    DeliveryModel.fromJson(doc.data()).copyWith(id: doc.id),
              )
              .toList(),
        );
  }

  @override
  Stream<DeliveryModel?> watchDeliveryById(String id) {
    return _firestore
        .collection(FirestoreCollections.deliveries)
        .doc(id)
        .snapshots()
        .map(
          (DocumentSnapshot<Map<String, dynamic>> doc) => doc.exists
              ? DeliveryModel.fromJson(doc.data()!).copyWith(id: doc.id)
              : null,
        );
  }
}
