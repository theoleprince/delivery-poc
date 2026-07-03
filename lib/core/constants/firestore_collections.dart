/// Noms des collections Firestore, centralisés pour éviter toute chaîne
/// littérale dupliquée dans les datasources. Chaque feature n'utilise que
/// la ou les constantes qui la concernent.
abstract final class FirestoreCollections {
  static const String users = 'users';

  // Réservées aux futures features — non utilisées tant que ces features
  // ne sont pas implémentées (voir TASKS.md).
  static const String wallets = 'wallets';
  static const String transactions = 'transactions';
  static const String deliveries = 'deliveries';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
}
