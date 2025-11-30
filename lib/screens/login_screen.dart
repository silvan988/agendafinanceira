import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool mostrarCadastro = false; // alterna entre login e cadastro

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _senhaController.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
  }

  Future<void> _cadastro() async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _senhaController.text,
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(cred.user!.uid)
          .set({
        'nome': _nomeController.text,
        'email': _emailController.text,
        'cpf': _cpfController.text,
        'telefone': _telefoneController.text,
        'criadoEm': DateTime.now(),
      });

      // encerra sessão para forçar login
      await FirebaseAuth.instance.signOut();

      // mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cadastro realizado com sucesso! Faça login para continuar."),
          backgroundColor: Colors.green,
        ),
      );

      // volta para tela de login
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mostrarCadastro ? "Cadastro" : "Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            if (mostrarCadastro) ...[
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              TextField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: "CPF"),
              ),
              TextField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: "Telefone"),
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: mostrarCadastro ? _cadastro : _login,
              child: Text(mostrarCadastro ? "Cadastrar" : "Entrar"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  mostrarCadastro = !mostrarCadastro;
                });
              },
              child: Text(mostrarCadastro
                  ? "Já tem conta? Entrar"
                  : "Não tem conta? Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }
}