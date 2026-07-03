/// Chemins de routes centralisés, consommés par `config/router/app_router.dart`.
/// Une seule source de vérité pour éviter les chaînes littérales dupliquées
/// dans les widgets (navigation typée).
abstract final class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

  /// Placeholder : la home réelle sera fournie par les features métier
  /// (delivery/wallet/...) une fois implémentées. Sert de cible de
  /// redirection post-authentification pour ce sprint.
  static const String home = '/home';

  static const String deliveryRoute = '/delivery/route';
  static const String deliveryPackage = '/delivery/package';
  static const String deliveryRecipient = '/delivery/recipient';
  static const String deliverySummary = '/delivery/summary';

  static const String deliveryHistory = '/delivery/history';
  static const String deliveryDetailPattern = '/delivery/history/:id';

  static String deliveryDetail(String id) => '/delivery/history/$id';

  static const String wallet = '/wallet';
  static const String transactionDetailPattern = '/wallet/transactions/:id';

  static String transactionDetail(String id) => '/wallet/transactions/$id';
}
