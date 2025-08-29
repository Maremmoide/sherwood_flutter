import 'package:flutter/material.dart';
import 'sala_screen.dart';
import 'cucina_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ruoloController = TextEditingController();

  void login() {
    final username = usernameController.text.trim();
    final ruolo = ruoloController.text.trim().toLowerCase();

    if (username == "Maicol" && ruolo == "sala") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SalaScreen()),
      );
    } else if (username == "Patrizia" && ruolo == "cucina") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CucinaScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Credenziali errate")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ruoloController,
              decoration: const InputDecoration(labelText: 'Ruolo (Sala/Cucina)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: login,
              child: const Text('Accedi'),
            ),
          ],
        ),
      ),
    );
  }
}
