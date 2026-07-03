import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_uber/features/delivery/presentation/pages/package_info_page.dart';

void main() {
  testWidgets('affiche tous les champs du formulaire colis', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PackageInfoPage())),
    );

    expect(find.text('Nom du colis'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Poids (kg)'), findsOneWidget);
    expect(find.text('Longueur (cm)'), findsOneWidget);
    expect(find.text('Largeur (cm)'), findsOneWidget);
    expect(find.text('Hauteur (cm)'), findsOneWidget);
    expect(find.text('Valeur déclarée'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });

  testWidgets('affiche des erreurs de validation sur formulaire vide', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: PackageInfoPage())),
    );

    await tester.tap(find.text('Suivant'));
    await tester.pump();

    expect(find.text('Champ requis'), findsWidgets);
    expect(find.text('Nombre invalide'), findsWidgets);
  });
}
