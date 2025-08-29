import 'package:flutter/material.dart';

class SalaScreen extends StatelessWidget {
  const SalaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sala')),
      body: const Center(
        child: Text(
          'Benvenuto nella Sala!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
