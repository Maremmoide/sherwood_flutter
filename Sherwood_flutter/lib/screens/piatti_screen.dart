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

  Future<void> _aggiungiOrdine(String piatto, double prezzo) async {
    final ordiniRef = FirebaseFirestore.instance
        .collection("ordini")
        .doc(tavoloNumero.toString());

    final snapshot = await ordiniRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      final items = List<Map<String, dynamic>>.from(data["items"]);
      final index = items.indexWhere((item) => item["nome"] == piatto);

      if (index != -1) {
        items[index]["qty"] += 1;
      } else {
        items.add({
          "nome": piatto,
          "qty": 1,
          "prezzo": prezzo,
          "stato": "In attesa"
        });
      }

      await ordiniRef.update({
        "items": items,
        "timestamp": DateTime.now().toIso8601String(),
        "stato": _calcolaStatoOrdine(items),
      });
    } else {
      await ordiniRef.set({
        "tavolo": tavoloNumero,
        "timestamp": DateTime.now().toIso8601String(),
        "items": [
          {"nome": piatto, "qty": 1, "prezzo": prezzo, "stato": "In attesa"}
        ],
        "stato": "In attesa",
      });
    }
  }

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
    final piattiRef = FirebaseFirestore.instance
        .collection("menu")
        .where("categoriaNome", isEqualTo: categoriaNome);

    return Scaffold(
      appBar: AppBar(title: Text("Tavolo $tavoloNumero - $categoriaNome")),
      body: StreamBuilder<QuerySnapshot>(
        stream: piattiRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final piattiDocs = snapshot.data!.docs;

          if (piattiDocs.isEmpty) {
            return const Center(child: Text("Nessun piatto disponibile"));
          }

          return ListView.builder(
            itemCount: piattiDocs.length,
            itemBuilder: (context, index) {
              final data = piattiDocs[index].data() as Map<String, dynamic>;
              final nome = data["nome"] ?? "Senza nome";
              final prezzo = (data["prezzo"] ?? 0).toDouble();

              return Card(
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text("€${prezzo.toStringAsFixed(2)}"),
                  trailing: const Icon(Icons.add),
                  onTap: () async {
                    await _aggiungiOrdine(nome, prezzo);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$nome aggiunto all’ordine")),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
