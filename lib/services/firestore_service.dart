import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transacao.dart';

class FirestoreService {
  final CollectionReference transacoesRef =
  FirebaseFirestore.instance.collection('transacoes');

  // Salvar nova transação
  Future<void> adicionarTransacao(Transacao transacao) async {
    await transacoesRef.doc(transacao.id).set(transacao.toMap());
  }

  // Buscar todas as transações de um usuário
  Stream<List<Transacao>> listarTransacoes(String userId) {
    return transacoesRef
        .where('id', isEqualTo: userId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Transacao.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Excluir transação
  Future<void> excluirTransacao(String transacaoId) async {
    await transacoesRef.doc(transacaoId).delete();
  }
}