import 'package:flutter/material.dart';
import 'package:sherwood_flutter/screens/ordini_screen.dart';

class SalaScreen extends StatelessWidget {
  const SalaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definizione tavoli divisi per sezione
    final Map<String, List<int>> sezioni = {
      'Interno': [1, 2, 3, 4, 5, 6],
      'Veranda': [11, 12, 13, 14],
      'Botti': [21, 22, 23],
      'Giardino': [31, 32, 33],
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Sala - Tavoli')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: sezioni.entries.map((entry) {
          final nomeSezione = entry.key;
          final tavoli = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nomeSezione,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: tavoli.map((numero) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(80, 80),
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrdiniScreen(tavoloNumero: numero),
                        ),
                      );
                    },

                    child: Text(
                      '$numero',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }
}
