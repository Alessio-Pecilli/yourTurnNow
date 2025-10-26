// lib/widgets/tx_tile.dart
import 'package:flutter/material.dart';
import 'package:your_turn/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/widgets/expense_category_chip.dart';
// ✅ nuovo nome coerente

// Estensione per convertire stringhe hex in Color
extension HexColorExtension on String {
  Color toColor() {
    var hex = replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // aggiunge alpha pieno se mancante
    return Color(int.parse(hex, radix: 16));
  }
}

class TxTile extends StatelessWidget {
  const TxTile({
    super.key,
    required this.tx,
    required this.money,
    this.onEdit,
    this.onDelete,
  });

  final MoneyTx tx;
  final NumberFormat money;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.amount >= 0;
    final amountText = money.format(tx.amount.abs());
    final dateText = DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt);
    final base = isPositive ? Colors.teal : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [base.withOpacity(0.03), base.withOpacity(0.07)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: base.withOpacity(0.15), width: 0.7),
        boxShadow: [
          BoxShadow(
            color: base.withOpacity(0.07),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: tx.category[0].color.toColor().withOpacity(0.18),
                  child: Icon(
                    tx.category[0].icon,
                    color: tx.category[0].color.toColor(),
                    size: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tx.note,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit!();
                    if (value == 'delete' && onDelete != null) onDelete!();
                  },
                  itemBuilder: (context) => [
                     PopupMenuItem(
                      value: 'edit',
                      child: Text(AppLocalizations.of(context)!.common_edit, style: const TextStyle(fontSize: 12)),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(AppLocalizations.of(context)!.common_delete, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 13),
                  tooltip: AppLocalizations.of(context)!.common_actions,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                TodoCategoryChip(category: tx.category[0], isSmall: true), // ✅ aggiornato
                const Spacer(),
                Icon(Icons.schedule, size: 9, color: Colors.grey.shade500),
                const SizedBox(width: 1),
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                (isPositive ? '+ ' : '- ') + amountText,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: isPositive ? Colors.teal.shade700 : Colors.red.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
