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
    final ordiniRef = FirebaseFirestore.instance
        .collection("ordini")
        .doc(tavoloNumero.toString());

    final snapshot = await ordiniRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      final items = List<Map<String, dynamic>>.from(data["items"]);
      final index = items.indexWhere((item) => item["nome"] == piatto);

      if (index != -1) {
        // Se il piatto già esiste, aumento solo la quantità
        items[index]["qty"] += 1;
      } else {
        // Se è un nuovo piatto, lo aggiungo con stato "In attesa"
        items.add({"nome": piatto, "qty": 1, "stato": "In attesa"});
      }

      // Aggiorno l'ordine su Firestore
      await ordiniRef.update({
        "items": items,
        "timestamp": DateTime.now().toIso8601String(),
        "stato": _calcolaStatoOrdine(items),
      });
    } else {
      // Se è il primo ordine per questo tavolo
      await ordiniRef.set({
        "tavolo": tavoloNumero,
        "timestamp": DateTime.now().toIso8601String(),
        "items": [
          {"nome": piatto, "qty": 1, "stato": "In attesa"}
        ],
        "stato": "In attesa",
      });
    }
  }

  /// Calcola lo stato complessivo dell'ordine in base agli item
  String _calcolaStatoOrdine(List<Map<String, dynamic>> items) {
    final stati = items.map((e) => e["stato"]).toList();
    if (stati.every((s) => s == "In attesa")) {
      return "In attesa";
    } else if (stati.every((s) => s == "Pronto")) {
      return "Pronto";
    } else {
      return "In preparazione";
    }
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
      appBar: AppBar(title: Text("Tavolo $tavoloNumero - $categoriaNome")),
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
