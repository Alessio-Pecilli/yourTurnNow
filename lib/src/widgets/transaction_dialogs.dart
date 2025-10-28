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
  final formKey = GlobalKey<FormState>();
  final amountCtrl = TextEditingController(text: tx.amount.toStringAsFixed(2));
  final noteCtrl = TextEditingController(text: tx.note);
  final allCategories = ref.read(categoriesProvider);

  List<TodoCategory> selectedCategories = [...tx.category];
  DateTime? selectedDate = tx.createdAt;

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 12,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.edit, color: Colors.blue.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.dialog_edit_transaction_title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Importo
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: amountCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]')),
],


                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.todo_dialog_cost_label,
                            prefixIcon: Icon(Icons.euro, color: Colors.green.shade700),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          style: TextStyle(color: Colors.grey.shade800),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return AppLocalizations.of(context)!.todo_dialog_cost_required;
                            }
                            final parsed = double.tryParse(v.replaceAll(',', '.'));
                                                        if (parsed == null) return AppLocalizations.of(context)!.error_operation_not_allowed;

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Categorie
                      // Categorie e Data affiancate
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Sezione categorie (2/3)
    Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.todo_dialog_categories,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: allCategories.map((category) {
                final isSelected = selectedCategories.any((c) => c.id == category.id);
                final categoryColor = Color(
                  int.parse(category.color.substring(1), radix: 16) + 0xFF000000,
                );
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, size: 16, color: categoryColor),
                      const SizedBox(width: 3),
                      Text(category.name, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.removeWhere((c) => c.id == category.id);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade50,
                  selectedColor: Colors.grey.shade200,
                  checkmarkColor: categoryColor,
                  side: BorderSide(
                    color: isSelected ? categoryColor : categoryColor.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  labelStyle: TextStyle(
                    color: categoryColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 12),

    // Sezione data (1/3)
    Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.todo_dialog_due_date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 20),
              title: Text(
                selectedDate == null
                    ? AppLocalizations.of(context)!.todo_dialog_optional
                    : DateFormat('dd/MM/yyyy').format(selectedDate!.toLocal()),
                style: TextStyle(
                  color: selectedDate == null ? Colors.grey.shade600 : Colors.grey.shade800,
                  fontWeight: selectedDate == null ? FontWeight.normal : FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              trailing: selectedDate != null
                  ? GestureDetector(
                      onTap: () => setState(() => selectedDate = null),
                      child: Icon(Icons.clear, color: Colors.grey.shade600, size: 16),
                    )
                  : Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 12),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
  final mq = MediaQuery.of(context);
  return MediaQuery(
    data: mq.copyWith(
      textScaler: TextScaler.linear(1.0), // 👈 forza uno scaling valido
    ),
    child: Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: Colors.blue.shade700,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.grey.shade800,
        ),
      ),
      child: child!,
    ),
  );
},

                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ),
          ),
        ],
      ),
    ),
  ],
),
const SizedBox(height: 16),


                      // Nota
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: noteCtrl,
                          textInputAction: TextInputAction.next,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.todo_dialog_notes_label,
                            prefixIcon: Icon(Icons.notes, color: Colors.blue.shade700),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            hintText: AppLocalizations.of(context)!.todo_dialog_notes_hint,
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.of(context)!.common_cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.pop(context, true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(AppLocalizations.of(context)!.common_save, style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
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
  final formKey = GlobalKey<FormState>();
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final categories = ref.read(categoriesProvider);

  List<TodoCategory> selectedCategories = [];
  DateTime? selectedDate;

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 12,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.attach_money, color: Colors.green.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.dialog_new_transaction_title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Importo
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: amountCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]')),
],

                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.todo_dialog_cost_label,
                            prefixIcon: Icon(Icons.euro, color: Colors.green.shade700),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            hintText: '12.50',
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          style: TextStyle(color: Colors.grey.shade800),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return AppLocalizations.of(context)!.todo_dialog_cost_required;
                            }
                            final parsed = double.tryParse(v.replaceAll(',', '.'));
                            if (parsed == null) return AppLocalizations.of(context)!.error_operation_not_allowed;
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Categorie
                      // Categorie e Data affiancate
// Categorie e Data affiancate con scroll orizzontale sicuro
// Categorie e Data affiancate con scroll orizzontale sicuro
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.todo_dialog_categories,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: categories.map((category) {
                  final isSelected = selectedCategories.any((c) => c.id == category.id);
                  final categoryColor = Color(
                    int.parse(category.color.substring(1), radix: 16) + 0xFF000000,
                  );
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, size: 16, color: categoryColor),
                        const SizedBox(width: 3),
                        Text(
                          category.name,
                          style: const TextStyle(fontSize: 12),
                          textScaler: TextScaler.noScaling, // 👈 evita errori di scala
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedCategories.add(category);
                        } else {
                          selectedCategories.removeWhere((c) => c.id == category.id);
                        }
                      });
                    },
                    backgroundColor: Colors.grey.shade50,
                    selectedColor: Colors.grey.shade200,
                    checkmarkColor: categoryColor,
                    side: BorderSide(
                      color: isSelected ? categoryColor : categoryColor.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: categoryColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.todo_dialog_due_date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 18),
              title: Text(
                selectedDate == null
                    ? AppLocalizations.of(context)!.todo_dialog_optional
                    : DateFormat('dd/MM').format(selectedDate!.toLocal()),
                style: TextStyle(
                  color: selectedDate == null ? Colors.grey.shade600 : Colors.grey.shade800,
                  fontWeight: selectedDate == null ? FontWeight.normal : FontWeight.bold,
                  fontSize: 12,
                ),
                textScaler: TextScaler.noScaling, // 👈 protegge anche il testo della data
              ),
              trailing: selectedDate != null
                  ? GestureDetector(
                      onTap: () => setState(() => selectedDate = null),
                      child: Icon(Icons.clear, color: Colors.grey.shade600, size: 16),
                    )
                  : Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 12),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
  final mq = MediaQuery.of(context);
  return MediaQuery(
    data: mq.copyWith(
      textScaler: TextScaler.linear(1.0), 
    ),
    child: Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: Colors.blue.shade700,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.grey.shade800,
        ),
      ),
      child: child!,
    ),
  );
},

                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ),
          ),
        ],
      ),
    ),
  ],
),


const SizedBox(height: 16),


                      // Nota
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: noteCtrl,
                          textInputAction: TextInputAction.next,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.todo_dialog_notes_label,
                            prefixIcon: Icon(Icons.notes, color: Colors.blue.shade700),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            hintText: AppLocalizations.of(context)!.todo_dialog_notes_hint,
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                      const SizedBox(height: 16),

                      
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.of(context)!.common_cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.pop(context, true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(AppLocalizations.of(context)!.common_add, style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );

  if (ok != true) return;

  final amount = double.parse(amountCtrl.text.replaceAll(',', '.'));
  final note = noteCtrl.text.trim();
  final when = selectedDate ?? DateTime.now();

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
