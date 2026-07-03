import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/entities/package_entity.dart';
import 'package:poc_uber/features/delivery/domain/entities/recipient_entity.dart';
import 'package:poc_uber/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:poc_uber/features/delivery/domain/usecases/watch_user_deliveries_usecase.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';

class _MockDeliveryRepository extends Mock implements DeliveryRepository {}

DeliveryEntity _buildDelivery(String id) {
  return DeliveryEntity(
    id: id,
    senderId: 'uid-1',
    pickup: const AddressEntity(
      formattedAddress: 'Paris',
      coordinates: CoordinatesEntity(latitude: 48.8566, longitude: 2.3522),
    ),
    destination: const AddressEntity(
      formattedAddress: 'Lyon',
      coordinates: CoordinatesEntity(latitude: 45.7640, longitude: 4.8357),
    ),
    package: const PackageEntity(
      name: 'Colis',
      description: 'Documents',
      weightKg: 1.5,
      dimensions: PackageDimensions(lengthCm: 20, widthCm: 15, heightCm: 5),
      declaredValue: 50,
    ),
    recipient: const RecipientEntity(
      name: 'Jean Dupont',
      phone: '0600000000',
      address: '12 rue de Lyon',
    ),
    distanceMeters: 391000,
    estimatedPrice: 12.5,
    estimatedDurationMinutes: 240,
    deliveryType: DeliveryType.standard,
    paymentMethod: PaymentMethod.beforeDelivery,
  );
}

void main() {
  test('délègue au repository et relaie le flux', () {
    final _MockDeliveryRepository repository = _MockDeliveryRepository();
    final WatchUserDeliveriesUseCase useCase = WatchUserDeliveriesUseCase(
      repository,
    );
    final List<DeliveryEntity> deliveries = <DeliveryEntity>[
      _buildDelivery('d1'),
    ];

    when(
      () => repository.watchUserDeliveries('uid-1'),
    ).thenAnswer((_) => Stream<List<DeliveryEntity>>.value(deliveries));

    expect(useCase('uid-1'), emits(deliveries));
    verify(() => repository.watchUserDeliveries('uid-1')).called(1);
  });
}
