# FIRESTORE_SCHEMA.md

## Statut

Implémentées : `users` (feature `auth`), `deliveries` (feature `delivery`), `wallets`/`transactions` (feature `wallet`). Les autres collections sont **planifiées** : leur schéma sera écrit au moment de l'implémentation de la feature correspondante, pour éviter de documenter une structure qui n'a pas encore été validée par du code réel.

---

## `users/{uid}`

Créé par `AuthRemoteDataSource.signUp` (feature `auth`) au moment de l'inscription. `{uid}` = `FirebaseAuth` UID.

| Champ        | Type      | Description                                      |
|--------------|-----------|---------------------------------------------------|
| `uid`        | string    | Identifiant Firebase Auth (dupliqué en champ pour les requêtes/index) |
| `email`      | string    | Email de l'utilisateur                            |
| `displayName`| string?   | Nom affiché, optionnel à l'inscription             |
| `createdAt`  | timestamp | Date de création du compte (server timestamp)      |
| `updatedAt`  | timestamp | Dernière mise à jour du document                   |

Notes :
- Ce document est volontairement minimal : c'est l'identité de base créée par `auth`. La feature `profile` (planifiée) l'étendra avec photo, préférences, adresses favorites, etc. — sans dupliquer ces champs.
- Règles de sécurité Firestore : à définir lors de la configuration réelle du projet Firebase (`firestore.rules`, hors scope de ce sprint car aucun projet Firebase réel n'est encore connecté — voir `README.md`).

---

## `deliveries/{id}`

Créé par `DeliveryRemoteDataSource.createDelivery` (feature `delivery`) à la confirmation du flux de création. `{id}` = ID auto-généré Firestore.

| Champ                      | Type      | Description |
|-----------------------------|-----------|-------------|
| `senderId`                  | string    | UID de l'expéditeur (`FirebaseAuth`) |
| `pickup`                    | map       | `{ formattedAddress, latitude, longitude }` |
| `destination`                | map       | `{ formattedAddress, latitude, longitude }` |
| `package`                    | map       | `{ name, description, weightKg, dimensions: { lengthCm, widthCm, heightCm }, declaredValue, specialInstructions? }` |
| `recipient`                  | map       | `{ name, phone, address, instructions? }` |
| `distanceMeters`             | number    | Distance haversine départ→destination (voir ARCHITECTURE.md §8.3 : trajet simulé en ligne droite) |
| `estimatedPrice`             | number    | Prix estimé (voir `DeliveryPricing`, simplifié — §8.8) |
| `estimatedDurationMinutes`   | number    | Durée estimée en minutes |
| `deliveryType`               | string    | `standard` \| `express` |
| `paymentMethod`              | string    | `beforeDelivery` \| `onDelivery` (paiement simulé, voir `CLAUDE.md`) |
| `status`                     | string    | `pending` \| `pickedUp` \| `inTransit` \| `delivered` — piloté par `tracking` (`updateTrackingState`, voir `ARCHITECTURE.md` §11.2) |
| `courierLatitude`            | number?   | Position simulée du livreur — absent tant que le suivi n'a pas démarré |
| `courierLongitude`           | number?   | idem |
| `createdAt`                  | timestamp | Date de création (server timestamp) |
| `updatedAt`                  | timestamp | Dernière mise à jour (création, paiement wallet non inclus, mise à jour de suivi) |

Notes :
- `pickup`/`destination` sont des adresses embarquées (pas une référence à une autre collection) : elles ne changent jamais après création, pas besoin de normalisation.
- `courierLatitude`/`courierLongitude` sont des champs plats (pas un `map` imbriqué) : réécrits très fréquemment pendant une simulation de suivi (toutes les 2 secondes), pas besoin d'un modèle dédié pour 2 doubles.
- Règles de sécurité Firestore : toujours à définir lors de la configuration réelle du projet (voir `README.md`).

**Index composite requis** : l'historique (`DeliveryRepository.watchUserDeliveries`) filtre sur `senderId` et trie sur `createdAt` — Firestore exige un index composite pour cette combinaison `where` + `orderBy` sur des champs différents. À créer dans la console Firebase (Firestore → Indexes) une fois le projet réel connecté :

| Collection   | Champs indexés                          |
|--------------|------------------------------------------|
| `deliveries` | `senderId` (Ascending), `createdAt` (Descending) |

Sans cet index, la requête échoue au runtime avec `failed-precondition` — Firestore fournit alors un lien direct dans le message d'erreur pour le créer en un clic.

---

## `wallets/{uid}`

Créé par `WalletRemoteDataSource.ensureWalletExists` (feature `wallet`) à la première connexion de l'utilisateur (voir `ARCHITECTURE.md` §10.1). `{uid}` = `FirebaseAuth` UID (même identifiant que `users/{uid}`).

| Champ       | Type      | Description |
|-------------|-----------|-------------|
| `uid`       | string    | Identifiant Firebase Auth (dupliqué en champ pour les requêtes) |
| `balance`   | number    | Solde courant, modifié uniquement via `runTransaction` (§10.2) |
| `createdAt` | timestamp | Date de création |
| `updatedAt` | timestamp | Dernière mise à jour (à chaque transaction) |

## `transactions/{id}`

Créé par `WalletRemoteDataSource.createTransaction` (débit/crédit) ou `ensureWalletExists` (bonus de bienvenue). `{id}` = ID auto-généré Firestore.

| Champ                | Type      | Description |
|-----------------------|-----------|-------------|
| `uid`                  | string    | UID du propriétaire du wallet |
| `type`                 | string    | `credit` \| `debit` |
| `amount`               | number    | Montant (toujours positif ; le signe est déduit de `type`) |
| `description`          | string    | Libellé affiché (ex. "Bonus de bienvenue", "Livraison vers ...") |
| `relatedDeliveryId`    | string?   | ID du document `deliveries` associé, si le débit provient d'un paiement de livraison (voir §10.3) |
| `createdAt`            | timestamp | Date de la transaction |

Notes :
- `wallets` et `transactions` sont deux collections top-level distinctes (pas de sous-collection), conformément à `CLAUDE.md` (`# FIRESTORE`).
- Solde et transaction sont toujours écrits ensemble dans une `runTransaction` Firestore — jamais l'un sans l'autre (§10.2).
- Règles de sécurité Firestore : toujours à définir lors de la configuration réelle du projet.

**Index composite requis** (même besoin que `deliveries`, §ci-dessus) : l'historique des transactions filtre sur `uid` et trie sur `createdAt`.

| Collection      | Champs indexés |
|-----------------|----------------|
| `transactions`  | `uid` (Ascending), `createdAt` (Descending) |

---

## Collections planifiées (non implémentées)

| Collection      | Feature propriétaire | Statut |
|-----------------|----------------------|--------|
| `settings`      | `settings`             | planifié |
| `notifications` | `notifications`        | planifié |

Chacune sera documentée ici avec son schéma complet au moment de son implémentation, suivant la méthode imposée (Analyse → Architecture → ... → Documentation) décrite dans `CLAUDE.md`.
