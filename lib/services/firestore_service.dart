import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transacao.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 Salvar nova transação dentro de usuarios/{uid}/transacoes
  Future<void> adicionarTransacao(Transacao transacao) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('transacoes')
        .doc(transacao.id)
        .set(transacao.toMap());
  }

  // 🔹 Buscar todas as transações de um usuário
  Stream<List<Transacao>> listarTransacoes(String userId) {
    return _db
        .collection('usuarios')
        .doc(userId)
        .collection('transacoes')
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Transacao.fromFirestore(doc)).toList());
  }

  // 🔹 Excluir transação
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

  // 🔹 Buscar transações filtradas (exemplo: por usuário logado)
  Stream<List<Transacao>> getTransacoesFiltradas({String? uid}) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    Query query = _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('transacoes');

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Transacao.fromFirestore(doc)).toList());
  }
}