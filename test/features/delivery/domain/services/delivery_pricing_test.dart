import 'package:flutter_test/flutter_test.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/services/delivery_pricing.dart';

void main() {
  group('DeliveryPricing.estimate', () {
    test('livraison standard : prix de base + tarif au km', () {
      final DeliveryEstimate estimate = DeliveryPricing.estimate(
        distanceMeters: 10000,
        deliveryType: DeliveryType.standard,
      );

      expect(estimate.price, closeTo(2.5 + 10 * 0.8, 0.001));
      expect(estimate.durationMinutes, greaterThan(0));
    });

    test('livraison express : plus chère et plus rapide que standard', () {
      const double distance = 20000;

      final DeliveryEstimate standard = DeliveryPricing.estimate(
        distanceMeters: distance,
        deliveryType: DeliveryType.standard,
      );
      final DeliveryEstimate express = DeliveryPricing.estimate(
        distanceMeters: distance,
        deliveryType: DeliveryType.express,
      );

      expect(express.price, greaterThan(standard.price));
      expect(express.durationMinutes, lessThan(standard.durationMinutes));
    });

    test('durée minimale garantie même pour une très courte distance', () {
      final DeliveryEstimate estimate = DeliveryPricing.estimate(
        distanceMeters: 10,
        deliveryType: DeliveryType.standard,
      );

      expect(estimate.durationMinutes, greaterThanOrEqualTo(5));
    });
  });
}
