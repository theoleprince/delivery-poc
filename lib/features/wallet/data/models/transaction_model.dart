import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/core/firestore/server_timestamp_converter.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    String? id,
    required String uid,
    required TransactionType type,
    required double amount,
    required String description,
    String? relatedDeliveryId,
    @ServerTimestampConverter() DateTime? createdAt,
  }) = _TransactionModel;

  const TransactionModel._();

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  TransactionEntity toEntity() => TransactionEntity(
    id: id,
    uid: uid,
    type: type,
    amount: amount,
    description: description,
    relatedDeliveryId: relatedDeliveryId,
    createdAt: createdAt,
  );
}
