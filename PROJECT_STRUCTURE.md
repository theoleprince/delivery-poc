# PROJECT_STRUCTURE.md

Arborescence de référence du projet (état après le sprint "Fondations + Auth"). Les dossiers marqués `(vide/planifié)` existent en tant qu'emplacement réservé par l'architecture imposée mais ne contiennent pas encore de code.

```
POC_uber/
├── ARCHITECTURE.md
├── README.md
├── FIRESTORE_SCHEMA.md
├── PROJECT_STRUCTURE.md
├── API_DOCUMENTATION.md
├── CHANGELOG.md
├── TASKS.md
├── CLAUDE.md
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── error/
│   │   │   ├── failure.dart
│   │   │   └── result.dart
│   │   ├── usecase/
│   │   │   └── usecase.dart
│   │   └── constants/
│   │       ├── app_routes.dart
│   │       └── firestore_collections.dart
│   ├── shared/
│   │   └── widgets/
│   │       ├── primary_button.dart
│   │       ├── secondary_button.dart
│   │       ├── input_field.dart
│   │       ├── loading_widget.dart
│   │       └── app_error_widget.dart
│   ├── config/
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── spacing.dart
│   │   │   ├── radius.dart
│   │   │   ├── elevation.dart
│   │   │   └── app_theme.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── firebase/
│   │       └── firebase_options.dart      # placeholder — voir README
│   └── features/
│       ├── auth/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── user_entity.dart
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository.dart
│       │   │   └── usecases/
│       │   │       ├── sign_in_usecase.dart
│       │   │       ├── sign_up_usecase.dart
│       │   │       ├── sign_out_usecase.dart
│       │   │       ├── reset_password_usecase.dart
│       │   │       └── watch_auth_state_usecase.dart
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── user_model.dart
│       │   │   ├── datasources/
│       │   │   │   └── auth_remote_datasource.dart
│       │   │   └── repositories/
│       │   │       └── auth_repository_impl.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── auth_providers.dart
│       │       └── pages/
│       │           ├── splash_page.dart
│       │           ├── sign_in_page.dart
│       │           ├── sign_up_page.dart
│       │           └── forgot_password_page.dart
│       ├── delivery/        (vide/planifié)
│       ├── wallet/          (vide/planifié)
│       ├── tracking/        (vide/planifié)
│       ├── settings/        (vide/planifié)
│       ├── profile/         (vide/planifié)
│       ├── map/             (vide/planifié)
│       └── notifications/   (vide/planifié)
└── test/
    └── features/
        └── auth/
            ├── domain/
            │   └── usecases/
            │       └── sign_in_usecase_test.dart
            ├── data/
            │   └── repositories/
            │       └── auth_repository_impl_test.dart
            └── presentation/
                └── pages/
                    └── sign_in_page_test.dart
```

## Conventions

- **Nommage fichiers** : `snake_case.dart`.
- **Nommage classes** : `PascalCase`.
- **Un fichier = une responsabilité publique principale** (une classe, ou une union Freezed + son fichier généré `.freezed.dart`/`.g.dart`).
- **Imports** : toujours par package (`package:poc_uber/...`), jamais de chemins relatifs remontant hors du dossier courant au-delà d'un niveau, pour garder les déplacements de fichiers sûrs.
- **Barrel files** : non utilisés pour l'instant (le projet est encore petit ; à réévaluer si les imports deviennent verbeux).
