import 'package:flutter/material.dart';
import 'package:your_turn/src/models/todo_category.dart';

/// Funzione per convertire stringa esadecimale in Color
Color _hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

/// Funzione per schiarire i colori scuri
Color lighten(Color color, [double amount = .4]) {
  final hsl = HSLColor.fromColor(color);
  final light = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(light).toColor();
}

/// Widget chip per visualizzare la categoria con icona e colore
class TodoCategoryChip extends StatelessWidget {
  final TodoCategory category;
  final bool isSmall;

  const TodoCategoryChip({
    super.key,
    required this.category,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = _hexToColor(category.color);
    final isDark = baseColor.computeLuminance() < 0.35;
    final chipBg =
        isDark ? lighten(baseColor, 0.7) : baseColor.withOpacity(0.10);
    final chipText = isDark ? Colors.black : baseColor;

    return Semantics(
      label: 'Categoria: ${category.name}',
      child: Chip(
        avatar: Icon(
          category.icon,
          size: isSmall ? 16 : 18,
          color: chipText,
        ),
        label: Text(
          category.name,
          style: TextStyle(
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: chipText,
          ),
        ),
        backgroundColor: chipBg,
        side: BorderSide(
          color: chipText.withOpacity(0.3),
          width: 1,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 12,
          vertical: isSmall ? 2 : 4,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity:
            isSmall ? VisualDensity.compact : VisualDensity.standard,
      ),
    );
  }
}

/// Widget per selezionare una categoria (con icone e colori)
class TodoCategorySelector extends StatelessWidget {
  final TodoCategory? selectedCategory;
  final ValueChanged<TodoCategory> onCategorySelected;
  final List<TodoCategory> categories;
  final bool wrap;

  const TodoCategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
    this.wrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final chips = categories.map((category) {
      final baseColor = _hexToColor(category.color);
      final isSelected = selectedCategory?.id == category.id;
      final isDark = baseColor.computeLuminance() < 0.35;
      final chipBg =
          isDark ? lighten(baseColor, 0.7) : baseColor.withOpacity(0.10);
      final chipSelectedBg =
          isDark ? lighten(baseColor, 0.5) : baseColor.withOpacity(0.30);
      final chipText = isDark ? Colors.black : baseColor;

      return Semantics(
        button: true,
        label: 'Seleziona categoria ${category.name}',
        selected: isSelected,
        child: FilterChip(
          avatar: Icon(
            category.icon,
            size: 18,
            color: chipText,
          ),
          label: Text(
            category.name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: chipText,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onCategorySelected(category),
          backgroundColor: chipBg,
          selectedColor: chipSelectedBg,
          side: BorderSide(
            color: isSelected ? chipText : chipText.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }).toList();

    if (wrap) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips
              .map((chip) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: chip,
                  ))
              .toList(),
        ),
      );
    }
  }
}
