import 'package:flutter/material.dart';
import '../models/transacao.dart';
import '../services/firestore_service.dart';
import 'cadastro_transacao.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Finanças')),
      body: StreamBuilder<List<Transacao>>(
        stream: FirestoreService().listarTransacoes(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transacoes = snapshot.data ?? [];

          if (transacoes.isEmpty) {
            return const Center(child: Text('Nenhuma transação cadastrada.'));
          }

          return ListView.builder(
            itemCount: transacoes.length,
            itemBuilder: (context, index) {
              final t = transacoes[index];
              return ListTile(
                leading: Icon(
                  t.tipo == 'receita' ? Icons.arrow_upward : Icons.arrow_downward,
                  color: t.tipo == 'receita' ? Colors.green : Colors.red,
                ),
                title: Text('${t.categoria} - R\$ ${t.valor.toStringAsFixed(2)}'),
                subtitle: Text('${t.data.toLocal().toString().split(' ')[0]}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    FirestoreService().excluirTransacao(t.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CadastroTransacao(userId: userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}