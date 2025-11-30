import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransacaoScreen extends StatefulWidget {
  const AddTransacaoScreen({super.key});

  @override
  State<AddTransacaoScreen> createState() => _AddTransacaoScreenState();
}

class _AddTransacaoScreenState extends State<AddTransacaoScreen> {
  final _valorController = TextEditingController();
  final _origemController = TextEditingController();
  final _categoriaController = TextEditingController();
  String _tipo = "despesa";
  DateTime _data = DateTime.now();

  Future<void> _salvarTransacao() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final valor = double.tryParse(_valorController.text);
    if (valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um valor válido")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('transacoes')
        .add({
          'tipo': _tipo,
          'valor': valor,
          'categoria': _categoriaController.text, // ✅ salva como String'
          'origem': _origemController.text,
          'data': Timestamp.fromDate(_data), // ✅ salva como Timestamp
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Transação")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Valor (R\$)"),
            ),
            const SizedBox(height: 13),
            TextField(
              controller: _origemController,
              decoration: const InputDecoration(labelText: "Origem (ex: Mercado, Uber, Salário)"),
            ),
            const SizedBox(height: 13),
            TextField(
              controller: _categoriaController,
              decoration: const InputDecoration(labelText: "Categoria (ex: Alimentação, Transporte, Lazer)"),
            ),
            const SizedBox(height: 13),
            DropdownButton<String>(
              value: _tipo,
              items: const [
                DropdownMenuItem(value: "despesa", child: Text("Despesa")),
                DropdownMenuItem(value: "receita", child: Text("Receita")),
              ],
              onChanged: (value) {
                setState(() {
                  _tipo = value!;
                });
              },
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _salvarTransacao,
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}