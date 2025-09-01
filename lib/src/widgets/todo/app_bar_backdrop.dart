import 'package:flutter/material.dart';

class AppBarBackdrop extends StatelessWidget {
  const AppBarBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.primary.withOpacity(0.10), c.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
