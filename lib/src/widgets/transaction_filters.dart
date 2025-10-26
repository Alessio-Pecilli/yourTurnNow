import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:your_turn/src/models/todo_category.dart';
import 'package:your_turn/l10n/app_localizations.dart';

/// Widget per i filtri delle transazioni: categorie e range di date.
class TransactionFilters extends StatelessWidget {
  const TransactionFilters({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.selectedDateRange,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
    required this.onReset,
  });

  final List<TodoCategory> categories;
  final TodoCategory? selectedCategory;
  final DateTimeRange? selectedDateRange;
  final void Function(TodoCategory?) onCategoryChanged;
  final void Function(DateTimeRange?) onDateRangeChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Filtro per categoria
                Expanded(
                  flex: 3,
                  child: _buildCategoryFilters(context),
                ),
                const SizedBox(width: 12),
                // 🔹 Filtro per date e reset
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDateFilter(context),
                        const SizedBox(width: 8),
                        _buildResetButton(context),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------
  // 🔸 Chip categorie
  // -----------------------
  Widget _buildCategoryFilters(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        // Chip "Tutte"
        ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.label_outline,
                size: 16,
                color:
                    selectedCategory == null ? Colors.white : Colors.blue.shade700,
              ),
              const SizedBox(width: 4),
              Text(AppLocalizations.of(context)!.categories_all, style: const TextStyle(fontSize: 12)),
            ],
          ),
          selected: selectedCategory == null,
          onSelected: (_) => onCategoryChanged(null),
          backgroundColor:
              selectedCategory == null ? Colors.blue.shade700 : Colors.white,
          selectedColor: Colors.blue.shade700,
          side: BorderSide(color: Colors.blue.shade700, width: 1.5),
          labelStyle: TextStyle(
            color:
                selectedCategory == null ? Colors.white : Colors.blue.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),

        // 🔹 Categorie personalizzate (TodoCategory)
        ...categories.map((category) {
          final color =
              Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000);
          final isSelected = selectedCategory?.id == category.id;

          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: 16, color: isSelected ? Colors.white : color),
                const SizedBox(width: 4),
                Text(category.name, style: const TextStyle(fontSize: 12)),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => onCategoryChanged(category),
            backgroundColor: isSelected ? color : Colors.white,
            selectedColor: color,
            side: BorderSide(color: color, width: 1.5),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        }),
      ],
    );
  }

  // -----------------------
  // 🔸 Filtro per intervallo di date
  // -----------------------
  Widget _buildDateFilter(BuildContext context) {
    return Flexible(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          textStyle: const TextStyle(fontSize: 12),
        ),
        icon: const Icon(Icons.date_range, size: 16),
        label: Text(
          selectedDateRange == null
              ? 'Date'
              : '${DateFormat('dd/MM').format(selectedDateRange!.start)} - ${DateFormat('dd/MM').format(selectedDateRange!.end)}',
          style: const TextStyle(fontSize: 12),
        ),
        onPressed: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            initialDateRange: selectedDateRange,
            builder: (context, child) => Theme(
              data: ThemeData.light(useMaterial3: true),
              child: Dialog(backgroundColor: Colors.white, child: child!),
            ),
          );
          if (picked != null) onDateRangeChanged(picked);
        },
      ),
    );
  }

  // -----------------------
  // 🔸 Bottone Reset
  // -----------------------
  Widget _buildResetButton(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
      ),
      onPressed: onReset,
      child: Text(AppLocalizations.of(context)!.common_reset),
    );
  }
}
