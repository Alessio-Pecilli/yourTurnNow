import 'package:flutter/material.dart';

typedef IconSelected = void Function(String key);

class AdminIconGrid extends StatelessWidget {
  final Map<String, IconData> icons;
  final String? selectedKey;
  final IconSelected onSelected;

  const AdminIconGrid({Key? key, required this.icons, required this.selectedKey, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = icons.keys.toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.grey.shade50),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final isSelected = selectedKey == key;
          return GestureDetector(
            onTap: () => onSelected(key),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.shade700 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? Colors.green.shade700 : Colors.grey.shade300, width: isSelected ? 2 : 1),
              ),
              child: Icon(icons[key], color: isSelected ? Colors.white : Colors.grey.shade700, size: 20),
            ),
          );
        },
      ),
    );
  }
}
