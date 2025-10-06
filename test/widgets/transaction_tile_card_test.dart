import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:your_turn/src/widgets/transaction_tile_card.dart';
import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/expense_category.dart';

void main() {
  group('TransactionTileCard Widget Tests', () {
    testWidgets('deve renderizzare widget base', (tester) async {
      final transaction = MoneyTx(
        id: 'test-tx',
        roommateId: 'user-1',
        amount: 25.0,
        note: 'Test',
        category: ExpenseCategory.spesa,
        createdAt: DateTime(2025, 10, 6),
      );
      
      final money = NumberFormat.currency(locale: 'it_IT', symbol: '€');

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

      // Test semplici - verifica solo che ci siano i pulsanti
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_rounded), findsOneWidget);
    });
  });
}