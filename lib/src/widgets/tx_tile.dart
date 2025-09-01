// lib/widgets/tx_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/widgets/expense_category_chip.dart';

class TxTile extends StatelessWidget {
  const TxTile({super.key, required this.tx, required this.money});
  final MoneyTx tx;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.amount >= 0;
    final amountText = money.format(tx.amount.abs());
    final dateText = DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt);
    final base = isPositive ? Colors.teal : Colors.red;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [base.withOpacity(0.04), base.withOpacity(0.10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: base.withOpacity(0.30), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: base.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: tx.category.color.withOpacity(0.18),
              child: Icon(tx.category.icon, color: tx.category.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.note,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey.shade800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ExpenseCategoryChip(category: tx.category, isSmall: true),
                      const Spacer(),
                      Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(dateText,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              (isPositive ? '+ ' : '- ') + amountText,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isPositive ? Colors.teal.shade700 : Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
