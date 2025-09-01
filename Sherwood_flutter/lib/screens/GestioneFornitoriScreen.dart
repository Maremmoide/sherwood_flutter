import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestioneFornitoriScreen extends StatelessWidget {
  const GestioneFornitoriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fornitoriRef = FirebaseFirestore.instance.collection("fornitori");
    String nome = "";

    return Scaffold(
      appBar: AppBar(title: const Text("Gestione Fornitori")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: fornitoriRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final fornitori = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: fornitori.length,
                    itemBuilder: (context, index) {
                      final f = fornitori[index];
                      return ListTile(
                        title: Text(f["nome"]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                nome = f["nome"];
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Modifica Fornitore"),
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
                                          fornitoriRef.doc(f.id).update({"nome": nome});
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
                              onPressed: () => fornitoriRef.doc(f.id).delete(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 80), // aggiungo spazio extra sopra la barra
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi Fornitore"),
        onPressed: () {
          nome = "";
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Nuovo Fornitore"),
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
                      fornitoriRef.add({"nome": nome});
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
    );
  }
}
