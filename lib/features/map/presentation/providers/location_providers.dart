import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:poc_uber/features/map/data/datasources/location_remote_datasource.dart';
import 'package:poc_uber/features/map/data/repositories/location_repository_impl.dart';
import 'package:poc_uber/features/map/domain/entities/address_entity.dart';
import 'package:poc_uber/features/map/domain/repositories/location_repository.dart';
import 'package:poc_uber/features/map/domain/usecases/get_current_position_usecase.dart';
import 'package:poc_uber/features/map/domain/usecases/get_route_usecase.dart';
import 'package:poc_uber/features/map/domain/usecases/reverse_geocode_usecase.dart';
import 'package:poc_uber/features/map/domain/usecases/search_address_usecase.dart';

part 'location_providers.g.dart';

@riverpod
LocationRemoteDataSource locationRemoteDataSource(Ref ref) {
  return const LocationRemoteDataSourceImpl();
}

@riverpod
LocationRepository locationRepository(Ref ref) {
  return LocationRepositoryImpl(ref.watch(locationRemoteDataSourceProvider));
}

@riverpod
GetCurrentPositionUseCase getCurrentPositionUseCase(Ref ref) =>
    GetCurrentPositionUseCase(ref.watch(locationRepositoryProvider));

@riverpod
SearchAddressUseCase searchAddressUseCase(Ref ref) =>
    SearchAddressUseCase(ref.watch(locationRepositoryProvider));

@riverpod
ReverseGeocodeUseCase reverseGeocodeUseCase(Ref ref) =>
    ReverseGeocodeUseCase(ref.watch(locationRepositoryProvider));

@riverpod
GetRouteUseCase getRouteUseCase(Ref ref) =>
    GetRouteUseCase(ref.watch(locationRepositoryProvider));

/// État de la recherche d'adresse dans `LocationPickerPage`. Volontairement
/// séparé d'un état de sélection persistant : la sélection finale
/// (`Coordinates`+adresse) est renvoyée via `Navigator.pop`, pas stockée
/// dans un provider global (état purement local à l'écran de sélection).
@riverpod
class AddressSearchController extends _$AddressSearchController {
  @override
  FutureOr<List<AddressEntity>> build() => const <AddressEntity>[];

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData<List<AddressEntity>>(<AddressEntity>[]);
      return;
    }
    state = const AsyncLoading<List<AddressEntity>>();
    final result = await ref
        .read(searchAddressUseCaseProvider)
        .call(SearchAddressParams(query: query));
    state = result.when(
      success: (List<AddressEntity> addresses) => AsyncData(addresses),
      failure: (failure) =>
          AsyncError<List<AddressEntity>>(failure, StackTrace.current),
    );
  }
}
