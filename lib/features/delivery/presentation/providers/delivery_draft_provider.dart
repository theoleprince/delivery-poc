import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/entities/package_entity.dart';
import 'package:poc_uber/features/delivery/domain/entities/recipient_entity.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/route_entity.dart';

part 'delivery_draft_provider.freezed.dart';
part 'delivery_draft_provider.g.dart';

/// État accumulé au fil des étapes du formulaire de création (voir
/// ARCHITECTURE.md §8). Tous les champs sont nullable par construction —
/// distinct de `DeliveryEntity` (domain), dont les champs sont requis.
/// [toEntity] valide la complétude juste avant l'appel au usecase.
@freezed
class DeliveryDraft with _$DeliveryDraft {
  const factory DeliveryDraft({
    AddressEntity? pickup,
    AddressEntity? destination,
    RouteEntity? route,
    PackageEntity? package,
    RecipientEntity? recipient,
    @Default(DeliveryType.standard) DeliveryType deliveryType,
    @Default(PaymentMethod.beforeDelivery) PaymentMethod paymentMethod,
  }) = _DeliveryDraft;

  const DeliveryDraft._();

  bool get isComplete =>
      pickup != null &&
      destination != null &&
      route != null &&
      package != null &&
      recipient != null;

  /// Lève une [StateError] si [isComplete] est faux — l'appelant
  /// (`DeliverySummaryPage`) ne doit permettre la confirmation que lorsque
  /// toutes les étapes précédentes sont remplies. `estimatedPrice`/
  /// `estimatedDurationMinutes` sont calculés par l'appelant via
  /// `DeliveryPricing.estimate` (domain/services), pas par ce mapper.
  DeliveryEntity toEntity({
    required String senderId,
    required double estimatedPrice,
    required int estimatedDurationMinutes,
  }) {
    if (!isComplete) {
      throw StateError(
        'DeliveryDraft incomplet : impossible de le convertir en DeliveryEntity.',
      );
    }
    return DeliveryEntity(
      senderId: senderId,
      pickup: pickup!,
      destination: destination!,
      package: package!,
      recipient: recipient!,
      distanceMeters: route!.distanceMeters,
      estimatedPrice: estimatedPrice,
      estimatedDurationMinutes: estimatedDurationMinutes,
      deliveryType: deliveryType,
      paymentMethod: paymentMethod,
    );
  }
}

@riverpod
class DeliveryDraftController extends _$DeliveryDraftController {
  @override
  DeliveryDraft build() => const DeliveryDraft();

  void setPickup(AddressEntity address) =>
      state = state.copyWith(pickup: address);

  void setDestination(AddressEntity address) =>
      state = state.copyWith(destination: address);

  void setRoute(RouteEntity route) => state = state.copyWith(route: route);

  void setPackage(PackageEntity package) =>
      state = state.copyWith(package: package);

  void setRecipient(RecipientEntity recipient) =>
      state = state.copyWith(recipient: recipient);

  void setDeliveryType(DeliveryType type) =>
      state = state.copyWith(deliveryType: type);

  void setPaymentMethod(PaymentMethod method) =>
      state = state.copyWith(paymentMethod: method);

  void reset() => state = const DeliveryDraft();
}
