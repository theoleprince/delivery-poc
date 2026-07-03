import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/core/firestore/server_timestamp_converter.dart';
import 'package:poc_uber/features/delivery/data/models/address_model.dart';
import 'package:poc_uber/features/delivery/data/models/package_model.dart';
import 'package:poc_uber/features/delivery/data/models/recipient_model.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';

part 'delivery_model.freezed.dart';
part 'delivery_model.g.dart';

/// DTO Firestore pour un document `deliveries/{id}`. `id` n'est jamais
/// écrit dans le corps du document (c'est l'ID du document lui-même) —
/// renseigné uniquement en mémoire après lecture/écriture.
@freezed
class DeliveryModel with _$DeliveryModel {
  const factory DeliveryModel({
    String? id,
    required String senderId,
    required AddressModel pickup,
    required AddressModel destination,
    required PackageModel package,
    required RecipientModel recipient,
    required double distanceMeters,
    required double estimatedPrice,
    required int estimatedDurationMinutes,
    required DeliveryType deliveryType,
    required PaymentMethod paymentMethod,
    required DeliveryStatus status,
    @ServerTimestampConverter() DateTime? createdAt,
    @ServerTimestampConverter() DateTime? updatedAt,
  }) = _DeliveryModel;

  const DeliveryModel._();

  factory DeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryModelFromJson(json);

  factory DeliveryModel.fromEntity(DeliveryEntity entity) => DeliveryModel(
    id: entity.id,
    senderId: entity.senderId,
    pickup: AddressModel.fromEntity(entity.pickup),
    destination: AddressModel.fromEntity(entity.destination),
    package: PackageModel.fromEntity(entity.package),
    recipient: RecipientModel.fromEntity(entity.recipient),
    distanceMeters: entity.distanceMeters,
    estimatedPrice: entity.estimatedPrice,
    estimatedDurationMinutes: entity.estimatedDurationMinutes,
    deliveryType: entity.deliveryType,
    paymentMethod: entity.paymentMethod,
    status: entity.status,
  );

  DeliveryEntity toEntity() => DeliveryEntity(
    id: id,
    senderId: senderId,
    pickup: pickup.toEntity(),
    destination: destination.toEntity(),
    package: package.toEntity(),
    recipient: recipient.toEntity(),
    distanceMeters: distanceMeters,
    estimatedPrice: estimatedPrice,
    estimatedDurationMinutes: estimatedDurationMinutes,
    deliveryType: deliveryType,
    paymentMethod: paymentMethod,
    status: status,
    createdAt: createdAt,
  );
}
