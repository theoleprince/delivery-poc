# API_DOCUMENTATION.md

Documente les contrats `domain` (repositories, usecases) exposés par chaque feature. Complété à chaque nouvelle feature implémentée.

---

## Feature `auth`

### `AuthRepository` (interface — `lib/features/auth/domain/repositories/auth_repository.dart`)

| Membre | Signature | Description |
|---|---|---|
| `watchAuthState` | `Stream<UserEntity?> watchAuthState()` | Émet l'utilisateur courant (`null` si déconnecté), y compris la session persistante restaurée au démarrage. |
| `signIn` | `Future<Result<UserEntity>> signIn({required String email, required String password})` | Connexion email/mot de passe. |
| `signUp` | `Future<Result<UserEntity>> signUp({required String email, required String password, String? displayName})` | Inscription ; crée aussi le document `users/{uid}` (voir `FIRESTORE_SCHEMA.md`). |
| `signOut` | `Future<Result<void>> signOut()` | Déconnexion. |
| `resetPassword` | `Future<Result<void>> resetPassword({required String email})` | Envoie un email de réinitialisation de mot de passe. |

Implémentation : `AuthRepositoryImpl` (`lib/features/auth/data/repositories/auth_repository_impl.dart`), qui délègue à `AuthRemoteDataSource` et convertit les `FirebaseAuthException` en `Failure` typée (voir `ARCHITECTURE.md` §4.2).

### Usecases (`lib/features/auth/domain/usecases/`)

| Usecase | Params | Retour | Description |
|---|---|---|---|
| `SignInUseCase` | `SignInParams({email, password})` | `Result<UserEntity>` | Encapsule `AuthRepository.signIn`. |
| `SignUpUseCase` | `SignUpParams({email, password, displayName})` | `Result<UserEntity>` | Encapsule `AuthRepository.signUp`. |
| `SignOutUseCase` | `NoParams` | `Result<void>` | Encapsule `AuthRepository.signOut`. |
| `ResetPasswordUseCase` | `ResetPasswordParams({email})` | `Result<void>` | Encapsule `AuthRepository.resetPassword`. |
| `WatchAuthStateUseCase` | — | `Stream<UserEntity?>` | N'implémente pas `UseCase<Type, Params>` (contrat `Future`-based) car il expose un flux continu — voir commentaire dans le fichier source. |

### Providers Riverpod (`lib/features/auth/presentation/providers/auth_providers.dart`)

| Provider | Type | Rôle |
|---|---|---|
| `authStateProvider` | `StreamProvider<UserEntity?>` (via `authStateProvider` codegen) | Source de vérité consommée par `app_router.dart` (redirection) et `SplashPage`. |
| `signInControllerProvider` | `AsyncNotifierProvider<SignInController, void>` | État de la tentative de connexion en cours (loading/data/error), consommé par `SignInPage`. |
| `signUpControllerProvider` | idem | Consommé par `SignUpPage`. |
| `resetPasswordControllerProvider` | idem | Consommé par `ForgotPasswordPage`. |

### Erreurs

Tous les échecs remontent sous forme de `Failure` (union Freezed, `lib/core/error/failure.dart`) : `AuthFailure`, `NetworkFailure`, `UnknownFailure`. Les messages sont déjà traduits en français dans `AuthRepositoryImpl._authMessage` — la présentation n'a pas à interpréter les codes `FirebaseAuthException`.

---

## Feature `map`

### `LocationRepository` (interface — `lib/features/map/domain/repositories/location_repository.dart`)

| Membre | Signature | Description |
|---|---|---|
| `getCurrentPosition` | `Future<Result<CoordinatesEntity>> getCurrentPosition()` | Position actuelle (gère permissions + service désactivé). |
| `searchAddress` | `Future<Result<List<AddressEntity>>> searchAddress(String query)` | Géocodage direct. Renvoie 0 ou 1 résultat — `geocoding` n'est pas une API d'autocomplete à suggestions multiples (voir `ARCHITECTURE.md` §8.4). |
| `reverseGeocode` | `Future<Result<AddressEntity>> reverseGeocode(CoordinatesEntity coordinates)` | Adresse lisible à partir de coordonnées. |
| `getRoute` | `Future<Result<RouteEntity>> getRoute({required CoordinatesEntity origin, required CoordinatesEntity destination})` | Distance haversine réelle + polyline à 2 points (trajet simulé, voir §8.3). |

Implémentation : `LocationRepositoryImpl`, qui délègue à `LocationRemoteDataSource` (encapsule `Geolocator` + `geocoding`).

### Usecases (`lib/features/map/domain/usecases/`)

| Usecase | Params | Retour |
|---|---|---|
| `GetCurrentPositionUseCase` | `NoParams` | `Result<CoordinatesEntity>` |
| `SearchAddressUseCase` | `SearchAddressParams({query})` | `Result<List<AddressEntity>>` |
| `ReverseGeocodeUseCase` | `ReverseGeocodeParams({coordinates})` | `Result<AddressEntity>` |
| `GetRouteUseCase` | `GetRouteParams({origin, destination})` | `Result<RouteEntity>` |

### Widget partagé

`lib/shared/widgets/map_widget.dart` (`MapWidget`) — enveloppe Mapbox derrière une interface neutre (`LatLng`, `MapMarkerData`). Voir `ARCHITECTURE.md` §8.1 pour la justification du choix Mapbox.

### Réutilisation par d'autres features

`AddressEntity` et `CoordinatesEntity` (contrat public de `map`) sont directement réutilisées par `delivery` (`DeliveryEntity.pickup`/`destination`) — voir `ARCHITECTURE.md` §8.5.

---

## Feature `delivery` (flux de création)

### `DeliveryRepository` (interface — `lib/features/delivery/domain/repositories/delivery_repository.dart`)

| Membre | Signature | Description |
|---|---|---|
| `createDelivery` | `Future<Result<DeliveryEntity>> createDelivery(DeliveryEntity delivery)` | Persiste la livraison dans `deliveries/{id}` (voir `FIRESTORE_SCHEMA.md`) et renvoie l'entité avec son `id`. |
| `watchUserDeliveries` | `Stream<List<DeliveryEntity>> watchUserDeliveries(String senderId)` | Historique en flux, les plus récentes en premier — voir `ARCHITECTURE.md` §9.1 (nécessite un index composite Firestore, §9.5). |
| `watchDeliveryById` | `Stream<DeliveryEntity?> watchDeliveryById(String id)` | Détail en flux (`null` si absent), prêt pour les mises à jour de statut de `tracking` (planifié). |

### Usecases

| Usecase | Params | Retour |
|---|---|---|
| `CreateDeliveryUseCase` (`domain/usecases/create_delivery_usecase.dart`) | `CreateDeliveryParams({delivery})` | `Result<DeliveryEntity>` |
| `WatchUserDeliveriesUseCase` | `String senderId` | `Stream<List<DeliveryEntity>>` — pas `UseCase<Type, Params>` (flux, pas `Future`), même raison que `WatchAuthStateUseCase`. |
| `WatchDeliveryByIdUseCase` | `String id` | `Stream<DeliveryEntity?>` |

### Service domaine pur

`DeliveryPricing.estimate({required double distanceMeters, required DeliveryType deliveryType})` → `DeliveryEstimate(price, durationMinutes)` — calcul déterministe sans I/O, volontairement simplifié (voir `ARCHITECTURE.md` §8.8).

### Providers Riverpod (`lib/features/delivery/presentation/providers/`)

| Provider | Type | Rôle |
|---|---|---|
| `deliveryDraftControllerProvider` | `NotifierProvider<DeliveryDraftController, DeliveryDraft>` | Accumule les étapes du formulaire (trajet, colis, destinataire, type, paiement) — voir `ARCHITECTURE.md` §8.6. |
| `createDeliveryControllerProvider` | `AsyncNotifierProvider<CreateDeliveryController, DeliveryEntity?>` | Déclenche `CreateDeliveryUseCase` depuis `DeliverySummaryPage`. |
| `userDeliveriesProvider(senderId)` | `StreamProvider.family<List<DeliveryEntity>, String>` | Consommé par `DeliveryHistoryPage`. |
| `deliveryByIdProvider(id)` | `StreamProvider.family<DeliveryEntity?, String>` | Consommé par `DeliveryDetailPage`. |

### Flux de pages

`DeliveryRoutePage` (`/delivery/route`) → `PackageInfoPage` (`/delivery/package`) → `RecipientInfoPage` (`/delivery/recipient`) → `DeliverySummaryPage` (`/delivery/summary`). `LocationPickerPage` (feature `map`) est poussée via `Navigator` standard (pas une route GoRouter dédiée) depuis `DeliveryRoutePage`, deux fois (départ, destination).

`DeliveryHistoryPage` (`/delivery/history`, recherche client + filtre par type) → `DeliveryDetailPage` (`/delivery/history/:id`, timeline/statut/carte/colis/destinataire).

### Widgets partagés ajoutés

`DeliveryCard` (`lib/shared/widgets/delivery_card.dart`) et `EmptyState` (`lib/shared/widgets/empty_state.dart`) — voir `ARCHITECTURE.md` §9.3. `CardWidget` étend son API avec un `onTap` optionnel (§9.4).

---

## Features suivantes

Non implémentées — voir `TASKS.md` : `wallet`, `tracking`, `settings`, `profile`, `notifications`. Chaque feature ajoutera sa section ici au moment de son implémentation.
