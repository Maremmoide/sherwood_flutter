import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      appBar: AppBar(title: Text("Tavolo $tavoloNumero - Ordini")),
      body: Column(
        children: [
          // 🔹 Lista categorie per aggiungere ordini
          Expanded(
            flex: 1,
            child: ListView.builder(
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
          ),

          const Divider(height: 1),

          // 🔹 Ordini del tavolo in tempo reale
          Expanded(
            flex: 1,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("ordini")
                  .doc(tavoloNumero.toString())
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                      child: Text("Nessun ordine per questo tavolo"));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final items = List<Map<String, dynamic>>.from(data["items"]);

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item["nome"]),
                        subtitle: Text("Stato: ${item["stato"] ?? "In attesa"}"),
                        trailing: Text("x${item["qty"]}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
