import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_uber/shared/widgets/transaction_card.dart';

void main() {
  testWidgets('affiche description, montant, date et déclenche onTap', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionCard(
            description: 'Bonus de bienvenue',
            amountLabel: '+50.00 €',
            dateLabel: '03/07/2026 à 10:00',
            isCredit: true,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Bonus de bienvenue'), findsOneWidget);
    expect(find.text('+50.00 €'), findsOneWidget);
    expect(find.text('03/07/2026 à 10:00'), findsOneWidget);

    await tester.tap(find.byType(TransactionCard));
    expect(tapped, isTrue);
  });
}
