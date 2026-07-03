import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';
import 'package:poc_uber/features/auth/domain/repositories/auth_repository.dart';

/// Expose l'état d'authentification en continu (session persistante
/// incluse). Ne suit pas le contrat `UseCase<Type, Params>` : c'est un
/// flux, pas une opération ponctuelle — forcer la même interface
/// obligerait à envelopper un `Stream` dans un `Future`, ce qui casserait
/// la réactivité recherchée par le router et le splash screen.
class WatchAuthStateUseCase {
  const WatchAuthStateUseCase(this._repository);

  final AuthRepository _repository;

  Stream<UserEntity?> call() => _repository.watchAuthState();
}
