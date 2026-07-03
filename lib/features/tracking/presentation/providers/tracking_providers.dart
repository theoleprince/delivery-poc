import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:poc_uber/features/tracking/domain/usecases/simulate_delivery_tracking_usecase.dart';

part 'tracking_providers.g.dart';

/// Réutilise `deliveryRepositoryProvider` (contrat public de `delivery`,
/// même direction de dépendance que `delivery` → `map`) plutôt que de
/// dupliquer un accès Firestore propre à `tracking`.
@riverpod
SimulateDeliveryTrackingUseCase simulateDeliveryTrackingUseCase(Ref ref) =>
    SimulateDeliveryTrackingUseCase(ref.watch(deliveryRepositoryProvider));

@riverpod
class TrackDeliveryController extends _$TrackDeliveryController {
  @override
  FutureOr<void> build() {}

  Future<void> start(SimulateDeliveryTrackingParams params) async {
    state = const AsyncLoading();
    final result = await ref
        .read(simulateDeliveryTrackingUseCaseProvider)
        .call(params);
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (Failure f) => AsyncError<void>(f, StackTrace.current),
    );
  }
}
