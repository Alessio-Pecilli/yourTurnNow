import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:your_turn/l10n/app_localizations.dart';

class PdfExportService {
  // 🔹 Funzione per rimuovere emoji e simboli non compatibili
  static String _sanitizeText(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F6FF}'
      r'\u{1F900}-\u{1F9FF}'
      r'\u{2600}-\u{26FF}'
      r'\u{2700}-\u{27BF}'
      r'\u{1F1E6}-\u{1F1FF}'
      r'\u{1F700}-\u{1F77F}]',
      unicode: true,
    );
    return text.replaceAll(emojiRegex, '');
  }


  // 🔹 Esporta PDF
  static Future<void> exportTransactionsPdf(
    List transactions,
    dynamic me,
    BuildContext context,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                AppLocalizations.of(context)!.common_download + ' - ' + _sanitizeText(me.name),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  AppLocalizations.of(context)!.table_date,
                  AppLocalizations.of(context)!.tx_note_label,
                  AppLocalizations.of(context)!.table_amount_eur,
                  AppLocalizations.of(context)!.table_category
                ],
                data: transactions.map((tx) {
                  final categorieTesto = tx.category.isEmpty
                      ? '-'
                      : tx.category
                          .map((c) => _sanitizeText(c.name))
                          .join(', ');

                  return [
                    dateFormat.format(tx.createdAt),
                    _sanitizeText(tx.note.isNotEmpty ? tx.note : '-'),
                    '${tx.amount.toStringAsFixed(2)} EUR',
                    categorieTesto,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    // 🔹 Mostra / scarica PDF (funziona anche su web)
    final bytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
    );
  }

  

 }
