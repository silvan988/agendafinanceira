import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transacao.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


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
        .map((doc) => Transacao.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // Excluir transação
  Future<void> deleteTransacao(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('transacoes')
        .doc(id)
        .delete();
  }
}