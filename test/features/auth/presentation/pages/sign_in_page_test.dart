import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_uber/features/auth/presentation/pages/sign_in_page.dart';

void main() {
  testWidgets('affiche les champs email/mot de passe et le bouton de connexion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignInPage())),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Mot de passe oublié ?'), findsOneWidget);
  });

  testWidgets('affiche des erreurs de validation sur formulaire vide', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignInPage())),
    );

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Email invalide'), findsOneWidget);
    expect(find.text('6 caractères minimum'), findsOneWidget);
  });
}
