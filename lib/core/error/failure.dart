import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Échec métier typé, produit par la couche `data` et consommé par
/// `presentation`. Ne jamais laisser une exception Firebase brute
/// traverser une frontière de couche : elle doit être convertie ici.
@freezed
class Failure with _$Failure {
  const factory Failure.auth(String message) = AuthFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.unknown(String message) = UnknownFailure;
}
