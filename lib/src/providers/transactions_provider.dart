import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_turn/src/mock_db.dart';
import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/expense_category.dart';


class TransactionsCtrl extends StateNotifier<List<MoneyTx>> {
  TransactionsCtrl() : super(mockTransactions);

  void addTx({
    required String roommateId,
    required double amount,
    required String note,
    DateTime? when,
    ExpenseCategory? category,
  })  {
    final now = when ?? DateTime.now();
    final inferredCategory = category ?? ExpenseCategory.inferFromNote(note);
    final tx = MoneyTx(
      id: now.microsecondsSinceEpoch.toString(),
      roommateId: roommateId,
      amount: amount,
      note: note,
      createdAt: now,
      category: inferredCategory,
    );
    state = [tx, ...state];
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsCtrl, List<MoneyTx>>((_) => TransactionsCtrl());

/// Transazioni di un utente (ord. decrescente)
final userTransactionsProvider = Provider.family<List<MoneyTx>, String>((ref, uid) {
  final all = ref.watch(transactionsProvider);
  final mine = all.where((t) => t.roommateId == uid).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return mine;
});