import 'package:flutter/material.dart';

class MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const MetaChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: scheme.primary, // icona blu principale
      ),
      label: Text(
        label,
        style: TextStyle(
          color: scheme.primary, // testo blu
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: scheme.primaryContainer.withOpacity(0.2),
      side: BorderSide(color: scheme.primaryContainer),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
