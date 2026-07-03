import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poc_uber/features/auth/presentation/providers/auth_providers.dart';
import 'package:poc_uber/shared/widgets/app_error_widget.dart';
import 'package:poc_uber/shared/widgets/loading_widget.dart';

/// Écran affiché pendant la résolution du premier événement du stream
/// d'authentification (restauration de session persistante). La décision
/// de redirection (`/sign-in` vs `/home`) est prise une seule fois, dans
/// `app_router.dart`, pour éviter toute logique de navigation dupliquée.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: authState.when(
        data: (_) => const LoadingWidget(),
        loading: () => const LoadingWidget(),
        error: (Object error, StackTrace _) =>
            AppErrorWidget(message: error.toString()),
      ),
    );
  }
}
