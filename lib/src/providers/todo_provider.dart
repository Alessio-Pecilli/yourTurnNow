import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/mock_db.dart';
import 'package:your_turn/src/models/todo_item.dart';
import 'package:your_turn/src/models/todo_status.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/models/expense_category.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/user_provider.dart';
import 'package:your_turn/src/providers/transactions_provider.dart';
import 'package:your_turn/src/pages/todo_page.dart';

/// 🔹 Provider filtro stato (null = tutti)
final todosFilterProvider = StateProvider<TodoStatus?>((ref) => null);

/// 🔹 Provider mostra/nascondi completati
final showCompletedProvider = StateProvider<bool>((ref) => true);

/// 🔹 Provider ordinamento (default: data discendente)
/// valori possibili: data_asc, data_desc, costo_asc, costo_desc
final todosOrderProvider = StateProvider<String>((ref) => "data_desc");

/// 🔹 StateNotifier principale con logica CRUD e side-effects
class TodosCtrl extends StateNotifier<List<TodoItem>> {
  TodosCtrl(this.ref) : super(mockTodos);
  final Ref ref;

  void add({
    required String title,
    String? notes,
    required String creatorId,
    List<String> assigneeIds = const [],
    double? cost,
    DateTime? dueDate,
    List<TodoCategory> categories = const [],
  }) {
    final now = DateTime.now();
    state = [
      TodoItem(
        id: now.microsecondsSinceEpoch.toString(),
        title: title.trim(),
        notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
        assigneeIds: List.unmodifiable(assigneeIds),
        cost: cost,
        dueDate: dueDate,
        status: TodoStatus.open,
        createdAt: now,
        completedAt: null,
        creatorId: creatorId,
        categories: List.unmodifiable(categories),
      ),
      ...state,
    ];
  }

  void update({
    required String id,
    String? title,
    String? notes,
    List<String>? assigneeIds,
    double? cost,
    DateTime? dueDate,
    TodoStatus? status,
    List<TodoCategory>? categories,
  }) {
    state = [
      for (final t in state)
        if (t.id != id)
          t
        else
          t.copyWith(
            title: title,
            notes: notes,
            assigneeIds: assigneeIds,
            cost: cost,
            dueDate: dueDate,
            status: status,
            categories: categories,
            completedAt: status == null
                ? t.completedAt
                : (status == TodoStatus.done
                    ? (t.completedAt ?? DateTime.now())
                    : null),
          )
    ];
  }

  /// Toggle con side-effects: completedAt, tasksCompleted, budget per-head, log transazione
  void toggleDone(String id) {
    final idx = state.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final t = state[idx];
    final toDone = t.status != TodoStatus.done;

    // aggiorna stato
    final updated = t.copyWith(
      status: toDone ? TodoStatus.done : TodoStatus.open,
      completedAt: toDone ? (t.completedAt ?? DateTime.now()) : null,
    );
    state = [...state]..[idx] = updated;

    // side-effects
    final ass = t.assigneeIds;
    if (ass.isEmpty) return;

    // conteggio task
    final deltaCompleted = toDone ? 1 : -1;
    for (final uid in ass) {
      ref.read(roommatesProvider.notifier).adjustCompletedFor(uid, deltaCompleted);
    }

    // budget + transazioni
    if (t.cost != null && t.cost! > 0) {
      final perHead = t.cost! / ass.length;
      final sign = toDone ? -1.0 : 1.0; // done = soldi che escono
      final deltaBudget = sign * perHead;
      final txNote = toDone
          ? 'Task "${t.title}" completato'
          : 'Task "${t.title}" riaperto (rimborso)';

      // stessa data del completamento
      final txWhen = toDone ? updated.completedAt : DateTime.now();

      // Mappa la categoria del todo a quella della transazione
      ExpenseCategory? txCategory;
      if (t.categories.isNotEmpty) {
        final todoCategoryId = t.categories.first.id;
        switch (todoCategoryId) {
          case 'spesa':
            txCategory = ExpenseCategory.spesa;
            break;
          case 'bollette':
            txCategory = ExpenseCategory.bolletta;
            break;
          case 'pulizie':
            txCategory = ExpenseCategory.pulizia;
            break;
          case 'manutenzione':
          case 'varie':
            txCategory = ExpenseCategory.altro;
            break;
          case 'divertimento':
          case 'cucina':
            txCategory = ExpenseCategory.altro;
            break;
          default:
            txCategory = ExpenseCategory.altro;
        }
      }

      for (final uid in ass) {
        ref.read(roommatesProvider.notifier).adjustBudgetFor(uid, deltaBudget);
        ref.read(transactionsProvider.notifier).addTx(
          roommateId: uid,
          amount: deltaBudget,
          note: txNote,
          when: txWhen,
          category: txCategory,
        );
      }
    }
  }

  void setAssignees(String id, List<String> assigneeIds) {
    final i = state.indexWhere((e) => e.id == id);
    if (i < 0) return;
    state = [...state]
      ..[i] = state[i].copyWith(assigneeIds: List.unmodifiable(assigneeIds));
  }

  void setCost(String id, double? cost) {
    final i = state.indexWhere((e) => e.id == id);
    if (i < 0) return;
    state = [...state]..[i] = state[i].copyWith(cost: cost);
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList(growable: false);
  }

  void clearCompleted() {
    state = state.where((t) => t.status != TodoStatus.done).toList(growable: false);
  }
}

/// 🔹 Provider principale dei todos
final todosProvider =
    StateNotifierProvider<TodosCtrl, List<TodoItem>>((ref) => TodosCtrl(ref));

/// 🔹 Provider derivato con filtri e ordinamento applicati
final filteredTodosProvider = Provider<List<TodoItem>>((ref) {
  final todos = ref.watch(todosProvider);
  final filter = ref.watch(todosFilterProvider);
  final showCompleted = ref.watch(showCompletedProvider);
  final order = ref.watch(todosOrderProvider);
  final categoryFilter = ref.watch(todosCategoryFilterProvider);
  final justYou = ref.watch(todosJustYouFilterProvider);
  final user = ref.watch(userProvider);

  // filtro stato, completati, categoria e assegnatario
  var filtered = todos.where((t) {
    if (!showCompleted && t.status == TodoStatus.done) return false;
    if (filter != null && t.status != filter) return false;
    if (categoryFilter != null && !t.categories.any((c) => c.id == categoryFilter.id)) return false;
    if (justYou && user != null && !t.assigneeIds.contains(user.id)) return false;
    return true;
  }).toList();

  // ordinamento
  switch (order) {
    case "data_asc":
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case "data_desc":
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case "inserimento_asc": // alias per data_asc
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case "costo_asc":
      filtered.sort((a, b) => (a.cost ?? 0).compareTo(b.cost ?? 0));
      break;
    case "costo_desc":
      filtered.sort((a, b) => (b.cost ?? 0).compareTo(a.cost ?? 0));
      break;
  }

  return filtered;
});
