import 'package:flutter_test/flutter_test.dart';
import 'package:your_turn/src/models/todo_category.dart';

void main() {
  group('TodoCategory Tests', () {
    test('tutte le categorie devono avere nome, icona e colore validi', () {
      for (final category in stockCategories) {
        expect(category.name.isNotEmpty, true, reason: '${category.id} deve avere un name valido');
        expect(category.icon, isNotNull, reason: '${category.id} deve avere una icon');
        expect(category.color.isNotEmpty, true, reason: '${category.id} deve avere un color valido');
      }
    });

    test('i colori devono essere in formato esadecimale valido', () {
      final hexColorRegex = RegExp(r'^#(?:[0-9a-fA-F]{6})$');
      for (final category in stockCategories) {
        expect(hexColorRegex.hasMatch(category.color), true,
            reason: '${category.id} ha un colore non valido: ${category.color}');
      }
    });

    test('gli id devono essere unici', () {
      final ids = stockCategories.map((c) => c.id).toSet();
      expect(ids.length, stockCategories.length, reason: 'Id duplicati trovati');
    });

    test('categorie specifiche devono esistere', () {
      final ids = stockCategories.map((c) => c.id).toList();
      expect(ids, containsAll(['spesa', 'bollette', 'pulizie', 'varie']));
    });

    test('la categoria spesa deve avere proprietà corrette', () {
      final spesa = stockCategories.firstWhere((c) => c.id == 'spesa');
      expect(spesa.name, 'Spesa');
      expect(spesa.icon, isNotNull);
      expect(spesa.color, '#4CAF50');
    });
  });
}
