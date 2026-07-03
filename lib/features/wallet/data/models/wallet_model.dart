import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/core/firestore/server_timestamp_converter.dart';
import 'package:poc_uber/features/wallet/domain/entities/wallet_entity.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

@freezed
class WalletModel with _$WalletModel {
  const factory WalletModel({
    required String uid,
    required double balance,
    @ServerTimestampConverter() DateTime? createdAt,
    @ServerTimestampConverter() DateTime? updatedAt,
  }) = _WalletModel;

  const WalletModel._();

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  WalletEntity toEntity() => WalletEntity(uid: uid, balance: balance);
}
