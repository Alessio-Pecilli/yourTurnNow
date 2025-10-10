import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:your_turn/src/models/money_tx.dart';

class TransactionsChart extends StatelessWidget {
  final List<MoneyTx> transactions;
  const TransactionsChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1) ordina per data crescente
    final sorted = [...transactions]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // 2) raggruppa per giorno
    final dayKey = DateFormat('yyyy-MM-dd');
    final Map<String, double> byDay = {};
    for (final tx in sorted) {
      final k = dayKey.format(tx.createdAt);
      byDay[k] = (byDay[k] ?? 0) + tx.amount;
    }

    // 3) costruisci serie cumulativa
    final keys = byDay.keys.toList()..sort();
    double cum = 0;
    final labels = <String>[];
    final spots = <fl.FlSpot>[];
    for (var i = 0; i < keys.length; i++) {
      cum += byDay[keys[i]]!;
      spots.add(fl.FlSpot(i.toDouble(), cum));
      final d = DateFormat('dd/MM').format(DateTime.parse(keys[i]));
      labels.add(d);
    }

    // 4) range Y con padding
    final ys = spots.map((s) => s.y).toList();
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);
    final pad = (maxY - minY).abs() * 0.1 + 1;

    // 5) etichette asse X
    Widget bottomLabel(double value, fl.TitleMeta meta) {
      final i = value.round();
      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
      final step = (labels.length / 6).ceil().clamp(1, labels.length);
      if (i % step != 0 && i != labels.length - 1) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(labels[i], style: const TextStyle(fontSize: 10)),
      );
    }

    // 6) ritorna il widget completo
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 6,
        color: const Color(0xFFFFFAF3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Titolo grafico
              Row(
                children: [
                  Icon(Icons.show_chart, color: Colors.blue.shade700, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Andamento delle spese nel tempo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 🔹 Grafico
              SizedBox(
                height: 220,
                child: fl.LineChart(
                  fl.LineChartData(
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: (minY - pad),
                    maxY: (maxY + pad),
                    gridData:
                        const fl.FlGridData(show: true, drawVerticalLine: false),
                    borderData: fl.FlBorderData(show: false),
                    titlesData: fl.FlTitlesData(
                      leftTitles: const fl.AxisTitles(
                        sideTitles:
                            fl.SideTitles(showTitles: true, reservedSize: 44),
                      ),
                      rightTitles: const fl.AxisTitles(
                        sideTitles: fl.SideTitles(showTitles: false),
                      ),
                      topTitles: const fl.AxisTitles(
                        sideTitles: fl.SideTitles(showTitles: false),
                      ),
                      bottomTitles: fl.AxisTitles(
                        sideTitles: fl.SideTitles(
                          showTitles: true,
                          getTitlesWidget: bottomLabel,
                          reservedSize: 26,
                        ),
                      ),
                    ),
                    lineTouchData: fl.LineTouchData(
                      enabled: true,
                      touchTooltipData: fl.LineTouchTooltipData(
                        getTooltipItems: (touched) => touched.map((e) {
                          final i = e.x.round().clamp(0, labels.length - 1);
                          return fl.LineTooltipItem(
                            '${labels[i]}\nSaldo: ${e.y.toStringAsFixed(2)}€',
                            const TextStyle(fontWeight: FontWeight.w600),
                          );
                        }).toList(),
                      ),
                    ),
                    lineBarsData: [
  fl.LineChartBarData(
    spots: spots,
    isCurved: true,
    barWidth: 3,
    dotData: const fl.FlDotData(show: false),
    color: Colors.green.shade600, // 💚 Linea verde principale
    belowBarData: fl.BarAreaData(
      show: true,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.green.shade300.withOpacity(0.4),
          Colors.green.shade100.withOpacity(0.1),
          Colors.white.withOpacity(0.1), // sfumatura verso il bianco/beige
        ],
      ),
    ),
  ),
],

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
