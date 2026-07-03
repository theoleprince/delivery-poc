# Changelog

Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/).

## [Unreleased]

### Added — Feature `wallet`
- Domaine : `WalletEntity`, `TransactionEntity` (+ `TransactionType`), `WalletRepository`, usecases (`EnsureWalletExistsUseCase`, `WatchWalletUseCase`, `WatchTransactionsUseCase`, `WatchTransactionByIdUseCase`, `CreateTransactionUseCase`).
- Data : `WalletModel`/`TransactionModel`, `WalletRemoteDataSource` (Firestore `wallets`/`transactions`, écritures atomiques via `runTransaction`), `WalletRepositoryImpl`.
- Presentation : `WalletPage`, `TransactionDetailPage`, provisioning automatique du wallet à la connexion (`main.dart`, bonus de bienvenue simulé de 50 €).
- Widgets partagés : `WalletCard`, `TransactionCard`.
- Routes `/wallet`, `/wallet/transactions/:id`, lien "Mon wallet" sur la home.
- **`DeliverySummaryPage`** vérifie le solde et débite le wallet quand le paiement est choisi "avant livraison" (voir `ARCHITECTURE.md` §10.3).
- Tests unitaires (usecase, repository — dont solde insuffisant) et tests widgets (`WalletCard`, `TransactionCard`).
- Note : nécessite un index composite Firestore (`uid` + `createdAt` sur `transactions`) — voir `FIRESTORE_SCHEMA.md`.

### Added — Feature `delivery` : Historique + Détail
- Domaine : `DeliveryRepository.watchUserDeliveries`/`watchDeliveryById` (flux), `WatchUserDeliveriesUseCase`, `WatchDeliveryByIdUseCase`.
- Data : requêtes Firestore `.snapshots()` sur `deliveries` (liste par expéditeur triée par date, document unique).
- Presentation : `DeliveryHistoryPage` (recherche client, filtre par type de livraison), `DeliveryDetailPage` (timeline, statut, carte Mapbox, colis, destinataire).
- Widgets partagés : `DeliveryCard`, `EmptyState`. `CardWidget` étendu avec un paramètre `onTap` optionnel.
- Routes `/delivery/history`, `/delivery/history/:id`, lien "Historique des livraisons" sur la home.
- Tests unitaires (usecase, repository) et test widget (`DeliveryCard`).
- Note : nécessite un index composite Firestore (`senderId` + `createdAt`) — voir `FIRESTORE_SCHEMA.md`.

### Changed
- Remplacement de `google_maps_flutter` par `mapbox_maps_flutter` dans `# STACK` (`CLAUDE.md` § AMENDEMENTS, 2026-07-03) : évite la facturation Google Cloud obligatoire pour ce POC. Voir `ARCHITECTURE.md` §8.1.
- `firebaseAuthProvider`/`firestoreProvider` déplacés de `auth_providers.dart` vers `core/providers/firebase_providers.dart` (partagés avec `delivery`).
- `ServerTimestampConverter` déplacé de `auth/data/models/user_model.dart` vers `core/firestore/server_timestamp_converter.dart` (partagé avec `delivery`).
- `AuthRemoteDataSourceImpl.signUp` utilise désormais `core/firestore/firestore_write_helpers.dart#attachTimestamps` au lieu d'horodatages en dur.

### Added — Feature `map`
- Domaine : `CoordinatesEntity`, `AddressEntity`, `RouteEntity`, interface `LocationRepository`, usecases (`GetCurrentPositionUseCase`, `SearchAddressUseCase`, `ReverseGeocodeUseCase`, `GetRouteUseCase`).
- Data : `LocationRemoteDataSource` (Geolocator + geocoding), `LocationRepositoryImpl`.
- Presentation : providers Riverpod, `LocationPickerPage` (recherche d'adresse + sélection sur carte).
- Widget partagé `MapWidget` (`lib/shared/widgets/map_widget.dart`, Mapbox).
- Tests unitaires (usecase, repository).

### Added — Feature `delivery` (flux de création)
- Domaine : `PackageEntity`, `RecipientEntity`, `DeliveryEntity` (+ enums `DeliveryType`, `PaymentMethod`, `DeliveryStatus`), interface `DeliveryRepository`, `CreateDeliveryUseCase`, service pur `DeliveryPricing`.
- Data : `AddressModel`/`PackageModel`/`RecipientModel`/`DeliveryModel` (Freezed + json_serializable), `DeliveryRemoteDataSource` (Firestore `deliveries/{id}`), `DeliveryRepositoryImpl`.
- Presentation : `DeliveryDraftController` (état multi-étapes), `CreateDeliveryController`, pages `DeliveryRoutePage`, `PackageInfoPage`, `RecipientInfoPage`, `DeliverySummaryPage`.
- Widgets partagés : `SearchField`, `CardWidget`.
- Bouton "Créer une livraison" sur la home, routes `/delivery/route`, `/delivery/package`, `/delivery/recipient`, `/delivery/summary`.
- Tests unitaires (usecase, repository, `DeliveryPricing`) et test widget (`PackageInfoPage`).

### Added — Fondations
- Documents structurants : `ARCHITECTURE.md`, `PROJECT_STRUCTURE.md`, `FIRESTORE_SCHEMA.md`, `README.md`, `TASKS.md`, `API_DOCUMENTATION.md`.
- Scaffold technique : `pubspec.yaml`, `analysis_options.yaml`.
- `core/` : gestion d'erreurs typées (`Failure`, `Result`), classe de base `UseCase`, constantes (routes, collections Firestore).
- `config/` : Design System (couleurs, typographie, spacing, radius, elevation, thèmes clair/sombre), routing GoRouter centralisé, placeholder de configuration Firebase.
- `shared/widgets/` : `PrimaryButton`, `SecondaryButton`, `InputField`, `LoadingWidget`, `AppErrorWidget`.

### Added — Feature Authentification
- Domaine : `UserEntity`, interface `AuthRepository`, usecases (`SignInUseCase`, `SignUpUseCase`, `SignOutUseCase`, `ResetPasswordUseCase`, `WatchAuthStateUseCase`).
- Data : `UserModel` (Freezed + json_serializable), `AuthRemoteDataSource` (Firebase Auth + Firestore `users/{uid}`), `AuthRepositoryImpl`.
- Presentation : providers Riverpod (état d'authentification en stream, contrôleurs sign-in/sign-up/reset), pages `SplashPage`, `SignInPage`, `SignUpPage`, `ForgotPasswordPage`.
- Tests unitaires (usecases, repository) et test widget (`SignInPage`).

## [0.1.0] — Initialisation

- Ajout de `CLAUDE.md` (cahier des charges).
