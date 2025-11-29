import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

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
            if (tipo == 'receita') {
              totalReceitas += valor;
            } else {
              totalDespesas += valor;
            }
          }

          return Column(
            children: [
              // gráfico de pizza
              SizedBox(
                height: 200,
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
                    final data = (doc['data'] as Timestamp).toDate();

                    return ListTile(
                      leading: Icon(
                        tipo == 'despesa'
                            ? Icons.remove_circle
                            : Icons.add_circle,
                        color: tipo == 'despesa' ? Colors.red : Colors.green,
                      ),
                      title: Text("R\$ $valor"),
                      subtitle: Text("${tipo.toUpperCase()} - ${doc['origem']} - ${data.toLocal()}"),
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