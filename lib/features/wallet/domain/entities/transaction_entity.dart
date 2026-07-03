import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';

enum TransactionType { credit, debit }

@freezed
class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    String? id,
    required String uid,
    required TransactionType type,
    required double amount,
    required String description,
    String? relatedDeliveryId,
    DateTime? createdAt,
  }) = _TransactionEntity;
}
