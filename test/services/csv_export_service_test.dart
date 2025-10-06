import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_turn/src/services/csv_export_service.dart';
import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/models/expense_category.dart';

void main() {
  group('CsvExportService Tests', () {
    late List<MoneyTx> mockTransactions;
    late Roommate mockRoommate;

    setUp(() {
      mockRoommate = const Roommate(
        id: 'user-1',
        name: 'Mario Rossi',
        monthlyBudget: 100.0,
      );

      mockTransactions = [
        MoneyTx(
          id: 'tx1',
          roommateId: 'user-1',
          amount: 100.0,
          note: 'Stipendio',
          category: ExpenseCategory.altro,
          createdAt: DateTime(2025, 10, 1, 9, 0),
        ),
        MoneyTx(
          id: 'tx2',
          roommateId: 'user-1',
          amount: -25.50,
          note: 'Spesa supermercato',
          category: ExpenseCategory.spesa,
          createdAt: DateTime(2025, 10, 2, 18, 30),
        ),
        MoneyTx(
          id: 'tx3',
          roommateId: 'user-1',
          amount: -15.0,
          note: 'Bolletta luce',
          category: ExpenseCategory.bolletta,
          createdAt: DateTime(2025, 10, 3, 12, 15),
        ),
      ];
    });

    test('calculateStatistics deve calcolare correttamente', () {
      final stats = CsvExportService.calculateStatistics(mockTransactions);

      expect(stats['totalIncome'], 100.0);
      expect(stats['totalExpenses'], 40.5); // 25.50 + 15.0
      expect(stats['balance'], 59.5); // 100.0 - 40.5
      expect(stats['transactionCount'], 3.0);
    });

    test('calculateStatistics con lista vuota', () {
      final stats = CsvExportService.calculateStatistics([]);

      expect(stats['totalIncome'], 0.0);
      expect(stats['totalExpenses'], 0.0);
      expect(stats['balance'], 0.0);
      expect(stats['transactionCount'], 0.0);
    });

    test('filterByDateRange deve filtrare correttamente', () {
      final dateRange = DateTimeRange(
        start: DateTime(2025, 10, 1),
        end: DateTime(2025, 10, 3),
      );

      final filtered = CsvExportService.filterByDateRange(mockTransactions, dateRange);

      // Test semplice - verifica solo che il filtro funzioni
      expect(filtered.length, greaterThan(0));
    });

    test('groupByMonth deve raggruppare correttamente', () {
      final transactionsMultiMonth = [
        ...mockTransactions,
        MoneyTx(
          id: 'tx4',
          roommateId: 'user-1',
          amount: -50.0,
          note: 'Cena novembre',
          category: ExpenseCategory.altro,
          createdAt: DateTime(2025, 11, 15, 20, 0),
        ),
      ];

      final grouped = CsvExportService.groupByMonth(transactionsMultiMonth);

      expect(grouped.keys.length, 2);
      expect(grouped['2025-10']?.length, 3); // Ottobre
      expect(grouped['2025-11']?.length, 1); // Novembre
    });

    test('mockRoommate deve essere creato correttamente', () {
      expect(mockRoommate.id, 'user-1');
      expect(mockRoommate.name, 'Mario Rossi');
      expect(mockRoommate.monthlyBudget, 100.0);
    });

    test('lista delle transazioni deve essere processabile', () {
      // Test semplice che verifica che le transazioni siano valide
      expect(mockTransactions.length, 3);
      expect(mockTransactions[0].amount, 100.0);
      expect(mockTransactions[1].amount, -25.50);
      expect(mockTransactions[2].amount, -15.0);
      
      // Test che le categorie siano assegnate correttamente
      expect(mockTransactions[0].category, ExpenseCategory.altro);
      expect(mockTransactions[1].category, ExpenseCategory.spesa);
      expect(mockTransactions[2].category, ExpenseCategory.bolletta);
    });
  });
}