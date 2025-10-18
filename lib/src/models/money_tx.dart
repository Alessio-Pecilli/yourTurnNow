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
  final String? customCategoryName;

  const MoneyTx({
    required this.id,
    required this.roommateId,
    required this.amount,
    required this.note,
    required this.createdAt,
    required this.category,
    this.customCategoryName,
  });

  MoneyTx copyWith({
  String? id,
  String? roommateId,
  double? amount,
  String? note,
  DateTime? createdAt,
  List<TodoCategory>? category,
  String? customCategoryName,
}) {
  return MoneyTx(
    id: id ?? this.id,
    roommateId: roommateId ?? this.roommateId,
    amount: amount ?? this.amount,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    category: category ?? this.category,
    customCategoryName: customCategoryName ?? this.customCategoryName,
  );
}

}
