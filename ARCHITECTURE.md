# ARCHITECTURE.md

## 1. Objectif du document

Ce document décrit l'architecture technique du POC, les décisions structurantes et leur justification. Il doit être relu et validé avant chaque nouvelle fonctionnalité majeure (voir `TASKS.md` pour le suivi par feature).

État : **v1 — Fondations + Feature Authentification**.

---

## 2. Principes directeurs

- **Clean Architecture** stricte, en 3 couches par feature : `domain` (règles métier, ne dépend de rien), `data` (implémentation technique, dépend de `domain`), `presentation` (UI + state, dépend de `domain`).
- **Feature First** : chaque fonctionnalité métier est un module autonome sous `lib/features/<feature>/`, avec ses propres `domain/data/presentation`. Le couplage inter-features passe uniquement par des contrats exposés (jamais d'import direct d'un détail d'implémentation d'une autre feature).
- **Inversion de dépendances** : la couche `presentation` ne connaît que des interfaces `domain` (repositories abstraits, usecases). La couche `data` implémente ces interfaces. Riverpod fournit l'implémentation concrète au runtime (injection via providers).
- **YAGNI appliqué avec discipline** : on ne construit pas un composant, un widget ou une abstraction sans consommateur réel. Ce qui est prévu par le cahier des charges mais pas encore nécessaire est tracé dans `TASKS.md`, pas codé par anticipation.

---

## 3. Arborescence imposée

```
lib/
  core/           # briques transverses sans dépendance Flutter métier : erreurs, usecase de base, constantes
  shared/         # widgets réutilisables cross-feature (Design System appliqué)
  config/         # thème, router, initialisation Firebase, configuration d'environnement
  features/
    auth/
      domain/
        entities/
        repositories/
        usecases/
      data/
        models/
        datasources/
        repositories/
      presentation/
        providers/
        pages/
        widgets/
    delivery/     # planifié — non implémenté ce sprint
    wallet/       # planifié — non implémenté ce sprint
    tracking/     # planifié — non implémenté ce sprint
    settings/     # planifié — non implémenté ce sprint
    profile/      # planifié — non implémenté ce sprint
    map/          # planifié — non implémenté ce sprint
    notifications/# planifié — non implémenté ce sprint
```

Chaque feature future reproduit exactement le triptyque `domain/data/presentation` de `auth/`.

Détail complet : voir `PROJECT_STRUCTURE.md`.

---

## 4. Décisions techniques et justifications

### 4.1 State management — Riverpod avec génération de code (`@riverpod`)

**Décision** : `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`, complété par `hooks_riverpod` pour les widgets ayant besoin de `flutter_hooks` (ex. `TextEditingController` dans les formulaires).

**Justification** :
- Imposé par le cahier des charges (`# ETAT`).
- La génération de code donne des providers typés, sûrs à la compilation, et un mécanisme de test simple (`overrideWith`).
- Les providers Riverpod font office de **conteneur d'injection de dépendances**. Ajouter `get_it` en plus créerait deux systèmes de DI concurrents — violation de DRY/KISS. Toute dépendance (repository, datasource, usecase) est exposée via un provider.

### 4.2 Gestion des erreurs — `Failure` (union Freezed) plutôt qu'exceptions inter-couches

**Décision** : `core/error/failure.dart` définit une union scellée Freezed (`ServerFailure`, `AuthFailure`, `NetworkFailure`, `UnknownFailure`, ...). Les usecases retournent `Future<Result<T>>` où `Result<T>` est une union Freezed `Success<T> | ResultFailure`.

**Justification** :
- Le domaine reste pur et testable : pas d'exception non typée qui traverse les couches.
- La présentation peut pattern-matcher exhaustivement (`when`/`map` généré par Freezed) pour afficher un message adapté.
- Pas de dépendance externe type `dartz`/`fpdart` : non prévue au stack imposé, et une union Freezed maison suffit pour ce besoin, en cohérence avec KISS.

### 4.3 Encapsulation Firebase — au niveau datasource, pas de couche `core/services` prématurée

**Décision** : `AuthRemoteDataSource` encapsule directement les appels `FirebaseAuth` et l'écriture du document `users/{uid}` dans Firestore à l'inscription.

**Justification** :
- Le cahier des charges impose "toutes les requêtes doivent être encapsulées" — c'est satisfait au niveau datasource (aucun widget ni provider n'appelle `FirebaseAuth`/`Firestore` directement).
- Une seule feature (`auth`) touche Firebase ce sprint. Introduire une couche `core/services/firestore_service.dart` partagée maintenant serait une abstraction sans second consommateur (violation de "pas d'abstraction pour un besoin hypothétique"). **Cette couche sera introduite dès que la 2e feature Firestore sera implémentée** (probablement `wallet` ou `delivery`), pour factoriser l'accès aux collections.
- Le nom des collections est néanmoins déjà centralisé dans `core/constants/firestore_collections.dart` pour être réutilisable dès le départ sans dupliquer des chaînes littérales.

### 4.4 Navigation — GoRouter centralisé

**Décision** : `config/router/app_router.dart` déclare toutes les routes. Les chemins sont des constantes typées dans `core/constants/app_routes.dart`. Le router écoute `authStateProvider` (stream `User?`) via un `Listenable` pour rediriger automatiquement (session persistante : utilisateur connecté → home ; sinon → sign-in).

**Justification** : imposé par le cahier des charges (`# NAVIGATION`), et c'est le pattern standard GoRouter pour la redirection réactive à l'état d'authentification sans polling.

### 4.5 Design System — tokens statiques, thème dynamique reporté

**Décision** : `config/theme/` expose des classes statiques `AppColors`, `AppTypography`, `Spacing`, `Radius`, `Elevation`, assemblées dans `AppTheme.light` / `AppTheme.dark`.

**Justification** :
- Le moteur de configuration piloté par Firestore (`# PARAMETRES` : couleur principale, logo, police... modifiables à distance) est une **fonctionnalité à part entière** (`features/settings`), pas un prérequis technique du Design System. La construire maintenant serait de la sur-ingénierie anticipée sans consommateur. Elle est tracée dans `TASKS.md` et viendra lire/écraser ces tokens statiques une fois implémentée.

### 4.6 Modèles — Freezed + json_serializable, séparation stricte Entity / Model (DTO)

**Décision** : `domain/entities/user_entity.dart` (objet métier pur, Freezed sans JSON) ≠ `data/models/user_model.dart` (Freezed + `json_serializable`, avec `toEntity()`/`fromEntity()`).

**Justification** : imposé par le cahier des charges (`# MODELES`). Cela évite qu'un changement de schéma Firestore ne casse le domaine, et inversement.

### 4.7 Widgets partagés — construits à la demande

**Décision** : ce sprint ne crée que `PrimaryButton`, `SecondaryButton`, `InputField`, `LoadingWidget`, `AppErrorWidget` (nécessaires aux écrans Auth).

**Justification** : `CardWidget`, `MapWidget`, `DeliveryCard`, `WalletCard`, `TransactionCard`, `BottomNavigation`, `Toolbar`, `SearchField`, `EmptyState` n'ont aucun consommateur avant les features `delivery`/`wallet`/`map`. Les créer maintenant produirait du code mort et une divergence probable avec les besoins réels une fois la feature écrite. Ils sont listés dans `TASKS.md` et seront créés avec leur feature consommatrice, dans `lib/shared/widgets/` (jamais dupliqués dans une feature).

---

## 5. Flux Authentification (résumé)

```
SignInPage (presentation)
   -> signInControllerProvider (Riverpod)
      -> SignInUseCase (domain)
         -> AuthRepository (interface, domain)
            <- AuthRepositoryImpl (data)
               <- AuthRemoteDataSource (data) -> FirebaseAuth / Firestore
```

- `watchAuthStateProvider` expose `Stream<UserEntity?>` consommé par `app_router.dart` pour la redirection et par `SplashPage` pour la vérification de session persistante au démarrage.
- Les échecs (`FirebaseAuthException`, erreurs réseau) sont capturés dans `AuthRemoteDataSource`/`AuthRepositoryImpl` et convertis en `Failure` typée avant de remonter à la présentation.

Détail des contrats : voir `API_DOCUMENTATION.md`.

---

## 6. Tests

- **Unitaires** : chaque usecase testé avec un mock de son repository (`mocktail`). `AuthRepositoryImpl` testé avec un mock du datasource.
- **Widgets** : `SignInPage` testée avec `ProviderScope(overrides: [...])` pour injecter des contrôleurs/faux états sans toucher Firebase.
- Aucune feature n'est considérée terminée sans ses tests (règle du cahier des charges, `# TESTS`).

---

## 7. Ce qui n'est pas dans ce sprint (v1)

Voir `TASKS.md` pour le backlog complet. En résumé : `delivery`, `wallet`, `tracking`, `settings`, `profile`, `map`, `notifications`, ainsi que les widgets partagés non consommés par Auth, et la couche `core/services` Firestore partagée.

---

## 8. Sprint 2 — Feature `map` + Feature `delivery` (flux de création)

Périmètre validé avec l'utilisateur : uniquement le flux de création d'une livraison, jusqu'à la sauvegarde Firestore. Historique + Détail livraison + `tracking` sont des sprints séparés (voir `TASKS.md`).

### 8.1 Mapbox plutôt que Google Maps Flutter

`google_maps_flutter` (imposé par `CLAUDE.md` v1) nécessite l'activation de la facturation sur un projet Google Cloud pour obtenir une clé API fonctionnelle. Décision validée avec l'utilisateur (voir `CLAUDE.md` § AMENDEMENTS, 2026-07-03) : remplacé par `mapbox_maps_flutter`, dont le tier gratuit convient à un POC sans cette contrainte. Impact isolé à `lib/shared/widgets/map_widget.dart`, qui expose une interface neutre (`LatLng`/`MapMarkerData`) — le reste de l'app ne dépend jamais du SDK Mapbox directement, donc un futur changement de fournisseur resterait cantonné à ce fichier.

### 8.2 `map` est une feature à part, consommée par `delivery`

Dossier déjà réservé par l'architecture v1. `map` expose position actuelle, recherche/reverse geocoding d'adresse et calcul de trajet — capacités réutilisables par `delivery` aujourd'hui, et par `tracking` plus tard. Contrat public : ses usecases (`domain/usecases/`) et son entité `AddressEntity`, que `delivery` réutilise directement (voir 8.5) plutôt que de dupliquer un type d'adresse.

### 8.3 Trajet simulé en ligne droite, distance réelle

`GetRouteUseCase` calcule la distance avec `Geolocator.distanceBetween` (haversine, déjà dans le stack, aucune dépendance nouvelle) et renvoie une polyline à 2 points (départ→destination), affichée telle quelle sur `MapWidget`. Pas d'intégration Google/Mapbox Directions API (facturation/activation d'API supplémentaire hors scope d'un POC) — cohérent avec le principe déjà appliqué à Paiement/Wallet/Tracking dans `CLAUDE.md` ("Simulation uniquement"). Limitation connue, à remplacer par un vrai calcul d'itinéraire en production.

### 8.4 Package `geocoding`, pas de couche `data/models` pour `map`

`geocoding` (^3.0.0) complète `geolocator` pour la recherche/reverse geocoding d'adresse, sans clé API supplémentaire (geocoder natif Android/iOS). C'est un géocodeur simple, pas une API d'autocomplete à suggestions multiples classées : `searchAddress` renvoie le meilleur résultat sous forme de liste à 1 élément.

`LocationRemoteDataSource` retourne directement des entités `domain` (pas de DTO `data/models`) : contrairement à `auth`/`delivery`, il n'y a ici aucune sérialisation JSON/Firestore à isoler du domaine (voir §4.6 — la séparation Entity/Model existe pour découpler un schéma de persistance du domaine, absent ici).

### 8.5 `delivery` réutilise `AddressEntity` de `map`

`DeliveryEntity.pickup`/`destination` sont typés `AddressEntity` (feature `map`). Réutiliser le contrat public d'une autre feature plutôt que dupliquer un type équivalent est cohérent avec DRY — la règle "pas d'import direct d'un détail d'implémentation d'une autre feature" (§3) ne s'applique qu'aux détails internes (datasources, implémentations de repository), pas aux entités/usecases exposés.

### 8.6 `DeliveryDraft` (presentation) ≠ `DeliveryEntity` (domain)

Le flux de création est un formulaire multi-étapes (trajet → colis → destinataire → récapitulatif). `DeliveryDraftController` (Riverpod `Notifier`) accumule un `DeliveryDraft` (Freezed, champs tous nullable) au fil des pages, sans transiter par des arguments de route GoRouter. `DeliveryDraft.toEntity()` valide la complétude et construit la `DeliveryEntity` juste avant l'appel à `CreateDeliveryUseCase` ; le prix/durée estimés sont calculés séparément par `DeliveryPricing.estimate` (domain/services, fonction pure) et injectés dans `toEntity()`.

### 8.7 Providers Firebase partagés déplacés dans `core`

`delivery` est la 2e feature à avoir besoin de `FirebaseFirestore`. `firebaseAuthProvider`/`firestoreProvider` (auparavant définis dans `auth_providers.dart`) ont été déplacés dans `core/providers/firebase_providers.dart`, réutilisés par `auth` et `delivery`. `core/firestore/firestore_write_helpers.dart` (fonction `attachTimestamps`) et `core/firestore/server_timestamp_converter.dart` (`ServerTimestampConverter`, déplacé depuis `auth/data/models/user_model.dart`) suivent la même logique : introduits dès qu'un 2e consommateur réel existe, pas avant (voir §4.3).

### 8.8 `DeliveryPricing` : tarification simplifiée, assumée comme telle

`lib/features/delivery/domain/services/delivery_pricing.dart` calcule prix/durée à partir d'un tarif de base + tarif au km + majoration express, sans zones tarifaires ni surcharge horaire. Fonction pure (pas d'I/O, pas de repository) : ce n'est pas un usecase au sens de cette architecture, juste une règle métier déterministe. Documenté comme simplification POC, pas un moteur de tarification réel.

---

## 9. Sprint 3 — Feature `delivery` : Historique + Détail

Complète la feature `delivery` commencée au sprint 2 (flux de création). Toujours pas de `wallet`/`tracking`/`settings`/`profile`/`notifications` — voir `TASKS.md`.

### 9.1 Historique/détail en flux (`Stream`), pas en `Future`

`DeliveryRepository.watchUserDeliveries`/`watchDeliveryById` renvoient des `Stream` (comme `AuthRepository.watchAuthState`, §5), pas des `Result` enveloppant un `Future` ponctuel. Deux raisons : (1) une livraison créée pendant que l'historique est ouvert doit apparaître automatiquement (Firestore `.snapshots()`), (2) `watchDeliveryById` doit pouvoir refléter, une fois `tracking` implémenté, les mises à jour de statut en direct sans que `DeliveryDetailPage` change de mécanisme. Les erreurs de flux remontent nativement via `AsyncValue.error` côté Riverpod, sans passer par `Result` (même choix que `watchAuthState`).

### 9.2 Recherche côté client, pas de recherche plein texte

`DeliveryHistoryPage` filtre la liste déjà chargée (nom destinataire / adresse destination) en mémoire. Une vraie recherche plein texte sur Firestore nécessiterait un service tiers (Algolia, Typesense, Firestore Extensions) — hors scope d'un POC dont l'historique par utilisateur reste de taille modeste. Noté comme limitation connue (`TASKS.md`).

### 9.3 `DeliveryCard` réutilisable : entités converties en primitives à la frontière `presentation`

Comme `MapWidget`/`LatLng` (§8.1), `lib/shared/widgets/delivery_card.dart` n'accepte que des `String` déjà formatées (pas une `DeliveryEntity`) — `shared/` ne dépend jamais d'une feature (§3). `DeliveryHistoryPage` fait la conversion. Même widget potentiellement réutilisable par une future feature `wallet` (liste de transactions) si son besoin d'affichage converge.

### 9.4 `CardWidget` étendu avec `onTap`

Ajout d'un paramètre `onTap` optionnel à `CardWidget` (`InkWell` + `Card.clipBehavior: antiAlias` pour un ripple correctement rogné) plutôt que dupliquer la logique de carte dans `DeliveryCard`. Rétrocompatible (paramètre optionnel) — aucun appelant existant (`DeliverySummaryPage`, `DeliveryRoutePage`) n'est affecté.

### 9.5 Index composite Firestore requis

`watchUserDeliveries` filtre sur `senderId` (`where`) et trie sur `createdAt` (`orderBy`) : Firestore exige un index composite pour cette combinaison. Sans lui, la requête échoue au runtime avec `failed-precondition` (Firestore fournit un lien direct pour créer l'index dans le message d'erreur). Documenté dans `FIRESTORE_SCHEMA.md` — à créer une fois connecté à un vrai projet Firebase, pas gérable depuis ce dépôt.

### 9.6 Timeline minimale, cycle de vie du statut reporté

`DeliveryDetailPage` n'affiche qu'un seul événement ("Créée le ...") : `DeliveryStatus` reste figé à `pending` (voir §8, `DeliveryEntity`). Une vraie timeline (`pickedUp`, `inTransit`, `delivered`...) n'a de sens qu'avec `tracking`, qui mettra à jour le document Firestore en continu — `watchDeliveryById` (§9.1) est déjà prêt à réagir à ces changements sans modification.
