import 'package:flutter/material.dart';

typedef ColorSelected = void Function(String hex);

class AdminColorPicker extends StatelessWidget {
  final List<Map<String, String>> colors;
  final String selectedHex;
  final ColorSelected onSelected;

  const AdminColorPicker({Key? key, required this.colors, required this.selectedHex, required this.onSelected}) : super(key: key);

  Color _hexToColor(String hex) => Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: colors.map((colorData) {
        final colorHex = colorData['hex']!;
        final isSelected = colorHex == selectedHex;
        return Semantics(
          label: 'Colore ${colorData['name']}',
          selected: isSelected,
          child: GestureDetector(
            onTap: () => onSelected(colorHex),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _hexToColor(colorHex),
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.black87 : Colors.grey.shade300, width: isSelected ? 3 : 1),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
