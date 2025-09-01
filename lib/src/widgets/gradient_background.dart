import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [scheme.surfaceContainerHigh, scheme.surfaceContainerHighest, Colors.black]
              : [scheme.surface, scheme.surfaceContainerHigh, scheme.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -30,
            child: _bubble(color: scheme.primary.withOpacity(isDark ? 0.20 : 0.10), size: 220),
          ),
          Positioned(
            bottom: -40,
            right: -20,
            child: _bubble(color: scheme.tertiary.withOpacity(isDark ? 0.18 : 0.08), size: 180),
          ),
          Positioned(
            bottom: 120,
            left: -50,
            child: _bubble(color: scheme.secondary.withOpacity(isDark ? 0.16 : 0.07), size: 140),
          ),
        ],
      ),
    );
  }

  Widget _bubble({required Color color, required double size}) => DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.28), blurRadius: 40, spreadRadius: 10)],
        ),
        child: SizedBox(width: size, height: size),
      );
}
