import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestioneCategorieScreen extends StatelessWidget {
  const GestioneCategorieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorieRef = FirebaseFirestore.instance.collection("categorie");
    String nome = "";

    return Scaffold(
      appBar: AppBar(title: const Text("Gestione Categorie")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: categorieRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final categorie = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: categorie.length,
                  itemBuilder: (context, index) {
                    final c = categorie[index];
                    return ListTile(
                      title: Text(c["nome"]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              nome = c["nome"];
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Modifica Categoria"),
                                  content: TextField(
                                    controller: TextEditingController(text: nome),
                                    decoration: const InputDecoration(labelText: "Nome"),
                                    onChanged: (v) => nome = v,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Annulla"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        categorieRef.doc(c.id).update({"nome": nome});
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Salva"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => categorieRef.doc(c.id).delete(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            child: const Text("Aggiungi Categoria"),
            onPressed: () {
              nome = "";
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Nuova Categoria"),
                  content: TextField(
                    decoration: const InputDecoration(labelText: "Nome"),
                    onChanged: (v) => nome = v,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annulla"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nome.isNotEmpty) {
                          categorieRef.add({"nome": nome});
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("Salva"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
