import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestioneMenuScreen extends StatelessWidget {
  const GestioneMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuRef = FirebaseFirestore.instance.collection("menu");
    final categorieRef = FirebaseFirestore.instance.collection("categorie");

    String nome = "";
    double prezzo = 0.0;
    String categoriaId = "";

    return Scaffold(
      appBar: AppBar(title: const Text("Gestione Menù")),

      // 🔹 Lista piatti del menù in tempo reale
      body: StreamBuilder<QuerySnapshot>(
        stream: menuRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final piatti = snapshot.data!.docs;

          if (piatti.isEmpty) {
            return const Center(child: Text("Nessun piatto presente"));
          }

          return ListView.builder(
            itemCount: piatti.length,
            itemBuilder: (context, index) {
              final p = piatti[index];
              return ListTile(
                title: Text(p["nome"]),
                subtitle: Text(
                  "Categoria: ${p["categoriaNome"] ?? "N/A"} - Prezzo: €${p["prezzo"]}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Modifica piatto
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        nome = p["nome"];
                        prezzo = (p["prezzo"] as num).toDouble();
                        categoriaId = p["categoriaId"];
                        final categoriaNome = p["categoriaNome"] ?? "";

                        showDialog(
                          context: context,
                          builder: (_) => _dialogMenu(
                            context,
                            categorieRef,
                            nome,
                            prezzo,
                            categoriaId,
                            categoriaNome,
                                (nuovoNome, nuovoPrezzo, nuovaCategoriaId, nuovaCategoriaNome) {
                              menuRef.doc(p.id).update({
                                "nome": nuovoNome,
                                "prezzo": nuovoPrezzo,
                                "categoriaId": nuovaCategoriaId,
                                "categoriaNome": nuovaCategoriaNome,
                              });
                            },
                          ),
                        );
                      },
                    ),
                    // 🔹 Elimina piatto
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => menuRef.doc(p.id).delete(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // 🔹 Pulsante per aggiungere nuovo piatto
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi Piatto"),
        onPressed: () {
          nome = "";
          prezzo = 0.0;
          categoriaId = "";
          showDialog(
            context: context,
            builder: (_) => _dialogMenu(
              context,
              categorieRef,
              nome,
              prezzo,
              categoriaId,
              "", // nessuna categoria predefinita
                  (nuovoNome, nuovoPrezzo, nuovaCategoriaId, nuovaCategoriaNome) {
                menuRef.add({
                  "nome": nuovoNome,
                  "prezzo": nuovoPrezzo,
                  "categoriaId": nuovaCategoriaId,
                  "categoriaNome": nuovaCategoriaNome,
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// 🔹 Dialog per aggiungere o modificare un piatto
  Widget _dialogMenu(
      BuildContext context,
      CollectionReference categorieRef,
      String nome,
      double prezzo,
      String categoriaId,
      String categoriaNome, // passo anche il nome attuale
      Function(String, double, String, String) onSave,
      ) {
    String nuovoNome = nome;
    double nuovoPrezzo = prezzo;
    String nuovaCategoriaId = categoriaId;
    String nuovaCategoriaNome = categoriaNome;

    return AlertDialog(
      title: const Text("Piatto Menù"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Campo testo per il nome
          TextField(
            decoration: const InputDecoration(labelText: "Nome"),
            controller: TextEditingController(text: nome),
            onChanged: (v) => nuovoNome = v,
          ),

          // 🔹 Campo testo per il prezzo
          TextField(
            decoration: const InputDecoration(labelText: "Prezzo"),
            keyboardType: TextInputType.number,
            controller: TextEditingController(
              text: prezzo > 0 ? prezzo.toString() : "",
            ),
            onChanged: (v) => nuovoPrezzo = double.tryParse(v) ?? 0.0,
          ),
          const SizedBox(height: 12),

          // 🔹 Dropdown categorie
          StreamBuilder<QuerySnapshot>(
            stream: categorieRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final categorie = snapshot.data!.docs;

              return DropdownButton<String>(
                // 🔹 Se ho già una categoria, la preseleziono
                value: nuovaCategoriaId.isNotEmpty ? nuovaCategoriaId : null,
                hint: const Text("Seleziona Categoria"),
                isExpanded: true,
                items: categorie.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c["nome"]),
                    onTap: () {
                      // Aggiorno il nome solo se cambio scelta
                      nuovaCategoriaNome = c["nome"];
                    },
                  );
                }).toList(),
                onChanged: (val) {
                  nuovaCategoriaId = val ?? "";
                },
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
        ElevatedButton(
          onPressed: () {
            // 🔹 Se non cambio nulla, rimane la categoria vecchia
            if (nuovoNome.isNotEmpty && nuovaCategoriaId.isNotEmpty) {
              onSave(nuovoNome, nuovoPrezzo, nuovaCategoriaId, nuovaCategoriaNome);
            }
            Navigator.pop(context);
          },
          child: const Text("Salva"),
        ),
      ],
    );
  }
}
