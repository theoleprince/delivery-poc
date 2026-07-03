import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:poc_uber/core/error/failure.dart';

part 'result.freezed.dart';

/// Résultat d'une opération métier : soit une valeur de succès, soit un
/// [Failure] typé. Remplace les exceptions comme mécanisme de propagation
/// d'erreur entre `domain` et `presentation`, pour forcer un traitement
/// explicite (via `when`/`map`) côté UI.
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T value) = ResultSuccess<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;
}
