import 'package:flutter/material.dart';

class TodoCategory {
  final String id;
  final String name;
  final IconData icon;
  final String color; // Hex color per i chip

  const TodoCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Mappa costante: id/iconKey -> IconData (tutto const, ok per tree-shaker)
  static const Map<String, IconData> _iconByKey = {
    'spesa': Icons.shopping_cart,
    'cucina': Icons.kitchen,
    'pulizie': Icons.cleaning_services,
    'bollette': Icons.receipt_long,
    'divertimento': Icons.celebration,
    'manutenzione': Icons.build,
    'varie': Icons.notes,
  };

  // Se serve serializzare:
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // salviamo una chiave testuale, non il codePoint
      'iconKey': _keyForIcon(icon),
      'color': color,
    };
  }

  // Inversione semplice senza riflessioni / costruttori runtime
  static String _keyForIcon(IconData icon) {
    if (icon == Icons.shopping_cart) return 'spesa';
    if (icon == Icons.kitchen) return 'cucina';
    if (icon == Icons.cleaning_services) return 'pulizie';
    if (icon == Icons.receipt_long) return 'bollette';
    if (icon == Icons.celebration) return 'divertimento';
    if (icon == Icons.build) return 'manutenzione';
    if (icon == Icons.notes) return 'varie';
    return 'varie';
  }

  factory TodoCategory.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    // Preferisci 'iconKey' nuovo, altrimenti usa l'id come chiave di fallback.
    final String iconKey = (json['iconKey'] as String?) ?? id;
    final IconData icon = _iconByKey[iconKey] ?? Icons.category;

    return TodoCategory(
      id: id,
      name: json['name'] as String,
      icon: icon,
      color: json['color'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoCategory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Categorie predefinite di stock (tutte const)
const List<TodoCategory> stockCategories = [
  TodoCategory(
    id: 'spesa',
    name: 'Spesa',
    icon: Icons.shopping_cart,
    color: '#4CAF50',
  ),
  TodoCategory(
    id: 'cucina',
    name: 'Cucina',
    icon: Icons.kitchen,
    color: '#FF9800',
  ),
  TodoCategory(
    id: 'pulizie',
    name: 'Pulizie',
    icon: Icons.cleaning_services,
    color: '#2196F3',
  ),
  TodoCategory(
    id: 'bollette',
    name: 'Bollette',
    icon: Icons.receipt_long,
    color: '#F44336',
  ),
  TodoCategory(
    id: 'divertimento',
    name: 'Divertimento',
    icon: Icons.celebration,
    color: '#9C27B0',
  ),
  TodoCategory(
    id: 'manutenzione',
    name: 'Manutenzione',
    icon: Icons.build,
    color: '#607D8B',
  ),
  TodoCategory(
    id: 'varie',
    name: 'Varie',
    icon: Icons.notes,
    color: '#795548',
  ),
];
