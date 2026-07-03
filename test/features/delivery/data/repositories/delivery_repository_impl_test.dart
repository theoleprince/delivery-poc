import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/delivery/data/datasources/delivery_remote_datasource.dart';
import 'package:poc_uber/features/delivery/data/models/delivery_model.dart';
import 'package:poc_uber/features/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/entities/package_entity.dart';
import 'package:poc_uber/features/delivery/domain/entities/recipient_entity.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/entities/coordinates_entity.dart';

class _MockDeliveryRemoteDataSource extends Mock
    implements DeliveryRemoteDataSource {}

DeliveryEntity _buildDelivery() {
  return DeliveryEntity(
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
  late _MockDeliveryRemoteDataSource dataSource;
  late DeliveryRepositoryImpl repository;

  setUpAll(() {
    // mocktail exige un fallback pour any() sur un type personnalisé.
    registerFallbackValue(DeliveryModel.fromEntity(_buildDelivery()));
  });

  setUp(() {
    dataSource = _MockDeliveryRemoteDataSource();
    repository = DeliveryRepositoryImpl(dataSource);
  });

  test('renvoie la livraison créée avec son id', () async {
    final DeliveryEntity delivery = _buildDelivery();
    final DeliveryModel createdModel = DeliveryModel.fromEntity(
      delivery,
    ).copyWith(id: 'delivery-1');

    when(
      () => dataSource.createDelivery(any()),
    ).thenAnswer((_) async => createdModel);

    final Result<DeliveryEntity> result = await repository.createDelivery(
      delivery,
    );

    expect(
      result,
      isA<ResultSuccess<DeliveryEntity>>().having(
        (ResultSuccess<DeliveryEntity> r) => r.value.id,
        'id',
        'delivery-1',
      ),
    );
  });

  test('mappe FirebaseException en Failure.server', () async {
    final DeliveryEntity delivery = _buildDelivery();
    when(
      () => dataSource.createDelivery(any()),
    ).thenThrow(FirebaseException(plugin: 'firestore', message: 'boom'));

    final Result<DeliveryEntity> result = await repository.createDelivery(
      delivery,
    );

    expect(
      result,
      isA<ResultFailure<DeliveryEntity>>().having(
        (ResultFailure<DeliveryEntity> r) => r.failure,
        'failure',
        isA<ServerFailure>(),
      ),
    );
  });

  test('watchUserDeliveries mappe chaque DeliveryModel en DeliveryEntity', () {
    final DeliveryModel model = DeliveryModel.fromEntity(
      _buildDelivery(),
    ).copyWith(id: 'delivery-1');

    when(
      () => dataSource.watchUserDeliveries('uid-1'),
    ).thenAnswer((_) => Stream<List<DeliveryModel>>.value(<DeliveryModel>[model]));

    expect(
      repository.watchUserDeliveries('uid-1'),
      emits(
        isA<List<DeliveryEntity>>().having(
          (List<DeliveryEntity> l) => l.single.id,
          'single.id',
          'delivery-1',
        ),
      ),
    );
  });

  test('watchDeliveryById renvoie null si le document est absent', () {
    when(
      () => dataSource.watchDeliveryById('missing'),
    ).thenAnswer((_) => Stream<DeliveryModel?>.value(null));

    expect(repository.watchDeliveryById('missing'), emits(null));
  });

  group('updateTrackingState', () {
    const CoordinatesEntity position = CoordinatesEntity(
      latitude: 46,
      longitude: 3,
    );

    test('délègue au datasource avec les coordonnées à plat', () async {
      when(
        () => dataSource.updateTrackingState(
          id: 'delivery-1',
          status: DeliveryStatus.inTransit,
          courierLatitude: 46,
          courierLongitude: 3,
        ),
      ).thenAnswer((_) async {});

      final Result<void> result = await repository.updateTrackingState(
        id: 'delivery-1',
        status: DeliveryStatus.inTransit,
        courierPosition: position,
      );

      expect(result, const Result<void>.success(null));
    });

    test('mappe FirebaseException en Failure.server', () async {
      when(
        () => dataSource.updateTrackingState(
          id: any(named: 'id'),
          status: any(named: 'status'),
          courierLatitude: any(named: 'courierLatitude'),
          courierLongitude: any(named: 'courierLongitude'),
        ),
      ).thenThrow(FirebaseException(plugin: 'firestore', message: 'boom'));

      final Result<void> result = await repository.updateTrackingState(
        id: 'delivery-1',
        status: DeliveryStatus.inTransit,
        courierPosition: position,
      );

      expect(
        result,
        isA<ResultFailure<void>>().having(
          (ResultFailure<void> r) => r.failure,
          'failure',
          isA<ServerFailure>(),
        ),
      );
    });
  });
}
