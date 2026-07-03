import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/features/delivery/domain/entities/package_entity.dart';
import 'package:poc_uber/features/delivery/domain/entities/recipient_entity.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';

part 'delivery_entity.freezed.dart';

/// Réutilise `AddressEntity` de la feature `map` (son contrat public, pas
/// un détail d'implémentation) plutôt que de dupliquer un type d'adresse
/// propre à `delivery` — voir ARCHITECTURE.md §8.
enum DeliveryType { standard, express }

enum PaymentMethod { beforeDelivery, onDelivery }

/// Statut figé à `pending` pour ce sprint (flux de création uniquement) —
/// le cycle de vie complet (`pickedUp`, `inTransit`, `delivered`, ...)
/// appartient à la feature `tracking`, pas encore implémentée.
enum DeliveryStatus { pending }

@freezed
class DeliveryEntity with _$DeliveryEntity {
  const factory DeliveryEntity({
    String? id,
    required String senderId,
    required AddressEntity pickup,
    required AddressEntity destination,
    required PackageEntity package,
    required RecipientEntity recipient,
    required double distanceMeters,
    required double estimatedPrice,
    required int estimatedDurationMinutes,
    required DeliveryType deliveryType,
    required PaymentMethod paymentMethod,
    @Default(DeliveryStatus.pending) DeliveryStatus status,
    DateTime? createdAt,
  }) = _DeliveryEntity;
}
