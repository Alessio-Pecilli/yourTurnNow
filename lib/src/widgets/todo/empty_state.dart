import 'package:flutter/material.dart';

class EmptyStateSliver extends StatelessWidget {
  const EmptyStateSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('Nessun task', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Aggiungi il primo task per organizzare la casa con i tuoi coinquilini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
