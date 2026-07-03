import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:poc_uber/config/firebase/firebase_options.dart';
import 'package:poc_uber/config/mapbox/mapbox_config.dart';
import 'package:poc_uber/config/router/app_router.dart';
import 'package:poc_uber/config/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  MapboxOptions.setAccessToken(MapboxConfig.accessToken);
  runApp(const ProviderScope(child: PocUberApp()));
}

class PocUberApp extends ConsumerWidget {
  const PocUberApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'POC Uber',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Le pilotage du thème (clair/sombre/dynamique) par Firestore
      // appartient à la future feature `settings` — voir TASKS.md.
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
