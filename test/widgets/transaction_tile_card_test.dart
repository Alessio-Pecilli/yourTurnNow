import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/widgets/transaction_tile_card.dart';

void main() {
  testWidgets('TransactionTileCard si costruisce senza crash', (tester) async {
    final tx = MoneyTx(
      id: '1',
      roommateId: 'r1',
      amount: 10,
      note: 'test',
      createdAt: DateTime.now(),
      category: [stockCategories.first],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [],
        home: Scaffold(
          body: TransactionTileCard(
            tx: tx,
            money: NumberFormat.simpleCurrency(locale: 'it_IT'),
            onDelete: () {},
            onEdit: () {},
          ),
        ),
      ),
    );

    expect(find.byType(TransactionTileCard), findsOneWidget);
  });
}
