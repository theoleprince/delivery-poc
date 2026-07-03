import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/providers/firebase_providers.dart';
import 'package:poc_uber/features/delivery/data/datasources/delivery_remote_datasource.dart';
import 'package:poc_uber/features/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:poc_uber/features/delivery/domain/usecases/create_delivery_usecase.dart';
import 'package:poc_uber/features/delivery/domain/usecases/watch_delivery_by_id_usecase.dart';
import 'package:poc_uber/features/delivery/domain/usecases/watch_user_deliveries_usecase.dart';

part 'delivery_providers.g.dart';

@riverpod
DeliveryRemoteDataSource deliveryRemoteDataSource(Ref ref) {
  return DeliveryRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
}

@riverpod
DeliveryRepository deliveryRepository(Ref ref) {
  return DeliveryRepositoryImpl(ref.watch(deliveryRemoteDataSourceProvider));
}

@riverpod
CreateDeliveryUseCase createDeliveryUseCase(Ref ref) =>
    CreateDeliveryUseCase(ref.watch(deliveryRepositoryProvider));

@riverpod
WatchUserDeliveriesUseCase watchUserDeliveriesUseCase(Ref ref) =>
    WatchUserDeliveriesUseCase(ref.watch(deliveryRepositoryProvider));

@riverpod
WatchDeliveryByIdUseCase watchDeliveryByIdUseCase(Ref ref) =>
    WatchDeliveryByIdUseCase(ref.watch(deliveryRepositoryProvider));

/// Historique de l'expéditeur `senderId`, en flux (voir
/// `DeliveryRepository.watchUserDeliveries`).
@riverpod
Stream<List<DeliveryEntity>> userDeliveries(Ref ref, String senderId) {
  return ref.watch(watchUserDeliveriesUseCaseProvider).call(senderId);
}

@riverpod
Stream<DeliveryEntity?> deliveryById(Ref ref, String id) {
  return ref.watch(watchDeliveryByIdUseCaseProvider).call(id);
}

@riverpod
class CreateDeliveryController extends _$CreateDeliveryController {
  @override
  FutureOr<DeliveryEntity?> build() => null;

  Future<void> submit(DeliveryEntity delivery) async {
    state = const AsyncLoading();
    final result = await ref
        .read(createDeliveryUseCaseProvider)
        .call(CreateDeliveryParams(delivery: delivery));
    state = result.when(
      success: (DeliveryEntity created) => AsyncData(created),
      failure: (Failure f) =>
          AsyncError<DeliveryEntity?>(f, StackTrace.current),
    );
  }
}
