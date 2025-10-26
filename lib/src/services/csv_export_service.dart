import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:your_turn/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/utils/csv_web_download_stub.dart'
  if (dart.library.html) 'package:your_turn/src/utils/csv_web_download.dart';

/// Servizio per l'esportazione delle transazioni in formato CSV
class CsvExportService {
  /// Esporta le transazioni di un utente in formato CSV
  static Future<void> exportTransactionsCsv(
    List<MoneyTx> transactions,
    Roommate roommate,
    BuildContext context,
  ) async {
    if (transactions.isEmpty) {
      _announce(context, AppLocalizations.of(context)!.no_transactions_to_export);
      return;
    }

    final csvContent = _generateCsvContent(transactions);
    final bytes = _encodeCsvToBytes(csvContent);
    final fileName = _generateFileName(roommate.name);
    
    triggerDownloadCsv(fileName, bytes);
    _announce(context, AppLocalizations.of(context)!.csv_generated);
  }

  /// Genera il contenuto CSV dalle transazioni
  static String _generateCsvContent(List<MoneyTx> transactions) {
    // Ordina le transazioni per data
    final ordered = [...transactions]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    final df = DateFormat('yyyy-MM-dd HH:mm');
    const separator = ';';
    
    // Header CSV
    final lines = <String>['Data;Nota;Entrata (EUR);Uscita (EUR)'];
    
    double totalIn = 0;
    double totalOut = 0;

    // Processa ogni transazione
    for (final transaction in ordered) {
      final date = df.format(transaction.createdAt.toLocal());
      final isIncome = transaction.amount >= 0;
      final incomeValue = isIncome ? transaction.amount.abs() : 0.0;
      final expenseValue = isIncome ? 0.0 : transaction.amount.abs();
      
      if (incomeValue > 0) totalIn += incomeValue;
      if (expenseValue > 0) totalOut += expenseValue;

      lines.add([
        _escapeForCsv(date),
        _escapeForCsv(transaction.note),
        incomeValue > 0 ? incomeValue.toStringAsFixed(2) : '',
        expenseValue > 0 ? expenseValue.toStringAsFixed(2) : '',
      ].join(separator));
    }

    // Riga dei totali
    lines.add([
      'Totali',
      '',
      totalIn.toStringAsFixed(2),
      totalOut.toStringAsFixed(2)
    ].join(separator));

    return lines.join('\r\n');
  }

  /// Converte il contenuto CSV in bytes con BOM UTF-8 per Excel
  static Uint8List _encodeCsvToBytes(String content) {
    return Uint8List.fromList([
      ...const [0xEF, 0xBB, 0xBF], // BOM UTF-8 per compatibilitÃƒÆ’Ã‚Â  Excel
      ...utf8.encode(content),
    ]);
  }

  /// Genera il nome del file CSV
  static String _generateFileName(String roommatteName) {
    final safeName = roommatteName.replaceAll(' ', '_');
    return 'transazioni_$safeName.csv';
  }

  /// Esegue l'escape dei caratteri speciali per CSV
  static String _escapeForCsv(String text) {
    return '"${text.replaceAll('"', '""')}"';
  }

  /// Annuncia un messaggio per l'accessibilitÃƒÆ’Ã‚Â 
  static void _announce(BuildContext context, String message) {
    SemanticsService.announce(message, Directionality.of(context));
  }

  /// Calcola le statistiche delle transazioni
  static Map<String, double> calculateStatistics(List<MoneyTx> transactions) {
    double totalIncome = 0;
    double totalExpenses = 0;
    
    for (final tx in transactions) {
      if (tx.amount >= 0) {
        totalIncome += tx.amount;
      } else {
        totalExpenses += tx.amount.abs();
      }
    }
    
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
      'transactionCount': transactions.length.toDouble(),
    };
  }

  /// Filtra le transazioni per periodo
  static List<MoneyTx> filterByDateRange(
    List<MoneyTx> transactions,
    DateTimeRange dateRange,
  ) {
    return transactions.where((tx) {
      return !tx.createdAt.isBefore(dateRange.start) && 
             !tx.createdAt.isAfter(dateRange.end);
    }).toList();
  }

  /// Raggruppa le transazioni per mese
  static Map<String, List<MoneyTx>> groupByMonth(List<MoneyTx> transactions) {
    final grouped = <String, List<MoneyTx>>{};
    final monthFormat = DateFormat('yyyy-MM');
    
    for (final tx in transactions) {
      final monthKey = monthFormat.format(tx.createdAt);
      grouped.putIfAbsent(monthKey, () => []).add(tx);
    }
    
    return grouped;
  }
}
