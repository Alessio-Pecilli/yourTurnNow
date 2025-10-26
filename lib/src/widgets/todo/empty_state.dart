import 'package:flutter/material.dart';
import 'package:your_turn/l10n/app_localizations.dart';

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
          Text(AppLocalizations.of(context)!.todos_empty, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.todos_add_first,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
