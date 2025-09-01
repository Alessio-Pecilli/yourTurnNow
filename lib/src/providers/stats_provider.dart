import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/models/todo_item.dart';
import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'package:your_turn/src/providers/transactions_provider.dart';


final statsProvider = Provider((ref) {
  final todos = ref.watch(todosProvider);
  final done = todos.where((t) => t.status == TodoStatus.done).length;
  final open = todos.length - done;
  final totalCost = todos.fold<double>(0, (sum, t) => sum + (t.cost ?? 0));
  final doneCost = todos
      .where((t) => t.status == TodoStatus.done)
      .fold<double>(0, (sum, t) => sum + (t.cost ?? 0));
  return (open: open, done: done, total: todos.length, totalCost: totalCost, doneCost: doneCost);
});

final filteredTodosProvider = Provider<List<TodoItem>>((ref) {
  final items = ref.watch(todosProvider);
  final filter = ref.watch(todosFilterProvider);

  Iterable<TodoItem> it = items;
  if (filter != null) {
    it = it.where((t) => t.status == filter);
  }

  int statusRank(TodoItem t) => t.status == TodoStatus.open ? 0 : 1;
  int dueRank(TodoItem t) => t.dueDate?.millisecondsSinceEpoch ?? 1 << 30;

  final sorted = it.toList()
    ..sort((a, b) {
      final byStatus = statusRank(a).compareTo(statusRank(b));
      if (byStatus != 0) return byStatus;
      final byDue = dueRank(a).compareTo(dueRank(b));
      if (byDue != 0) return byDue;
      // createdAt decrescente: il più recente sopra
      return b.createdAt.compareTo(a.createdAt);
    });

  return sorted;
});