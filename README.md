# POC Uber-like — Plateforme de livraison (Flutter + Firebase)

POC démontrant une architecture Flutter/Firebase professionnelle pour une plateforme de livraison type Uber/Yango/Glovo. Voir `ARCHITECTURE.md` pour les décisions techniques et `CLAUDE.md` pour le cahier des charges complet.

État actuel : **Fondations + Authentification + Livraison (flux de création) + Carte/Géolocalisation**. Voir `TASKS.md` pour le reste du backlog.

---

## Prérequis

- Flutter SDK (stable) installé et dans le `PATH`.
- Un compte Firebase + le CLI `firebase-tools` et `flutterfire_cli` pour la configuration réelle.
- Un compte Mapbox (gratuit) pour la carte — voir étape 5. `google_maps_flutter` a été remplacé par `mapbox_maps_flutter` pour éviter la facturation Google Cloud obligatoire sur ce POC (voir `CLAUDE.md` § AMENDEMENTS et `ARCHITECTURE.md` §8.1).

> Ce dépôt a été initialisé **sans** exécuter le SDK Flutter (non disponible dans l'environnement de génération). Le code Dart (`lib/`, `test/`, `pubspec.yaml`) est complet, mais les dossiers plateformes (`android/`, `ios/`, `web/`, etc.) n'existent pas encore. Suis l'étape 1 ci-dessous avant toute autre chose.

## Installation

### 1. Générer les dossiers plateformes

Depuis la racine du projet :

```bash
flutter create . --org com.pocuber --project-name poc_uber
```

`flutter create .` sur un dossier contenant déjà `pubspec.yaml` et `lib/main.dart` **ne les écrase pas silencieusement** : si un prompt d'écrasement apparaît pour `pubspec.yaml` ou `lib/main.dart`, réponds **non** (garder les fichiers existants) — seuls les dossiers plateformes manquants (`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`) doivent être créés.

### 2. Récupérer les dépendances

```bash
flutter pub get
```

### 3. Générer le code (Freezed / json_serializable / Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

À relancer à chaque modification d'un fichier `@freezed`, `@JsonSerializable` ou `@riverpod`.

### 4. Connecter un vrai projet Firebase

`lib/config/firebase/firebase_options.dart` est un **placeholder** (valeurs factices, clairement marquées `TODO`). L'app ne pourra pas s'authentifier tant qu'il n'est pas remplacé par une vraie configuration :

```bash
firebase login
flutterfire configure
```

Active au minimum, dans la console Firebase du projet choisi :
- **Authentication** → méthode Email/Password.
- **Cloud Firestore** → mode production ou test, avec des règles de sécurité (voir `FIRESTORE_SCHEMA.md`).

### 5. Configurer Mapbox

`mapbox_maps_flutter` nécessite **deux tokens distincts** (source fréquente de confusion) :

1. **Un "secret downloads token"**, pour que Gradle/CocoaPods puissent télécharger le SDK natif Mapbox lui-même (dépôt privé). À créer sur [account.mapbox.com/access-tokens](https://account.mapbox.com/access-tokens) avec le scope `Downloads:Read`, puis :
   - Android : ajoute-le dans `~/.gradle/gradle.properties` (créer le fichier s'il n'existe pas) :
     ```properties
     MAPBOX_DOWNLOADS_TOKEN=sk.xxx...
     ```
   - iOS/macOS : ajoute-le dans `~/.netrc` :
     ```
     machine api.mapbox.com
       login mapbox
       password sk.xxx...
     ```
2. **Un token public "access token"**, utilisé au runtime pour afficher la carte. `lib/main.dart` appelle déjà `MapboxOptions.setAccessToken(MapboxConfig.accessToken)` — remplace la valeur placeholder dans `lib/config/mapbox/mapbox_config.dart` (marquée `TODO`) par ton vrai token public.

Ces deux étapes ne peuvent être faites que sur ta machine, une fois `flutter create .` exécuté (étape 1) : les fichiers `~/.gradle/gradle.properties`/`~/.netrc` sont hors du dépôt par nature.

`geocoding` (recherche/reverse geocoding d'adresse) n'a besoin d'aucune clé : il utilise le geocoder natif Android (Google Play services) / iOS (Apple), déjà disponible.

### 6. Vérifier

```bash
flutter analyze
flutter test
flutter run
```

---

## Structure du projet

Voir `PROJECT_STRUCTURE.md` pour l'arborescence complète et les conventions de nommage.

## Documentation

| Document | Contenu |
|---|---|
| `ARCHITECTURE.md` | Décisions techniques et justifications |
| `PROJECT_STRUCTURE.md` | Arborescence de référence |
| `FIRESTORE_SCHEMA.md` | Schéma des collections Firestore |
| `API_DOCUMENTATION.md` | Contrats domain (usecases, repositories) par feature |
| `TASKS.md` | Backlog par feature, ce qui est fait / à faire |
| `CHANGELOG.md` | Historique des changements |
