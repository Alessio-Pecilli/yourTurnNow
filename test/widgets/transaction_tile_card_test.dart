import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/widgets/transaction_tile_card.dart';

void main() {
  group('TransactionTileCard Widget Tests', () {
    testWidgets('deve renderizzare widget base', (tester) async {
      // 🔹 Crea una transazione di test con categoria "spesa"
      final transaction = MoneyTx(
        id: 'test-tx',
        roommateId: 'user-1',
        amount: 25.0,
        note: 'Test transazione',
        category: [
          stockCategories.firstWhere((c) => c.id == 'spesa'),
        ],
        createdAt: DateTime(2025, 10, 6, 12, 0),
      );

      // 🔹 Formatter per l’importo
      final money = NumberFormat.currency(locale: 'it_IT', symbol: '€');

      // 🔹 Render del widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTileCard(
              tx: transaction,
              money: money,
              onDelete: () {},
              onEdit: () {},
            ),
          ),
        ),
      );

      // 🔹 Aspettative di base
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_rounded), findsOneWidget);

      // 🔹 Verifica che la nota della transazione sia visibile
      expect(find.text('Test transazione'), findsOneWidget);

      // 🔹 Verifica che l’importo formattato sia visibile
      expect(find.textContaining('€'), findsOneWidget);
    });
  });
}
