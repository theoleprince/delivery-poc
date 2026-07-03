import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/features/delivery/domain/entities/package_entity.dart';
import 'package:poc_uber/features/delivery/domain/entities/recipient_entity.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';

part 'delivery_entity.freezed.dart';

/// Réutilise `AddressEntity` de la feature `map` (son contrat public, pas
/// un détail d'implémentation) plutôt que de dupliquer un type d'adresse
/// propre à `delivery` — voir ARCHITECTURE.md §8.
enum DeliveryType { standard, express }

enum PaymentMethod { beforeDelivery, onDelivery }

/// Cycle de vie piloté par la feature `tracking` (simulation) via
/// `DeliveryRepository.updateTrackingState` — voir ARCHITECTURE.md §11.
enum DeliveryStatus { pending, pickedUp, inTransit, delivered }

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

    /// Position simulée du livreur, mise à jour par `tracking`. `null`
    /// tant que le suivi n'a pas été démarré.
    CoordinatesEntity? courierPosition,
  }) = _DeliveryEntity;
}
