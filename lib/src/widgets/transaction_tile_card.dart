import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:your_turn/src/models/money_tx.dart';

/// Widget compatto per visualizzare una transazione in formato card
/// con importo, categoria, nota e azioni modifica/elimina
class TransactionTileCard extends StatelessWidget {
  const TransactionTileCard({
    super.key,
    required this.tx,
    required this.money,
    required this.onDelete,
    required this.onEdit,
    this.dense = false,
  });

  final MoneyTx tx;
  final NumberFormat money;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isIn = tx.amount >= 0;
    final amountStr = money.format(tx.amount.abs());
    final dateStr = DateFormat('dd/MM/yy • HH:mm').format(tx.createdAt);
    final catIcon = tx.category.icon;
    final catColor = tx.category.color;
    final catLabel = tx.category.label;

    final amountColor = isIn ? Colors.green.shade700 : Colors.red.shade700;

    final semanticsLabel = StringBuffer()
      ..write(isIn ? 'Entrata ' : 'Uscita ')
      ..write(amountStr)
      ..write(tx.note.trim().isEmpty ? '' : ' per ${tx.note}')
      ..write('. ')
      ..write('Categoria $catLabel. ')
      ..write('In data $dateStr.');

    return Semantics(
      label: semanticsLabel.toString(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2), // Solo margine verticale come todo
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: isIn
                ? [Colors.green.shade50.withOpacity(0.3), Colors.green.shade50.withOpacity(0.7)]
                : [Colors.white, Colors.grey.shade100],
            begin: isIn ? Alignment.bottomRight : Alignment.topLeft,
            end: isIn ? Alignment.topLeft : Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isIn ? Colors.green : catColor).withOpacity(0.07),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: isIn ? Colors.green.shade200 : catColor.withOpacity(0.3),
            width: 0.7,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(6), // Padding compatto come i todo
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Prima riga: icona + importo + pulsanti
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icona compatta accanto al testo
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          catIcon,
                          size: 14,
                          color: catColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Importo (principale)
                      Expanded(
                        child: Text(
                          (isIn ? '+ ' : '- ') + amountStr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: amountColor,
                          ),
                        ),
                      ),
                      // Pulsanti compatti
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              tooltip: 'Modifica',
                              icon: Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 16),
                              onPressed: onEdit,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              tooltip: 'Elimina',
                              icon: Icon(Icons.delete_rounded, color: Colors.red.shade700, size: 16),
                              onPressed: onDelete,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Seconda riga: nota (solo se presente)
                  if (tx.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 32), // Allineato all'importo
                      child: Text(
                        tx.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                  // Terza riga: data
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.only(left: 32), // Allineato all'importo
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 10, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}