# TASKS.md

Backlog du projet, organisé par feature, suivant la méthode imposée par `CLAUDE.md` (une feature à la fois : Analyse → Architecture → Plan → Implémentation → Tests → Optimisation → Documentation).

Légende : `[x]` fait · `[ ]` à faire · `[~]` partiellement fait (voir note)

---

## Sprint courant — Fondations + Authentification

- [x] `ARCHITECTURE.md`, `PROJECT_STRUCTURE.md`, `FIRESTORE_SCHEMA.md`, `README.md`, `CHANGELOG.md`, `TASKS.md`, `API_DOCUMENTATION.md`
- [x] Scaffold technique : `pubspec.yaml`, `analysis_options.yaml`, `lib/core`, `lib/config` (theme/router/firebase placeholder), `lib/main.dart`
- [x] Design System (tokens statiques) : `AppColors`, `AppTypography`, `Spacing`, `Radius`, `Elevation`, `AppTheme` (light/dark)
- [x] Widgets partagés (sous-ensemble consommé par Auth) : `PrimaryButton`, `SecondaryButton`, `InputField`, `LoadingWidget`, `AppErrorWidget`
- [x] Feature **Authentification** complète (domain/data/presentation) : connexion, inscription, déconnexion, reset password, session persistante
- [x] Tests unitaires (usecases, repository) + test widget (SignInPage) pour Auth
- [ ] Exécution réelle (côté utilisateur, SDK Flutter requis) : `flutter create .`, `pub get`, `build_runner`, `flutter analyze`, `flutter test`
- [ ] Connexion à un vrai projet Firebase (`flutterfire configure`) — hors scope tant qu'aucun projet n'est fourni

---

## Sprint 2 — Feature `map` + Feature `delivery` (flux de création)

- [x] Décision + amendement `CLAUDE.md` : Mapbox plutôt que Google Maps Flutter (facturation Google Cloud évitée pour ce POC)
- [x] Feature **`map`** complète : position actuelle, recherche/reverse geocoding d'adresse, calcul de trajet (distance réelle, polyline simulée en ligne droite), `LocationPickerPage`
- [x] Feature **`delivery`** — flux de création complet : trajet (via `map`), colis, destinataire, récapitulatif (type de livraison, mode de paiement, estimation prix/durée), sauvegarde Firestore (`deliveries/{id}`)
- [x] Widgets partagés : `MapWidget` (Mapbox), `SearchField`, `CardWidget`
- [x] `core/providers/firebase_providers.dart` (Firebase partagé), `core/firestore/firestore_write_helpers.dart` (`attachTimestamps`), `core/firestore/server_timestamp_converter.dart` — introduits à la 2e feature Firestore, `auth` refactorée pour les réutiliser
- [x] Tests unitaires (usecases `map`/`delivery`, repositories, `DeliveryPricing`) + test widget (`PackageInfoPage`)
- [x] Docs mises à jour : `ARCHITECTURE.md` §8, `FIRESTORE_SCHEMA.md` (`deliveries`), `API_DOCUMENTATION.md`, `README.md` (setup Mapbox/geocoding)
- [ ] Exécution réelle (côté utilisateur) : `flutter pub get` (récupère `mapbox_maps_flutter`/`geocoding`), `build_runner`, `flutter analyze`, `flutter test`
- [ ] Configuration native de la clé Mapbox (voir `README.md`) — bloquant pour tester la carte réellement

---

## Sprint 3 — Feature `delivery` : Historique + Détail

- [x] Domain : `DeliveryRepository.watchUserDeliveries`/`watchDeliveryById` (flux), `WatchUserDeliveriesUseCase`, `WatchDeliveryByIdUseCase`
- [x] Data : `DeliveryRemoteDataSource`/`DeliveryRepositoryImpl` — requêtes Firestore `.snapshots()` (liste filtrée + document unique)
- [x] Presentation : `DeliveryHistoryPage` (liste temps réel, recherche client, filtre par type), `DeliveryDetailPage` (timeline minimale, statut, carte, colis, destinataire)
- [x] Widgets partagés : `DeliveryCard`, `EmptyState` ; `CardWidget` étendu avec `onTap`
- [x] Routing : `/delivery/history`, `/delivery/history/:id`, lien "Historique" depuis la home
- [x] Tests unitaires (usecase, repository — mapping de flux) + test widget (`DeliveryCard`)
- [x] Docs mises à jour : `ARCHITECTURE.md` §9, `FIRESTORE_SCHEMA.md` (index composite requis), `API_DOCUMENTATION.md`
- [ ] Exécution réelle (côté utilisateur) : `flutter analyze`, `flutter test`
- [ ] Créer l'index composite Firestore (`senderId` + `createdAt`) une fois un vrai projet connecté — voir `FIRESTORE_SCHEMA.md`

**Feature `delivery` considérée complète** (création + historique + détail). Le cycle de vie du statut (`DeliveryStatus`) reste à faire avec `tracking`.

---

## Sprint 4 — Feature `wallet`

- [x] Domain : `WalletEntity`, `TransactionEntity` (+ enum `TransactionType`), `WalletRepository`, usecases (`EnsureWalletExistsUseCase`, `WatchWalletUseCase`, `WatchTransactionsUseCase`, `WatchTransactionByIdUseCase`, `CreateTransactionUseCase`)
- [x] Data : `WalletModel`/`TransactionModel`, `WalletRemoteDataSource` (Firestore `wallets`/`transactions`, écritures atomiques via `runTransaction`), `WalletRepositoryImpl`
- [x] Presentation : `WalletPage` (solde + historique), `TransactionDetailPage` (+ lien vers la livraison associée)
- [x] Provisioning automatique réactif à la connexion (`main.dart`), idempotent, bonus de bienvenue simulé (50 €)
- [x] Widgets partagés : `WalletCard`, `TransactionCard`
- [x] Routing : `/wallet`, `/wallet/transactions/:id`, lien "Mon wallet" depuis la home
- [x] **Intégration `delivery` ↔ `wallet`** : paiement "avant livraison" vérifie le solde puis débite le wallet à la confirmation (voir `ARCHITECTURE.md` §10.3)
- [x] Tests unitaires (usecase, repository — dont solde insuffisant) + tests widgets (`WalletCard`, `TransactionCard`)
- [x] Docs mises à jour : `ARCHITECTURE.md` §10, `FIRESTORE_SCHEMA.md` (`wallets`/`transactions` + index composite), `API_DOCUMENTATION.md`
- [ ] Exécution réelle (côté utilisateur) : `flutter analyze`, `flutter test`
- [ ] Créer l'index composite Firestore (`uid` + `createdAt` sur `transactions`) une fois un vrai projet connecté

---

## Sprint 5 — Feature `tracking`

- [x] Domain `delivery` étendu : `DeliveryStatus` (`pending`/`pickedUp`/`inTransit`/`delivered`), `DeliveryEntity.courierPosition`, `DeliveryRepository.updateTrackingState`
- [x] Data `delivery` étendue : `DeliveryModel.courierLatitude`/`courierLongitude`, `DeliveryRemoteDataSource.updateTrackingState`, `DeliveryRepositoryImpl.updateTrackingState`
- [x] Feature **`tracking`** : `SimulateDeliveryTrackingUseCase` (simulation client, 12 étapes), `TrackDeliveryController`, `TrackingPage` (marqueur animé)
- [x] **Correctif `MapWidget`** : diffing des marqueurs en place (id-based), `LatLng`/`MapMarkerData` avec égalité de valeur, `LatLng.lerp` — nécessaire pour l'animation fluide (voir `ARCHITECTURE.md` §11.3)
- [x] `DeliveryDetailPage` : statut réel affiché, bouton "Suivre en temps réel", marqueur livreur sur la carte si suivi démarré
- [x] `deliveryStatusLabel` extrait en helper partagé (`delivery`/`tracking`) pour éviter la triplication
- [x] Routing : `/delivery/history/:id/tracking`
- [x] Tests unitaires (`SimulateDeliveryTrackingUseCase` avec `stepInterval` injectable, `DeliveryRepositoryImpl.updateTrackingState`)
- [x] Docs mises à jour : `ARCHITECTURE.md` §11, `FIRESTORE_SCHEMA.md` (`deliveries` : nouveaux statuts + champs courier), `API_DOCUMENTATION.md`
- [ ] Exécution réelle (côté utilisateur) : `flutter analyze`, `flutter test` — `map_widget.dart` en particulier (API Mapbox non compilée ici)

**Toutes les fonctionnalités listées dans `CLAUDE.md` sont maintenant couvertes sauf `settings`, `profile` et `notifications`.**

---

## Backlog — Features non démarrées

### `settings` (Paramètres)
- [ ] Analyse + Architecture
- [ ] Moteur de configuration dynamique lu depuis Firestore (nom app, logo, couleur principale, dark mode, position menu, icônes, police, devise, activation wallet/tracking/notifications/paiement)
- [ ] Mise à jour automatique de l'app à la modification des paramètres

### `profile` (Profil)
- [ ] Analyse + Architecture
- [ ] Extension du document `users/{uid}` créé par `auth` (photo, préférences, adresses)

### `notifications`
- [ ] Analyse + Architecture
- [ ] Intégration Firebase Cloud Messaging, collection `notifications`

### Widgets partagés restants (à construire avec leur feature consommatrice)
- [ ] `BottomNavigation`, `Toolbar`

### Limitations connues à lever plus tard
- [ ] `GetRouteUseCase` (feature `map`) : remplacer la polyline en ligne droite par un vrai calcul d'itinéraire (Directions API) — voir `ARCHITECTURE.md` §8.3
- [ ] `DeliveryPricing` : remplacer le calcul simplifié par un vrai moteur de tarification (zones, surcharge horaire) — voir `ARCHITECTURE.md` §8.8
- [ ] Débit wallet après création de livraison : pas de saga/transaction distribuée entre `deliveries` et `wallets`/`transactions` (nécessiterait une Cloud Function) — voir `ARCHITECTURE.md` §10.3
- [ ] `SimulateDeliveryTrackingUseCase` : simulation pilotée par l'app expéditeur, pas par un vrai livreur/service serveur — s'arrête si l'app est fermée. Une vraie plateforme utiliserait la position GPS du livreur ou une Cloud Function — voir `ARCHITECTURE.md` §11.1
- [ ] Timeline détaillée des changements de statut (horodatage de chaque étape) : seul le statut courant est stocké, pas un historique d'événements — voir `ARCHITECTURE.md` §11.4

---

## Règle de mise à jour

Chaque nouvelle feature démarrée doit d'abord mettre à jour ce fichier (cases cochées au fil de l'avancement) et `CHANGELOG.md`, conformément à `# METHODE DE TRAVAIL` dans `CLAUDE.md`.
