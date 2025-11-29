import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// importe suas telas
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transacao_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Gastos',
      theme: ThemeData(primarySwatch: Colors.green),
      // aqui usamos o StreamBuilder para decidir qual tela mostrar
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // usuário logado → vai para HomeScreen
            return const HomeScreen();
          }
          // usuário não logado → vai para LoginScreen
          return const LoginScreen();
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/addTransacao': (context) => const AddTransacaoScreen(),

      },
    );
  }
}