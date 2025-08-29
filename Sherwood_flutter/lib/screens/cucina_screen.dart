import 'package:flutter/material.dart';

class CucinaScreen extends StatelessWidget {
  const CucinaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cucina')),
      body: const Center(
        child: Text(
          'Benvenuto in Cucina!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
