import 'package:poc_uber/core/error/result.dart';

/// Contrat de base pour tous les usecases du domaine.
///
/// [Type] est le type de retour en cas de succès, [Params] le type des
/// paramètres d'entrée. Utiliser [NoParams] quand le usecase n'a pas de
/// paramètre.
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Marqueur pour les usecases sans paramètre (ex. `SignOutUseCase`).
class NoParams {
  const NoParams();
}
