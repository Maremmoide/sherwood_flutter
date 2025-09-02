import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ordini_screen.dart';

class SalaScreen extends StatelessWidget {
  const SalaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tavoliRef = FirebaseFirestore.instance.collection("tavoli");

    return Scaffold(
      appBar: AppBar(title: const Text('Sala - Tavoli')),
      body: StreamBuilder<QuerySnapshot>(
        stream: tavoliRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tavoliDocs = snapshot.data!.docs;

          // Suddivisione per sezioni
          final Map<String, List<int>> sezioni = {
            'Interno': [],
            'Veranda': [],
            'Botti': [],
            'Giardino': [],
          };

          for (var doc in tavoliDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final numeroRaw = data["nome"];

            if (numeroRaw == null) continue;

            final numero = (numeroRaw is int)
                ? numeroRaw
                : int.tryParse(numeroRaw.toString());

            if (numero == null) continue;

            if (numero >= 1 && numero <= 9) {
              sezioni['Interno']!.add(numero);
            } else if (numero >= 10 && numero <= 19) {
              sezioni['Veranda']!.add(numero);
            } else if (numero >= 20 && numero <= 29) {
              sezioni['Botti']!.add(numero);
            } else if (numero >= 30 && numero <= 39) {
              sezioni['Giardino']!.add(numero);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: sezioni.entries.map((entry) {
              final nomeSezione = entry.key;
              final tavoli = entry.value..sort();

              if (tavoli.isEmpty) return const SizedBox.shrink();

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
          );
        },
      ),
    );
  }
}
