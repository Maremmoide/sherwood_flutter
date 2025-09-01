import 'package:flutter/material.dart';
import 'GestioneProdottiScreen.dart';
import 'GestioneMenuScreen.dart';
import 'GestioneCategorieScreen.dart';
import 'GestioneFornitoriScreen.dart';
import 'GestioneAcquistiScreen.dart';
import 'GestioneTavoliScreen.dart';
import 'statistiche_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menu = [
      {"titolo": "Gestione Prodotti", "screen": const GestioneProdottiScreen()},
      {"titolo": "Gestione Menù", "screen": const GestioneMenuScreen()},
      {"titolo": "Gestione Categorie", "screen": const GestioneCategorieScreen()},
      {"titolo": "Gestione Fornitori", "screen": const GestioneFornitoriScreen()},
      {"titolo": "Gestione Acquisti", "screen": const GestioneAcquistiScreen()},
      {"titolo": "Gestione Tavoli e Prenotazioni", "screen": const GestioneTavoliScreen()},
      {"titolo": "Statistiche", "screen": const StatisticheScreen()},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Admin")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: menu.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = menu[index];
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item["screen"]),
                );
              },
              child: Text(item["titolo"]),
            );
          },
        ),
      ),
    );
  }
}
