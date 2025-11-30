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

  // Firestore → objeto
  factory Transacao.fromMap(Map<String, dynamic> map, String id) {
    return Transacao(
      id: id,
      tipo: map['tipo'] ?? '',
      valor: (map['valor'] as num).toDouble(),
      origem: map['origem'] ?? 'Sem origem',
      categoria: map['categoria'] ?? 'Sem categoria',
      data: (map['data'] as Timestamp).toDate(),
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