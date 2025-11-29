import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transacao.dart';
import '../services/firestore_service.dart';

class CadastroTransacao extends StatefulWidget {
  final String userId;

  const CadastroTransacao({required this.userId, super.key});

  @override
  State<CadastroTransacao> createState() => _CadastroTransacaoState();
}

class _CadastroTransacaoState extends State<CadastroTransacao> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _observacaoController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();
  String _tipoSelecionado = 'despesa';

  void _salvarTransacao() {
    if (_formKey.currentState!.validate()) {
      final transacao = Transacao(
        id: const Uuid().v4(),
        tipo: _tipoSelecionado,
        valor: double.parse(_valorController.text),
        categoria: _categoriaController.text,
        data: _dataSelecionada,
        observacao: _observacaoController.text,
      );

      FirestoreService().adicionarTransacao(transacao).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Transação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                items: const [
                  DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
                  DropdownMenuItem(value: 'receita', child: Text('Receita')),
                ],
                onChanged: (value) => setState(() => _tipoSelecionado = value!),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor'),
                validator: (value) =>
                value!.isEmpty ? 'Informe o valor' : null,
              ),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: (value) =>
                value!.isEmpty ? 'Informe a categoria' : null,
              ),
              TextFormField(
                controller: _observacaoController,
                decoration: const InputDecoration(labelText: 'Observação'),
              ),
              const SizedBox(height: 16),
              Text('Data: ${_dataSelecionada.toLocal().toString().split(' ')[0]}'),
              ElevatedButton(
                onPressed: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate: _dataSelecionada,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (data != null) {
                    setState(() => _dataSelecionada = data);
                  }
                },
                child: const Text('Selecionar Data'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarTransacao,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}