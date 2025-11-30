import 'package:cloud_firestore/cloud_firestore.dart';

class Transacao {
  final String id;
  final String tipo;       // despesa ou receita
  final double valor;
  final String origem;     // supermercado, uber, salário...
  final String categoria;  // alimentação, transporte, lazer...
  final DateTime data;

  Transacao({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.origem,
    required this.categoria,
    required this.data,
  });

  // Construtor a partir do Firestore
  factory Transacao.fromFirestore(DocumentSnapshot doc) {
    final dados = doc.data() as Map<String, dynamic>;

    return Transacao(
      id: doc.id,
      tipo: dados['tipo'] ?? '',
      origem: dados['origem'] ?? '',
      categoria: dados['categoria'] ?? '',
      valor: (dados['valor'] as num).toDouble(),
      data: (dados['data'] as Timestamp).toDate(),
    );
  }


  // objeto → Firestore
  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'valor': valor,
      'origem': origem,
      'categoria': categoria,
      'data': Timestamp.fromDate(data),
    };
  }
}