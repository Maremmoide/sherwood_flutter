import 'package:flutter/material.dart';
import 'piatti_screen.dart';

class OrdiniScreen extends StatelessWidget {
  final int tavoloNumero;

  const OrdiniScreen({super.key, required this.tavoloNumero});

  @override
  Widget build(BuildContext context) {
    final categorie = [
      {"id": 1, "nome": "Antipasti"},
      {"id": 2, "nome": "Primi"},
      {"id": 3, "nome": "Secondi"},
      {"id": 4, "nome": "Pizze"},
      {"id": 5, "nome": "Dolci"},
      {"id": 6, "nome": "Bevande"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Tavolo $tavoloNumero - Ordini"),
      ),
      body: ListView.builder(
        itemCount: categorie.length,
        itemBuilder: (context, index) {
          final categoria = categorie[index];
          return Card(
            child: ListTile(
              title: Text(categoria["nome"].toString()),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PiattiScreen(
                      tavoloNumero: tavoloNumero,
                      categoriaNome: categoria["nome"].toString(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
