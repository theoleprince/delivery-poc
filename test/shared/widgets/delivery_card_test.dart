import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_uber/shared/widgets/delivery_card.dart';

void main() {
  testWidgets('affiche les champs et déclenche onTap', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveryCard(
            destination: '12 rue de Lyon',
            recipientName: 'Jean Dupont',
            statusLabel: 'En attente · Standard',
            priceLabel: '12.50 €',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('12 rue de Lyon'), findsOneWidget);
    expect(find.text('Jean Dupont'), findsOneWidget);
    expect(find.text('En attente · Standard'), findsOneWidget);
    expect(find.text('12.50 €'), findsOneWidget);

    await tester.tap(find.byType(DeliveryCard));
    expect(tapped, isTrue);
  });
}
