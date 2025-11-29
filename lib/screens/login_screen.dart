import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _carregando = false;
  String? _erro;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final credenciais = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userId: credenciais.user!.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _erro = e.message;
        _carregando = false;
      });
    }
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final credenciais = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userId: credenciais.user!.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _erro = e.message;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_erro != null)
                Text(_erro!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (value) =>
                value!.isEmpty ? 'Informe o e-mail' : null,
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) =>
                value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 24),
              if (_carregando)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Entrar'),
                ),
                TextButton(
                  onPressed: _registrar,
                  child: const Text('Criar conta'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}