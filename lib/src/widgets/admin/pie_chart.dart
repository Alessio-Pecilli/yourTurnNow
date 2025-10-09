import 'dart:math' as math;
import 'package:flutter/material.dart';

class ExpenseSlice {
  final String category;
  final double amount;
  final Color color;

  ExpenseSlice({required this.category, required this.amount, required this.color});
}

class PieChartPainter extends CustomPainter {
  final List<ExpenseSlice> slices;
  final double total;

  PieChartPainter(this.slices, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty || total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    double startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweepAngle = (slice.amount / total) * 2 * math.pi;

      final paint = Paint()..color = slice.color..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);

      // white border between slices
      final borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, borderPaint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
