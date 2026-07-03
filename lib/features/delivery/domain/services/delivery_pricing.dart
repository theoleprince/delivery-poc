import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';

class DeliveryEstimate {
  const DeliveryEstimate({required this.price, required this.durationMinutes});

  final double price;
  final int durationMinutes;
}

/// Calcul de prix/durée estimée, volontairement simplifié pour ce POC
/// (tarif au kilomètre + majoration express, pas de zones tarifaires ni de
/// surcharge horaire) — voir ARCHITECTURE.md §8. Fonction pure (pas d'I/O,
/// pas de dépendance repository) : ce n'est pas un usecase au sens de cette
/// architecture, juste une règle métier déterministe.
abstract final class DeliveryPricing {
  static const double _baseFare = 2.5;
  static const double _perKm = 0.8;
  static const double _expressMultiplier = 1.5;
  static const double _expressDurationFactor = 0.7;
  static const double _averageSpeedKmH = 25;
  static const int _minDurationMinutes = 5;

  static DeliveryEstimate estimate({
    required double distanceMeters,
    required DeliveryType deliveryType,
  }) {
    final bool isExpress = deliveryType == DeliveryType.express;
    final double distanceKm = distanceMeters / 1000;

    final double basePrice = _baseFare + (distanceKm * _perKm);
    final double price = isExpress ? basePrice * _expressMultiplier : basePrice;

    final double baseDurationMinutes = (distanceKm / _averageSpeedKmH) * 60;
    final double adjustedDuration = isExpress
        ? baseDurationMinutes * _expressDurationFactor
        : baseDurationMinutes;
    final int durationMinutes = adjustedDuration < _minDurationMinutes
        ? _minDurationMinutes
        : adjustedDuration.round();

    return DeliveryEstimate(
      price: double.parse(price.toStringAsFixed(2)),
      durationMinutes: durationMinutes,
    );
  }
}
