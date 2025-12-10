import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';
import '../models/transacao.dart';
import '../widgets/export_util.dart';
import '../widgets/resumo_financeiro.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não autenticado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Controle de Gastos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              // 🔹 Pega a lista atual do Stream via FirestoreService
              final transacoes = await FirestoreService()
                  .listarTransacoes(user.uid)
                  .first;

              // 🔹 Gera o PDF com a lista correta
              await ExportUtils().exportarPDF(transacoes);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Transacao>>(
        stream: FirestoreService().listarTransacoes(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhuma transação cadastrada"));
          }

          final transacoes = snapshot.data!;

          // calcular totais
          double totalReceitas = 0;
          double totalDespesas = 0;

          for (var t in transacoes) {
            if (t.tipo.toLowerCase() == 'receita') {
              totalReceitas += t.valor;
            } else {
              totalDespesas += t.valor;
            }
          }

          final reais = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

          return Column(
            children: [
              ResumoFinanceiro(
                totalReceitas: totalReceitas,
                totalDespesas: totalDespesas,
              ),
              SizedBox(
                height: 140,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: totalReceitas,
                        title: "Receitas",
                        color: Colors.green,
                      ),
                      PieChartSectionData(
                        value: totalDespesas,
                        title: "Despesas",
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: transacoes.length,
                  itemBuilder: (context, index) {
                    final t = transacoes[index];
                    return ListTile(
                      leading: Icon(
                        t.tipo.toLowerCase() == 'despesa'
                            ? Icons.remove_circle
                            : Icons.add_circle,
                        color: t.tipo.toLowerCase() == 'despesa'
                            ? Colors.red
                            : Colors.green,
                      ),
                      title: Text(reais.format(t.valor)),
                      subtitle: Text(
                        "${t.tipo.toUpperCase()} - ${t.origem} - ${t.categoria} - ${DateFormat('dd/MM/yy').format(t.data)}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () async {
                          await FirestoreService().deleteTransacao(t.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTransacao');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}