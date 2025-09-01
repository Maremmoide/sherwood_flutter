import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestioneMenuScreen extends StatelessWidget {
  const GestioneMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorieRef = FirebaseFirestore.instance.collection("Categorie");

    return Scaffold(
      appBar: AppBar(title: const Text("Gestione Menu")),
      body: StreamBuilder<QuerySnapshot>(
        stream: categorieRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categorie = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categorie.length,
            itemBuilder: (context, index) {
              final categoria = categorie[index];
              final nomeCategoria = categoria["nome"];

              return ExpansionTile(
                title: Text(nomeCategoria),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: categoria.reference.collection("piatti").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final piatti = snapshot.data!.docs;

                      return Column(
                        children: piatti.map((piatto) {
                          final nome = piatto["nome"];
                          final prezzo = piatto["prezzo"].toString();

                          return ListTile(
                            title: Text(nome),
                            subtitle: Text("€ $prezzo"),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _mostraDialogModifica(context, piatto.reference, nome, prezzo);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _mostraDialogModifica(BuildContext context, DocumentReference ref, String nomeAttuale, String prezzoAttuale) {
    final nomeController = TextEditingController(text: nomeAttuale);
    final prezzoController = TextEditingController(text: prezzoAttuale);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifica Piatto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome")),
            TextField(controller: prezzoController, decoration: const InputDecoration(labelText: "Prezzo"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () async {
              await ref.update({
                "nome": nomeController.text,
                "prezzo": double.tryParse(prezzoController.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: const Text("Salva"),
          ),
        ],
      ),
    );
  }
}
