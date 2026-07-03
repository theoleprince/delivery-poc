// TODO(mapbox): remplace par ton token public "access token" Mapbox
// (https://account.mapbox.com/access-tokens) — voir README.md § "Configurer
// Mapbox". Distinct du "downloads token" (configuré côté Gradle/CocoaPods,
// jamais dans le code source).
abstract final class MapboxConfig {
  static const String accessToken = 'TODO-replace-with-mapbox-access-token';
}
