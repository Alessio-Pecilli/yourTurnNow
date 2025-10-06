import 'package:flutter_test/flutter_test.dart';
import 'package:your_turn/src/models/roommate.dart';

void main() {
  group('Roommate Tests', () {
    test('costruttore deve creare oggetto valido', () {
      final roommate = Roommate(
        id: 'user-1',
        name: 'Mario Rossi',
        photoUrl: 'https://example.com/photo.jpg',
        monthlyBudget: 100.0,
        tasksCompleted: 5,
      );

      expect(roommate.id, 'user-1');
      expect(roommate.name, 'Mario Rossi');
      expect(roommate.photoUrl, 'https://example.com/photo.jpg');
      expect(roommate.monthlyBudget, 100.0);
      expect(roommate.tasksCompleted, 5);
    });

    test('photoUrl, monthlyBudget e tasksCompleted devono essere opzionali', () {
      final roommate = Roommate(
        id: 'user-1',
        name: 'Mario Rossi',
      );

      expect(roommate.id, 'user-1');
      expect(roommate.name, 'Mario Rossi');
      expect(roommate.photoUrl, isNull);
      expect(roommate.monthlyBudget, 0.0); // Valore di default
      expect(roommate.tasksCompleted, 0); // Valore di default
    });

    test('copyWith deve funzionare correttamente', () {
      final original = Roommate(
        id: 'user-1',
        name: 'Mario Rossi',
        monthlyBudget: 100.0,
        tasksCompleted: 3,
      );

      final modified = original.copyWith(
        name: 'Luigi Verdi',
        monthlyBudget: 200.0,
      );

      expect(modified.name, 'Luigi Verdi');
      expect(modified.monthlyBudget, 200.0);
      expect(modified.id, original.id); // Non modificato
      expect(modified.tasksCompleted, original.tasksCompleted); // Non modificato
    });

    test('deve gestire budget positivi e negativi', () {
      final positiveBalance = Roommate(
        id: 'user-1',
        name: 'Rich User',
        monthlyBudget: 1000.0,
      );

      final negativeBalance = Roommate(
        id: 'user-2',
        name: 'Poor User',
        monthlyBudget: -50.0,
      );

      expect(positiveBalance.monthlyBudget > 0, true);
      expect(negativeBalance.monthlyBudget < 0, true);
    });

    test('nomi vuoti devono essere gestiti', () {
      final roommate = Roommate(
        id: 'user-1',
        name: '',
      );

      expect(roommate.name, '');
      expect(roommate.id.isNotEmpty, true);
    });

    test('tasksCompleted deve essere un intero', () {
      final roommate = Roommate(
        id: 'user-1',
        name: 'Test User',
        tasksCompleted: 42,
      );

      expect(roommate.tasksCompleted, isA<int>());
      expect(roommate.tasksCompleted, 42);
    });
  });
}