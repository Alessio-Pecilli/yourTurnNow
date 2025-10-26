import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:your_turn/src/models/money_tx.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/src/providers/categories_provider.dart';
import 'package:your_turn/src/providers/roommates_provider.dart';
import 'package:your_turn/src/providers/transactions_provider.dart';
import 'package:your_turn/l10n/app_localizations.dart';

/// Utility class per gestire i dialoghi delle transazioni
class TransactionDialogs {
  /// Dialogo di conferma per eliminare una transazione
  static Future<void> showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    MoneyTx tx,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: AlertDialog(
          title: Text(AppLocalizations.of(context)!.dialog_delete_transaction_title),
          content: Text(AppLocalizations.of(context)!.dialog_delete_transaction_content),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.common_delete),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      ref.read(transactionsProvider.notifier).removeTx(tx.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.snackbar_transaction_deleted)),
        );
      }
    }
  }

  /// Dialogo per modificare una transazione esistente
  static Future<void> showEditDialog(
    BuildContext context,
    WidgetRef ref,
    MoneyTx tx,
  ) async {
    final amountCtrl = TextEditingController(text: tx.amount.toString());
    final noteCtrl = TextEditingController(text: tx.note);
    final formKey = GlobalKey<FormState>();

    List<TodoCategory> selectedCategories = [...tx.category];
    DateTime? selectedDate = tx.createdAt;

    final allCategories = ref.read(categoriesProvider);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.dialog_edit_transaction_title),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountField(amountCtrl, context),
                    const SizedBox(height: 16),
                    _buildMultiCategorySelector(context, allCategories, selectedCategories,
                        (newList) {
                      setState(() => selectedCategories = newList);
                    }),
                    const SizedBox(height: 16),
                    _buildNoteField(noteCtrl, context),
                    const SizedBox(height: 16),
                    _buildDateSelector(context, selectedDate, (date) {
                      setState(() => selectedDate = date);
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.common_cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.pop(context, true);
                },
                child: Text(AppLocalizations.of(context)!.common_save),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      final amount = double.parse(amountCtrl.text.replaceAll(',', '.'));
      final note = noteCtrl.text.trim();
      final when = selectedDate ?? DateTime.now();
      final updated = tx.copyWith(
        amount: amount,
        note: note,
        createdAt: when,
        category: selectedCategories,
      );
      ref.read(transactionsProvider.notifier).updateTx(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.snackbar_transaction_updated)),
        );
      }
    }
  }

  /// Dialogo per aggiungere una nuova transazione
  static Future<void> showAddDialog(
    BuildContext context,
    WidgetRef ref,
    Roommate roommate,
  ) async {
    final categories = ref.read(categoriesProvider);
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    List<TodoCategory> selectedCategories = [];
    DateTime? selectedDate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.dialog_new_transaction_title),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountField(amountCtrl, context),
                    const SizedBox(height: 16),
                    _buildMultiCategorySelector(context,categories, selectedCategories,
                        (newList) {
                      setState(() => selectedCategories = newList);
                    }),
                    const SizedBox(height: 16),
                    _buildNoteField(noteCtrl, context),
                    const SizedBox(height: 16),
                    _buildDateSelector(context, selectedDate, (date) {
                      setState(() => selectedDate = date);
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.common_cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.pop(context, true);
                },
                child: Text(AppLocalizations.of(context)!.common_add),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true) return;

    final amount = double.parse(amountCtrl.text.replaceAll(',', '.'));
    final note = noteCtrl.text.trim();
    final when = selectedDate ?? DateTime.now();

    // Aggiorna budget e aggiungi transazione
    ref.read(roommatesProvider.notifier).adjustBudgetFor(roommate.id, amount);
    ref.read(transactionsProvider.notifier).addTx(
      roommateId: roommate.id,
      amount: amount,
      note: note,
      category: selectedCategories,
      when: when,
    );
  }

  // --- CAMPI ---

  static Widget _buildAmountField(TextEditingController controller, BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\-]'))
      ],
      decoration:  InputDecoration(
        labelText: AppLocalizations.of(context)!.tx_amount_label,
        hintText: AppLocalizations.of(context)!.tx_amount_hint,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.tx_amount_required;
        final p = double.tryParse(v.replaceAll(',', '.'));
        if (p == null || p == 0.0) return AppLocalizations.of(context)!.tx_amount_nonzero;
        return null;
      },
    );
  }

  static Widget _buildNoteField(TextEditingController controller, BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.tx_note_label,
        hintText: AppLocalizations.of(context)!.tx_note_hint,
      ),
    );
  }

  /// ðŸ”¹ Nuovo: selezione multipla categorie
  static Widget _buildMultiCategorySelector(
    BuildContext context,
    List<TodoCategory> categories,
    List<TodoCategory> selectedCategories,
    void Function(List<TodoCategory>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.todo_dialog_categories, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final sel = selectedCategories.any((c) => c.id == category.id);
            final categoryColor = Color(
                int.parse(category.color.substring(1), radix: 16) + 0xFF000000);

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon,
                      size: 18, color: sel ? Colors.white : categoryColor),
                  const SizedBox(width: 6),
                  Text(category.name),
                ],
              ),
              selected: sel,
              onSelected: (_) {
                final newList = [...selectedCategories];
                if (sel) {
                  newList.removeWhere((c) => c.id == category.id);
                } else {
                  newList.add(category);
                }
                onChanged(newList);
              },
              backgroundColor: sel ? categoryColor : Colors.white,
              selectedColor: categoryColor,
              side: BorderSide(color: categoryColor, width: 1.5),
              labelStyle: TextStyle(
                color: sel ? Colors.white : categoryColor,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildDateSelector(
  BuildContext context,
  DateTime? selectedDate,
  void Function(DateTime?) onChanged,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('${AppLocalizations.of(context)!.table_date}:', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        icon: const Icon(Icons.calendar_today),
        label: Text(
          selectedDate == null
              ? 'Oggi'
              : DateFormat('dd/MM/yyyy').format(selectedDate),
        ),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),

            // âœ… fix qui
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: Theme(
                  data: ThemeData.light(useMaterial3: true),
                  child: child!,
                ),
              );
            },
          );

          if (picked != null) onChanged(picked);
        },
      ),
    ],
  );
}

}
