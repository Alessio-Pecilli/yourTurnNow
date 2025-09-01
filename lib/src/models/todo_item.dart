import 'package:flutter/foundation.dart';
import 'todo_status.dart';
import 'todo_category.dart';

@immutable
class TodoItem {
  final String id;
  final String title;
  final String? notes;
  final List<String> assigneeIds;
  final double? cost;
  final DateTime? dueDate;
  final TodoStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<TodoCategory> categories;

  const TodoItem({
    required this.id,
    required this.title,
    this.notes,
    this.assigneeIds = const [],
    this.cost,
    this.dueDate,
    this.status = TodoStatus.open,
    required this.createdAt,
    this.completedAt,
    this.categories = const [],
  });

  TodoItem copyWith({
    String? title,
    String? notes,
    List<String>? assigneeIds,
    double? cost,
    DateTime? dueDate,
    TodoStatus? status,
    DateTime? completedAt,
    List<TodoCategory>? categories,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      cost: cost ?? this.cost,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      categories: categories ?? this.categories,
    );
  }
}