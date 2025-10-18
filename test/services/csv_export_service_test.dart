import 'package:flutter/foundation.dart';
import 'package:your_turn/src/models/todo_category.dart';

@immutable
class MoneyTx {
  final String id;
  final String roommateId;
  final double amount;
  final String note;
  final DateTime createdAt;
  final List<TodoCategory> category;

  const MoneyTx({
    required this.id,
    required this.roommateId,
    required this.amount,
    required this.note,
    required this.createdAt,
    required this.category,
  });

  MoneyTx copyWith({
    String? id,
    String? roommateId,
    double? amount,
    String? note,
    DateTime? createdAt,
    List<TodoCategory>? category,
  }) {
    return MoneyTx(
      id: id ?? this.id,
      roommateId: roommateId ?? this.roommateId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? List.from(this.category),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'roommateId': roommateId,
        'amount': amount,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'category': category.map((c) => c.id).toList(),
      };

  factory MoneyTx.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    List<TodoCategory> parsedCategories = [];

    if (rawCategory is List) {
      parsedCategories = rawCategory.map((id) {
        try {
          return stockCategories.firstWhere((c) => c.id == id);
        } catch (_) {
          return stockCategories.firstWhere((c) => c.id == 'varie');
        }
      }).toList();
    } else if (rawCategory is String) {
      // compatibilità con vecchi dati (singola categoria)
      try {
        parsedCategories = [
          stockCategories.firstWhere((c) => c.id == rawCategory)
        ];
      } catch (_) {
        parsedCategories = [
          stockCategories.firstWhere((c) => c.id == 'varie')
        ];
      }
    } else {
      parsedCategories = [
        stockCategories.firstWhere((c) => c.id == 'varie')
      ];
    }

    return MoneyTx(
      id: json['id'] as String,
      roommateId: json['roommateId'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      category: parsedCategories,
    );
  }

  @override
  String toString() {
    final cats = category.map((c) => c.name).join(', ');
    return 'MoneyTx(id: $id, roommateId: $roommateId, amount: $amount, '
        'note: $note, createdAt: $createdAt, category: [$cats])';
  }

  /// Categoria principale (prima della lista)
  TodoCategory get mainCategory =>
      category.isNotEmpty
          ? category.first
          : stockCategories.firstWhere((c) => c.id == 'varie');
}
