import 'package:flutter_test/flutter_test.dart';
import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/todo_category.dart';

void main() {
  group('MoneyTx Tests', () {
    test('costruttore deve creare oggetto valido', () {
      final now = DateTime.now();
      final tx = MoneyTx(
        id: 'test-id',
        roommateId: 'roommate-1',
        amount: 10.50,
        note: 'Test transaction',
        category: [
          stockCategories.firstWhere((c) => c.id == 'spesa'),
        ],
        createdAt: now,
      );

      expect(tx.id, 'test-id');
      expect(tx.roommateId, 'roommate-1');
      expect(tx.amount, 10.50);
      expect(tx.note, 'Test transaction');
      expect(tx.category.first.id, 'spesa');
      expect(tx.createdAt, now);
    });

    test('equality check deve funzionare con stessi dati', () {
      final now = DateTime.now();
      final cat = stockCategories.firstWhere((c) => c.id == 'bollette');

      final tx1 = MoneyTx(
        id: 'test-id',
        roommateId: 'roommate-1',
        amount: -25.75,
        note: 'Test expense',
        category: [cat],
        createdAt: now,
      );

      final tx2 = MoneyTx(
        id: 'test-id',
        roommateId: 'roommate-1',
        amount: -25.75,
        note: 'Test expense',
        category: [cat],
        createdAt: now,
      );

      expect(tx1.id, tx2.id);
      expect(tx1.roommateId, tx2.roommateId);
      expect(tx1.amount, tx2.amount);
      expect(tx1.note, tx2.note);
      expect(tx1.category.first, tx2.category.first);
      expect(tx1.createdAt, tx2.createdAt);
    });

    test('copyWith deve funzionare correttamente', () {
      final original = MoneyTx(
        id: 'original-id',
        roommateId: 'roommate-1',
        amount: 100.0,
        note: 'Original note',
        category: [
          stockCategories.firstWhere((c) => c.id == 'spesa'),
        ],
        createdAt: DateTime.now(),
      );

      final modified = original.copyWith(
        amount: 200.0,
        note: 'Modified note',
      );

      expect(modified.amount, 200.0);
      expect(modified.note, 'Modified note');
      expect(modified.id, original.id);
      expect(modified.roommateId, original.roommateId);
      expect(modified.category, original.category);
    });

    test('deve gestire importi positivi e negativi', () {
      final income = MoneyTx(
        id: 'income',
        roommateId: 'user-1',
        amount: 1000.0,
        note: 'Stipendio',
        category: [
          stockCategories.firstWhere((c) => c.id == 'varie'),
        ],
        createdAt: DateTime.now(),
      );

      final expense = MoneyTx(
        id: 'expense',
        roommateId: 'user-1',
        amount: -50.0,
        note: 'Spesa supermercato',
        category: [
          stockCategories.firstWhere((c) => c.id == 'spesa'),
        ],
        createdAt: DateTime.now(),
      );

      expect(income.amount > 0, true);
      expect(expense.amount < 0, true);
    });

    test('note vuota deve essere permessa', () {
      final tx = MoneyTx(
        id: 'test',
        roommateId: 'user-1',
        amount: 10.0,
        note: '',
        category: [
          stockCategories.firstWhere((c) => c.id == 'varie'),
        ],
        createdAt: DateTime.now(),
      );

      expect(tx.note, '');
      expect(tx.category.first.id, 'varie');
    });
  });
}
