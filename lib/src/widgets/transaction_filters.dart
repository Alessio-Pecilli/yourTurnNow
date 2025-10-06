import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:your_turn/src/models/todo_category.dart';

/// Widget per i filtri delle transazioni: categorie e range di date
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
            // Top row: Categorie + Data/Reset
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categorie
                Expanded(
                  flex: 3,
                  child: _buildCategoryFilters(),
                ),
                
                const SizedBox(width: 12),
                
                // Data e Reset
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Data e Reset sulla stessa riga
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDateFilter(context),
                        const SizedBox(width: 8),
                        _buildResetButton(),
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

  Widget _buildCategoryFilters() {
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
                color: selectedCategory == null ? Colors.white : Colors.blue.shade700
              ),
              const SizedBox(width: 4),
              const Text('Tutte', style: TextStyle(fontSize: 12)),
            ],
          ),
          selected: selectedCategory == null,
          onSelected: (_) => onCategoryChanged(null),
          backgroundColor: selectedCategory == null ? Colors.blue.shade700 : Colors.white,
          selectedColor: Colors.blue.shade700,
          side: BorderSide(color: Colors.blue.shade700, width: 1.5),
          labelStyle: TextStyle(
            color: selectedCategory == null ? Colors.white : Colors.blue.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        
        // Chips delle categorie
        ...categories.map((category) {
          final categoryColor = Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000);
          final isSelected = selectedCategory?.id == category.id;
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: 16, color: isSelected ? Colors.white : categoryColor),
                const SizedBox(width: 4),
                Text(
                  category.name.length > 8 ? category.name.substring(0, 8) : category.name, 
                  style: const TextStyle(fontSize: 12)
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => onCategoryChanged(category),
            backgroundColor: isSelected ? categoryColor : Colors.white,
            selectedColor: categoryColor,
            side: BorderSide(color: categoryColor, width: 1.5),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : categoryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        }),
      ],
    );
  }

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
              : '${DateFormat('dd/MM').format(selectedDateRange!.start)}-${DateFormat('dd/MM').format(selectedDateRange!.end)}',
          style: const TextStyle(fontSize: 12),
        ),
        onPressed: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            initialDateRange: selectedDateRange,
            builder: (context, child) {
              return Theme(
                data: ThemeData.light(useMaterial3: true),
                child: Dialog(backgroundColor: Colors.white, child: child!),
              );
            },
          );
          if (picked != null) {
            onDateRangeChanged(picked);
          }
        },
      ),
    );
  }

  Widget _buildResetButton() {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36), // Stessa altezza del bottone data
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
      ),
      onPressed: onReset,
      child: const Text('Reset'),
    );
  }
}