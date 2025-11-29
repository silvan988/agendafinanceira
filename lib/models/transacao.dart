class Transacao {
  final String id;
  final String tipo; // 'receita' ou 'despesa'
  final double valor;
  final String categoria;
  final DateTime data;
  final String observacao;

  Transacao({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.categoria,
    required this.data,
    required this.observacao,
  });

  // Converte para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'valor': valor,
      'categoria': categoria,
      'data': data.toIso8601String(),
      'observacao': observacao,
    };
  }

  // Construtor a partir de Map (Firestore)
  factory Transacao.fromMap(Map<String, dynamic> map) {
    return Transacao(
      id: map['id'] ?? '',
      tipo: map['tipo'] ?? '',
      valor: map['valor']?.toDouble() ?? 0.0,
      categoria: map['categoria'] ?? '',
      data: DateTime.parse(map['data']),
      observacao: map['observacao'] ?? '',
    );
  }
}