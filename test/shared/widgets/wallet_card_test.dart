import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_uber/shared/widgets/wallet_card.dart';

void main() {
  testWidgets('affiche le solde formaté', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WalletCard(balanceLabel: '50.00 €')),
      ),
    );

    expect(find.text('Solde disponible'), findsOneWidget);
    expect(find.text('50.00 €'), findsOneWidget);
  });
}
