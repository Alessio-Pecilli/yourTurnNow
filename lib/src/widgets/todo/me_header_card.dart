import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'google_avatar_widget.dart';

class MeHeaderCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double balance;
  final VoidCallback onProfileTap;

  const MeHeaderCard({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.balance,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onProfileTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GoogleAvatar(name: name, photoUrl: photoUrl, radius: 28, tooltip: name),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Saldo attuale', style: Theme.of(context).textTheme.labelLarge),
                    Text(
                      f.format(balance),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
