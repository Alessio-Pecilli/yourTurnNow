import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_turn/src/models/todo_category.dart';

void main() {
  group('TodoCategory Tests', () {
    test('stockCategories deve contenere 7 categorie', () {
      expect(stockCategories.length, 7);
    });

    test('tutte le stockCategories devono avere id, name, color e icon validi', () {
      for (final category in stockCategories) {
        expect(category.id.isNotEmpty, true, reason: 'ID non può essere vuoto');
        expect(category.name.isNotEmpty, true, reason: 'Nome non può essere vuoto');
        expect(category.color.startsWith('#'), true, reason: 'Colore deve iniziare con #');
        expect(category.color.length, 7, reason: 'Colore deve essere formato #RRGGBB');
        expect(category.icon, isNotNull, reason: 'Icon non può essere null');
      }
    });

    test('fromJson e toJson devono essere simmetrici', () {
      final originalCategory = stockCategories.first;
      final json = originalCategory.toJson();
      final reconstructedCategory = TodoCategory.fromJson(json);
      
      expect(reconstructedCategory.id, originalCategory.id);
      expect(reconstructedCategory.name, originalCategory.name);
      expect(reconstructedCategory.color, originalCategory.color);
    });

    test('equality operator deve funzionare correttamente', () {
      final category1 = stockCategories.first;
      final category2 = TodoCategory(
        id: category1.id,
        name: 'Nome Diverso', // Nome diverso ma stesso ID
        icon: category1.icon,
        color: category1.color,
      );
      
      // Due categorie con stesso ID devono essere uguali
      expect(category1, equals(category2));
      expect(category1.hashCode, equals(category2.hashCode));
    });

    test('tutte le stock categories devono avere icone coerenti con il loro ID', () {
      for (final category in stockCategories) {
        // Verifica che la serializzazione/deserializzazione mantenga l'icona corretta
        final json = category.toJson();
        final restored = TodoCategory.fromJson(json);
        expect(restored.icon, category.icon, reason: 'Icona per ${category.id} non corrispondente dopo serializzazione');
      }
    });

    test('le categorie stock devono avere ID univoci', () {
      final ids = stockCategories.map((c) => c.id).toSet();
      expect(ids.length, stockCategories.length, reason: 'ID duplicati trovati');
    });

    test('fromJson deve gestire sia iconKey che fallback su ID', () {
      // Test con iconKey esplicito
      final jsonWithIconKey = {
        'id': 'test-id',
        'name': 'Test Category',
        'iconKey': 'spesa',
        'color': '#FF0000',
      };
      
      final categoryWithIconKey = TodoCategory.fromJson(jsonWithIconKey);
      expect(categoryWithIconKey.id, 'test-id');
      expect(categoryWithIconKey.name, 'Test Category');
      expect(categoryWithIconKey.icon, Icons.shopping_cart);
      expect(categoryWithIconKey.color, '#FF0000');
      
      // Test senza iconKey (usa ID come fallback)
      final jsonWithoutIconKey = {
        'id': 'cucina',
        'name': 'Test Cucina',
        'color': '#00FF00',
      };
      
      final categoryWithoutIconKey = TodoCategory.fromJson(jsonWithoutIconKey);
      expect(categoryWithoutIconKey.id, 'cucina');
      expect(categoryWithoutIconKey.icon, Icons.kitchen);
    });

    test('fromJson deve usare icona di default per chiavi sconosciute', () {
      final jsonUnknownIcon = {
        'id': 'unknown',
        'name': 'Unknown Category',
        'iconKey': 'nonexistent_key',
        'color': '#000000',
      };
      
      final category = TodoCategory.fromJson(jsonUnknownIcon);
      expect(category.icon, Icons.category); // Icona di default
    });
  });
}