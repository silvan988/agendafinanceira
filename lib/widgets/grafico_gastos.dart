import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transacao.dart';

class GraficoGastos extends StatelessWidget {
  final List<Transacao> transacoes;

  const GraficoGastos({required this.transacoes, super.key});

  @override
  Widget build(BuildContext context) {
    final despesas = transacoes
        .where((t) => t.tipo == 'despesa')
        .fold<Map<String, double>>({}, (map, t) {
      map[t.categoria] = (map[t.categoria] ?? 0) + t.valor;
      return map;
    });

    final total = despesas.values.fold(0.0, (a, b) => a + b);

    final categorias = despesas.keys.toList();
    final cores = [
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: List.generate(categorias.length, (i) {
            final categoria = categorias[i];
            final valor = despesas[categoria]!;
            final porcentagem = (valor / total) * 100;

            return PieChartSectionData(
              color: cores[i % cores.length],
              value: valor,
              title: '${porcentagem.toStringAsFixed(1)}%',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}