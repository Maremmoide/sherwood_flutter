import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'piatti_screen.dart';

class OrdiniScreen extends StatelessWidget {
  final int tavoloNumero;

  const OrdiniScreen({super.key, required this.tavoloNumero});

  @override
  Widget build(BuildContext context) {
    final categorieRef = FirebaseFirestore.instance.collection("categorie");

    return Scaffold(
      appBar: AppBar(title: Text("Tavolo $tavoloNumero - Ordini")),
      body: Column(
        children: [
          // Lista categorie lette da Firestore
          Expanded(
            flex: 1,
            child: StreamBuilder<QuerySnapshot>(
              stream: categorieRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categorieDocs = snapshot.data!.docs;

                if (categorieDocs.isEmpty) {
                  return const Center(child: Text("Nessuna categoria disponibile"));
                }

                return ListView.builder(
                  itemCount: categorieDocs.length,
                  itemBuilder: (context, index) {
                    final data = categorieDocs[index].data() as Map<String, dynamic>;
                    final nome = data["nome"] ?? "Senza nome";

                    return Card(
                      child: ListTile(
                        title: Text(nome),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PiattiScreen(
                                tavoloNumero: tavoloNumero,
                                categoriaNome: nome,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Ordini del tavolo in tempo reale
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
