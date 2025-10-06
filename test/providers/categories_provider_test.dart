import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/providers/categories_provider.dart';
import 'package:your_turn/src/models/todo_category.dart';

void main() {
  group('Categories Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('categoriesProvider deve inizializzare con stockCategories', () {
      final categories = container.read(categoriesProvider);
      
      expect(categories.length, stockCategories.length);
      expect(categories.length, 7); // Le 7 categorie stock
      
      // Verifica che contenga le categorie stock
      final stockIds = stockCategories.map((c) => c.id).toSet();
      final providerIds = categories.map((c) => c.id).toSet();
      expect(providerIds, stockIds);
    });

    test('categoriesProvider deve contenere categoria spesa', () {
      final categories = container.read(categoriesProvider);
      
      final spesaCategory = categories.firstWhere(
        (c) => c.id == 'spesa',
        orElse: () => throw StateError('Spesa category not found'),
      );
      
      expect(spesaCategory.name, 'Spesa');
      expect(spesaCategory.color, isNotEmpty);
      expect(spesaCategory.icon, isNotNull);
    });

    test('tutte le categorie del provider devono avere propriet√† valide', () {
      final categories = container.read(categoriesProvider);
      
      for (final category in categories) {
        expect(category.id.isNotEmpty, true);
        expect(category.name.isNotEmpty, true);
        expect(category.color.startsWith('#'), true);
        expect(category.color.length, 7); // #RRGGBB
        expect(category.icon, isNotNull);
      }
    });

    test('provider deve essere immutabile per default', () {
      final categories1 = container.read(categoriesProvider);
      final categories2 = container.read(categoriesProvider);
      
      // Stessa istanza se non modificata
      expect(categories1.length, categories2.length);
      expect(categories1.first.id, categories2.first.id);
    });

    test('provider deve contenere tutte le categorie stock ID', () {
      final categories = container.read(categoriesProvider);
      final providerIds = categories.map((c) => c.id).toList();
      
      // Verifica che contenga le categorie principali
      expect(providerIds, contains('spesa'));
      expect(providerIds, contains('bollette'));
      expect(providerIds, contains('pulizie'));
      expect(providerIds, contains('cucina'));
      expect(providerIds, contains('divertimento'));
      expect(providerIds, contains('manutenzione'));
      expect(providerIds, contains('varie'));
    });
  });
}