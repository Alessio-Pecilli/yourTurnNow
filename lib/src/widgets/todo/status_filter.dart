import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/providers/todo_provider.dart';
import 'package:your_turn/l10n/app_localizations.dart';

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
          label: Text(AppLocalizations.of(context)!.todos_filter_all),
          selected: current == null,
          onSelected: (_) => setFilter(null),
        ),
        FilterChip(
          label: Text(AppLocalizations.of(context)!.todos_filter_open),
          selected: current == TodoStatus.open,
          onSelected: (_) => setFilter(TodoStatus.open),
        ),
        FilterChip(
          label: Text(AppLocalizations.of(context)!.todos_filter_done),
          selected: current == TodoStatus.done,
          onSelected: (_) => setFilter(TodoStatus.done),
        ),
      ],
    );
  }
}
