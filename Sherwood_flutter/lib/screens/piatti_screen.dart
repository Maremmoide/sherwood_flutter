import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PiattiScreen extends StatelessWidget {
  final int tavoloNumero;
  final String categoriaNome;

  const PiattiScreen({
    super.key,
    required this.tavoloNumero,
    required this.categoriaNome,
  });

  Future<void> _aggiungiOrdine(String piatto) async {
    final ordiniRef = FirebaseFirestore.instance.collection("ordini");

    await ordiniRef.add({
      "tavolo": tavoloNumero,
      "timestamp": DateTime.now().toIso8601String(),
      "items": [
        {"nome": piatto, "qty": 1}
      ],
    });
  }

  @override
  Widget build(BuildContext context) {
    final piatti = {
      "Antipasti": ["Bruschette", "Tagliere misto", "Olive ascolane"],
      "Primi": ["Carbonara", "Lasagna", "Gnocchi al sugo"],
      "Secondi": ["Tagliata di manzo", "Pollo arrosto", "Fritto misto"],
      "Pizze": ["Margherita", "Diavola", "Quattro formaggi"],
      "Dolci": ["Tiramisù", "Panna cotta", "Cheesecake"],
      "Bevande": ["Acqua", "Coca Cola", "Birra artigianale"],
    };

    final piattiCategoria = piatti[categoriaNome] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Tavolo $tavoloNumero - $categoriaNome"),
      ),
      body: ListView.builder(
        itemCount: piattiCategoria.length,
        itemBuilder: (context, index) {
          final piatto = piattiCategoria[index];
          return Card(
            child: ListTile(
              title: Text(piatto),
              trailing: const Icon(Icons.add),
              onTap: () async {
                await _aggiungiOrdine(piatto);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$piatto aggiunto all’ordine")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
