import 'package:flutter_test/flutter_test.dart';
import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/services/csv_export_service.dart';
import 'package:flutter/material.dart';


void main() {
  group('CsvExportService basic tests', () {
    test('calculateStatistics should compute correct totals', () {
      final transactions = [
        MoneyTx(
          id: '1',
          roommateId: 'r1',
          amount: 100,
          note: 'entrata',
          createdAt: DateTime(2024, 5, 1),
          category: [stockCategories.first],
        ),
        MoneyTx(
          id: '2',
          roommateId: 'r1',
          amount: -40,
          note: 'uscita',
          createdAt: DateTime(2024, 5, 2),
          category: [stockCategories.first],
        ),
      ];

      final stats = CsvExportService.calculateStatistics(transactions);
      expect(stats['totalIncome'], 100);
      expect(stats['totalExpenses'], 40);
      expect(stats['balance'], 60);
      expect(stats['transactionCount'], 2);
    });

    test('filterByDateRange should include transactions within range', () {
      final now = DateTime.now();
      final transactions = [
        MoneyTx(
          id: '1',
          roommateId: 'r1',
          amount: 10,
          note: 'in range',
          createdAt: now,
          category: [stockCategories.first],
        ),
        MoneyTx(
          id: '2',
          roommateId: 'r1',
          amount: 5,
          note: 'out of range',
          createdAt: now.subtract(const Duration(days: 10)),
          category: [stockCategories.first],
        ),
      ];

      final range = DateTimeRange(
        start: now.subtract(const Duration(days: 1)),
        end: now.add(const Duration(days: 1)),
      );

      final filtered = CsvExportService.filterByDateRange(transactions, range);
      expect(filtered.length, 1);
      expect(filtered.first.note, 'in range');
    });
  });
}
