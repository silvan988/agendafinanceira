import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../widgets/export_util.dart';

class ResumoFinanceiro extends StatelessWidget {
  final double totalReceitas;
  final double totalDespesas;

  const ResumoFinanceiro({
    super.key,
    required this.totalReceitas,
    required this.totalDespesas,
  });

  @override
  Widget build(BuildContext context) {
    final saldo = totalReceitas - totalDespesas;

    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Resumo Financeiro",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Receitas:", style: const TextStyle(color: Colors.green)),
                Text(formatador.format(totalReceitas),
                    style: const TextStyle(color: Colors.green)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Despesas:", style: const TextStyle(color: Colors.red)),
                Text(formatador.format(totalDespesas),
                    style: const TextStyle(color: Colors.red)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Saldo:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  formatador.format(saldo),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: saldo >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Controle de Gastos");
            }
            final dados = snapshot.data!.data() as Map<String, dynamic>?;
            final nome = dados?['nome'] ?? '';
            return Text("Controle de Gastos - $nome");
          },
        ),



        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final transacoes = await FirestoreService().getTransacoesFiltradas(uid: user.uid);
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('transacoes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhuma transação cadastrada"));
          }

          final transacoes = snapshot.data!.docs;

          // calcular totais
          double totalReceitas = 0;
          double totalDespesas = 0;

          for (var doc in transacoes) {
            final tipo = doc['tipo'];
            final valor = (doc['valor'] as num).toDouble();
            final categoria = doc['categoria'];

            if (tipo == 'receita') {
              totalReceitas += valor;
            } else {
              totalDespesas += valor;
            }
          }

          return Column(
            children: [
            ResumoFinanceiro(
            totalReceitas: totalReceitas,
            totalDespesas: totalDespesas,
             ),// gráfico de pizza
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
              // lista de transações
              Expanded(
                child: ListView.builder(
                  itemCount: transacoes.length,
                  itemBuilder: (context, index) {
                    final doc = transacoes[index];
                    final tipo = doc['tipo'];
                    final valor = doc['valor'];
                    final categoria = doc['categoria'];
                    final data = (doc['data'] as Timestamp).toDate();
                    final reais = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');


                    return ListTile(
                      leading: Icon(
                        tipo == 'despesa'
                            ? Icons.remove_circle
                            : Icons.add_circle,
                        color: tipo == 'despesa' ? Colors.red : Colors.green,
                      ),
                      title: Text(reais.format((doc['valor'] as num).toDouble())),
                      subtitle: Text(
                        "${tipo.toUpperCase()} - ${doc['origem']} - ${doc['categoria']} - ${DateFormat('dd/MM/yy').format(data)}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () async {
                          await FirestoreService().deleteTransacao(doc.id);
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