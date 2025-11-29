import 'package:cloud_firestore/cloud_firestore.dart';

class Transacao {
  final String id;
  final String tipo;
  final double valor;
  final String origem;
  final DateTime data;

  Transacao({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.origem,
    required this.data,
  });

  factory Transacao.fromFirestore(Map<String, dynamic> doc, String id) {
    return Transacao(
      id: id,
      tipo: doc['tipo'] ?? '',
      valor: (doc['valor'] as num).toDouble(),
      origem: doc['origem'] ?? 'Sem origem',
      data: (doc['data'] as Timestamp).toDate(), // ✅ conversão correta
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo,
      'valor': valor,
      'origem': origem,
      'data': Timestamp.fromDate(data), // ✅ salva como Timestamp
    };
  }
}