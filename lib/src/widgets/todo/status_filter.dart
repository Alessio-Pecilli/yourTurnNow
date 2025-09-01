import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/providers/todo_provider.dart';

class StatusFilters extends ConsumerWidget {
  const StatusFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(todosFilterProvider);
    void setFilter(TodoStatus? st) => ref.read(todosFilterProvider.notifier).state = st;

    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Tutti'),
          selected: current == null,
          onSelected: (_) => setFilter(null),
        ),
        FilterChip(
          label: const Text('Da fare'),
          selected: current == TodoStatus.open,
          onSelected: (_) => setFilter(TodoStatus.open),
        ),
        FilterChip(
          label: const Text('Fatto'),
          selected: current == TodoStatus.done,
          onSelected: (_) => setFilter(TodoStatus.done),
        ),
      ],
    );
  }
}
