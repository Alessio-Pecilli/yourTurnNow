import 'package:flutter/material.dart';

class CommonActionButton extends StatelessWidget {
  final String letter;
  final String label;
  final MaterialColor color;
  final IconData icon;
  final VoidCallback onTap;
  final double height;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const CommonActionButton({
    super.key,
    required this.letter,
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.height = 46,
    this.fontSize = 13,
    this.iconSize = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.85), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.shade700, width: 2),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.shade700,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: Colors.white, size: iconSize),
            ],
          ),
        ),
      ),
    );
  }
}
