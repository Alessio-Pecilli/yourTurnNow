import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/mock_db.dart';
import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/todo_category.dart';

/// Controller principale per la gestione delle transazioni.
/// Usa solo TodoCategory (le categorie personalizzabili dell’app).
class TransactionsCtrl extends StateNotifier<List<MoneyTx>> {
  TransactionsCtrl() : super(mockTransactions);

  /// Aggiunge una nuova transazione
  void addTx({
    required String roommateId,
    required double amount,
    required String note,
    DateTime? when,
    List<TodoCategory>? category,
  }) {
    final now = when ?? DateTime.now();


    final tx = MoneyTx(
      id: now.microsecondsSinceEpoch.toString(),
      roommateId: roommateId,
      amount: amount,
      note: note,
      createdAt: now,
      category: category!,
    );

    // Inserisci in cima alla lista (ordinamento decrescente per data)
    state = [tx, ...state];
  }

  /// Rimuove una transazione
  void removeTx(String txId) {
    state = state.where((t) => t.id != txId).toList();
  }

  /// Aggiorna una transazione
  void updateTx(MoneyTx updated) {
    state = [
      for (final t in state)
        if (t.id == updated.id) updated else t,
    ];
  }
}

/// Provider principale per tutte le transazioni
final transactionsProvider =
    StateNotifierProvider<TransactionsCtrl, List<MoneyTx>>(
        (_) => TransactionsCtrl());

/// Provider per ottenere solo le transazioni di un utente (ordinate per data)
final userTransactionsProvider =
    Provider.family<List<MoneyTx>, String>((ref, uid) {
  final all = ref.watch(transactionsProvider);
  final mine = all.where((t) => t.roommateId == uid).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return mine;
});
