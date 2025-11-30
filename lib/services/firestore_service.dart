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
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado");
    }

    await _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('transacoes')
        .add(transacao.toMap());
  }

  Future<void> updateTransacao(String id, Transacao transacao) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('transacoes')
        .doc(id)
        .update(transacao.toMap());
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