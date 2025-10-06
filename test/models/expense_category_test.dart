import 'package:flutter_test/flutter_test.dart';
import 'package:your_turn/src/models/expense_category.dart';

void main() {
  group('ExpenseCategory Tests', () {
    test('tutti gli enum devono avere label e icon', () {
      for (final category in ExpenseCategory.values) {
        expect(category.label.isNotEmpty, true, reason: '${category.name} deve avere label');
        expect(category.icon, isNotNull, reason: '${category.name} deve avere icon');
        expect(category.color, isNotNull, reason: '${category.name} deve avere color');
      }
    });

    test('i colori devono essere validi', () {
      for (final category in ExpenseCategory.values) {
        // Test che il colore sia un Color valido (non null e non trasparente)
        expect(category.color.value, greaterThan(0));
      }
    });

    test('le label devono essere uniche', () {
      final labels = ExpenseCategory.values.map((c) => c.label).toSet();
      expect(labels.length, ExpenseCategory.values.length, reason: 'Label duplicate trovate');
    });

    test('enum values specifici devono esistere', () {
      expect(ExpenseCategory.values, contains(ExpenseCategory.spesa));
      expect(ExpenseCategory.values, contains(ExpenseCategory.bolletta));
      expect(ExpenseCategory.values, contains(ExpenseCategory.pulizia));
      expect(ExpenseCategory.values, contains(ExpenseCategory.altro));
    });

    test('ExpenseCategory.spesa deve avere proprietà corrette', () {
      expect(ExpenseCategory.spesa.label, 'Spesa');
      expect(ExpenseCategory.spesa.icon, isNotNull);
      expect(ExpenseCategory.spesa.color, isNotNull);
    });
  });
}