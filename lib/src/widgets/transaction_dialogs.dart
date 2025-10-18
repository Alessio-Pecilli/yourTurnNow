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
          title: const Text('Elimina transazione'),
          content: const Text('Sei sicuro di voler eliminare questa transazione?'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Elimina'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      ref.read(transactionsProvider.notifier).removeTx(tx.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transazione eliminata.')),
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
            title: const Text('Modifica transazione'),
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
                    _buildAmountField(amountCtrl),
                    const SizedBox(height: 16),
                    _buildMultiCategorySelector(allCategories, selectedCategories,
                        (newList) {
                      setState(() => selectedCategories = newList);
                    }),
                    const SizedBox(height: 16),
                    _buildNoteField(noteCtrl),
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
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.pop(context, true);
                },
                child: const Text('Salva'),
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
          const SnackBar(content: Text('Transazione modificata.')),
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
            title: const Text('Nuova transazione'),
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
                    _buildAmountField(amountCtrl),
                    const SizedBox(height: 16),
                    _buildMultiCategorySelector(categories, selectedCategories,
                        (newList) {
                      setState(() => selectedCategories = newList);
                    }),
                    const SizedBox(height: 16),
                    _buildNoteField(noteCtrl),
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
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.pop(context, true);
                },
                child: const Text('Aggiungi'),
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

  static Widget _buildAmountField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\-]'))
      ],
      decoration: const InputDecoration(
        labelText: 'Importo (€)',
        hintText: 'positivo = accredito, negativo = addebito',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Campo obbligatorio';
        final p = double.tryParse(v.replaceAll(',', '.'));
        if (p == null || p == 0.0) return 'Inserisci un numero diverso da 0';
        return null;
      },
    );
  }

  static Widget _buildNoteField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Nota (opzionale)',
        hintText: 'es. descrizione della spesa',
      ),
    );
  }

  /// 🔹 Nuovo: selezione multipla categorie
  static Widget _buildMultiCategorySelector(
    List<TodoCategory> categories,
    List<TodoCategory> selectedCategories,
    void Function(List<TodoCategory>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categorie', style: TextStyle(fontWeight: FontWeight.bold)),
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
      children: [
        const Text('Data:', style: TextStyle(fontWeight: FontWeight.bold)),
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
              builder: (context, child) => Theme(
                data: ThemeData.light(useMaterial3: true),
                child: Dialog(backgroundColor: Colors.white, child: child!),
              ),
            );
            if (picked != null) onChanged(picked);
          },
        ),
      ],
    );
  }
}
