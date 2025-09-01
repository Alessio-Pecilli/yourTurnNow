import 'package:flutter/material.dart';

enum ExpenseCategory {
  spesa('Spesa', Icons.shopping_cart, Color(0xFF4CAF50)),
  bolletta('Bolletta', Icons.receipt_long, Color(0xFFFF9800)),
  prestito('Prestito', Icons.handshake, Color(0xFF2196F3)),
  affitto('Affitto', Icons.home, Color(0xFF9C27B0)),
  pulizia('Pulizia', Icons.cleaning_services, Color(0xFF00BCD4)),
  trasporti('Trasporti', Icons.directions_bus, Color(0xFFFF5722)),
  altro('Altro', Icons.category, Color(0xFF607D8B));

  const ExpenseCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Ottiene la categoria dall'etichetta (per compatibilità con dati esistenti)
  static ExpenseCategory? fromLabel(String label) {
    try {
      return ExpenseCategory.values.firstWhere(
        (cat) => cat.label.toLowerCase() == label.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Inferisce la categoria dalla nota (per migrazione dati esistenti)
  static ExpenseCategory inferFromNote(String note) {
    final noteLower = note.toLowerCase();

    if (noteLower.contains('bolletta') || noteLower.contains('luce') ||
        noteLower.contains('gas') || noteLower.contains('acqua')) {
      return ExpenseCategory.bolletta;
    }
    if (noteLower.contains('spesa') || noteLower.contains('supermercato') ||
        noteLower.contains('alimentari')) {
      return ExpenseCategory.spesa;
    }
    if (noteLower.contains('prestito') || noteLower.contains('rimborso') ||
        noteLower.contains('anticipo')) {
      return ExpenseCategory.prestito;
    }
    if (noteLower.contains('affitto') || noteLower.contains('canone')) {
      return ExpenseCategory.affitto;
    }
    if (noteLower.contains('pulizia') || noteLower.contains('detersivi')) {
      return ExpenseCategory.pulizia;
    }
    if (noteLower.contains('trasport') || noteLower.contains('benzina') ||
        noteLower.contains('autobus') || noteLower.contains('metro')) {
      return ExpenseCategory.trasporti;
    }

    return ExpenseCategory.altro;
  }
}
