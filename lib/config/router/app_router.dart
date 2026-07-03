import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:poc_uber/config/theme/spacing.dart';
import 'package:poc_uber/core/constants/app_routes.dart';
import 'package:poc_uber/core/usecase/usecase.dart';
import 'package:poc_uber/features/auth/domain/entities/user_entity.dart';
import 'package:poc_uber/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:poc_uber/features/auth/presentation/pages/sign_in_page.dart';
import 'package:poc_uber/features/auth/presentation/pages/sign_up_page.dart';
import 'package:poc_uber/features/auth/presentation/pages/splash_page.dart';
import 'package:poc_uber/features/auth/presentation/providers/auth_providers.dart';
import 'package:poc_uber/features/delivery/presentation/pages/delivery_detail_page.dart';
import 'package:poc_uber/features/delivery/presentation/pages/delivery_history_page.dart';
import 'package:poc_uber/features/delivery/presentation/pages/delivery_route_page.dart';
import 'package:poc_uber/features/delivery/presentation/pages/delivery_summary_page.dart';
import 'package:poc_uber/features/delivery/presentation/pages/package_info_page.dart';
import 'package:poc_uber/features/delivery/presentation/pages/recipient_info_page.dart';
import 'package:poc_uber/shared/widgets/primary_button.dart';

part 'app_router.g.dart';

/// Router centralisé (voir ARCHITECTURE.md §4.4). La redirection est
/// pilotée par `authStateProvider` : session persistante restaurée →
/// `/home`, sinon → `/sign-in`. `_AuthRefreshNotifier` relaie les
/// changements du provider vers `GoRouter.refreshListenable`.
@riverpod
GoRouter appRouter(Ref ref) {
  final _AuthRefreshNotifier refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final AsyncValue<UserEntity?> authState = ref.read(authStateProvider);
      final String location = state.matchedLocation;
      final bool isAuthRoute =
          location == AppRoutes.signIn ||
          location == AppRoutes.signUp ||
          location == AppRoutes.forgotPassword;

      if (authState.isLoading && !authState.hasValue) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final bool isLoggedIn = authState.valueOrNull != null;

      if (!isLoggedIn) {
        return isAuthRoute ? null : AppRoutes.signIn;
      }

      if (isAuthRoute || location == AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (BuildContext context, GoRouterState state) =>
            const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (BuildContext context, GoRouterState state) =>
            const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) =>
            const _HomePlaceholderPage(),
      ),
      GoRoute(
        path: AppRoutes.deliveryRoute,
        builder: (BuildContext context, GoRouterState state) =>
            const DeliveryRoutePage(),
      ),
      GoRoute(
        path: AppRoutes.deliveryPackage,
        builder: (BuildContext context, GoRouterState state) =>
            const PackageInfoPage(),
      ),
      GoRoute(
        path: AppRoutes.deliveryRecipient,
        builder: (BuildContext context, GoRouterState state) =>
            const RecipientInfoPage(),
      ),
      GoRoute(
        path: AppRoutes.deliverySummary,
        builder: (BuildContext context, GoRouterState state) =>
            const DeliverySummaryPage(),
      ),
      GoRoute(
        path: AppRoutes.deliveryHistory,
        builder: (BuildContext context, GoRouterState state) =>
            const DeliveryHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.deliveryDetailPattern,
        builder: (BuildContext context, GoRouterState state) =>
            DeliveryDetailPage(deliveryId: state.pathParameters['id']!),
      ),
    ],
  );
}

/// Relaie les changements de `authStateProvider` vers GoRouter. `ref.listen`
/// est utilisé de façon impérative (hors `build`) : c'est le pattern
/// recommandé pour ponter un `StreamProvider` Riverpod vers un
/// `Listenable` externe.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _subscription = _ref.listen<AsyncValue<UserEntity?>>(
      authStateProvider,
      (AsyncValue<UserEntity?>? previous, AsyncValue<UserEntity?> next) =>
          notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<UserEntity?>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Écran d'accueil temporaire : confirme visuellement que le flux Auth
/// fonctionne de bout en bout. Sera remplacé par la home réelle fournie par
/// les futures features (`delivery`/`wallet`/...) — voir TASKS.md.
class _HomePlaceholderPage extends ConsumerWidget {
  const _HomePlaceholderPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserEntity?> authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Connecté : ${authState.valueOrNull?.email ?? ''}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.lg),
              PrimaryButton(
                label: 'Créer une livraison',
                onPressed: () => context.push(AppRoutes.deliveryRoute),
              ),
              const SizedBox(height: Spacing.sm),
              PrimaryButton(
                label: 'Historique des livraisons',
                onPressed: () => context.push(AppRoutes.deliveryHistory),
              ),
              const SizedBox(height: Spacing.sm),
              PrimaryButton(
                label: 'Se déconnecter',
                onPressed: () {
                  unawaited(
                    ref.read(signOutUseCaseProvider).call(const NoParams()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
