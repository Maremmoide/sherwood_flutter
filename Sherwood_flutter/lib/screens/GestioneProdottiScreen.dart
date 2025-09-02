import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestioneProdottiScreen extends StatelessWidget {
  const GestioneProdottiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prodottiRef = FirebaseFirestore.instance.collection("prodotti");
    final fornitoriRef = FirebaseFirestore.instance.collection("fornitori");

    String nome = "";
    String fornitoreId = "";

    return Scaffold(
      appBar: AppBar(title: const Text("Gestione Prodotti")),

      // Lista prodotti in tempo reale
      body: StreamBuilder<QuerySnapshot>(
        stream: prodottiRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final prodotti = snapshot.data!.docs;

          if (prodotti.isEmpty) {
            return const Center(child: Text("Nessun prodotto presente"));
          }

          return ListView.builder(
            itemCount: prodotti.length,
            itemBuilder: (context, index) {
              final p = prodotti[index];
              return ListTile(
                title: Text(p["nome"]),
                subtitle: Text("Fornitore: ${p["fornitoreNome"] ?? "N/A"}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modifica prodotto
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        nome = p["nome"];
                        fornitoreId = p["fornitoreId"];
                        final fornitoreNome = p["fornitoreNome"];
                        showDialog(
                          context: context,
                          builder: (_) => _dialogProdotto(
                            context,
                            fornitoriRef,
                            nome,
                            fornitoreId,
                            fornitoreNome,
                                (nuovoNome, nuovoFornitoreId, nuovoFornitoreNome) {
                              prodottiRef.doc(p.id).update({
                                "nome": nuovoNome,
                                "fornitoreId": nuovoFornitoreId,
                                "fornitoreNome": nuovoFornitoreNome,
                              });
                            },
                          ),
                        );
                      },
                    ),
                    // Elimina prodotto
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => prodottiRef.doc(p.id).delete(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // Pulsante per aggiungere nuovo prodotto
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi Prodotto"),
        onPressed: () {
          nome = "";
          fornitoreId = "";
          showDialog(
            context: context,
            builder: (_) => _dialogProdotto(
              context,
              fornitoriRef,
              nome,
              fornitoreId,
              "", // Nessun fornitore predefinito
                  (nuovoNome, nuovoFornitoreId, nuovoFornitoreNome) {
                FirebaseFirestore.instance.collection("prodotti").add({
                  "nome": nuovoNome,
                  "fornitoreId": nuovoFornitoreId,
                  "fornitoreNome": nuovoFornitoreNome,
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// Dialog per aggiungere o modificare un prodotto
  Widget _dialogProdotto(
      BuildContext context,
      CollectionReference fornitoriRef,
      String nome,
      String fornitoreId,
      String fornitoreNome, // passo anche il nome attuale
      Function(String, String, String) onSave,
      ) {
    String nuovoNome = nome;
    String nuovoFornitoreId = fornitoreId;
    String nuovoFornitoreNome = fornitoreNome;

    return AlertDialog(
      title: const Text("Prodotto"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo testo per il nome
          TextField(
            decoration: const InputDecoration(labelText: "Nome"),
            controller: TextEditingController(text: nome),
            onChanged: (v) => nuovoNome = v,
          ),
          const SizedBox(height: 12),

          // Dropdown fornitori
          StreamBuilder<QuerySnapshot>(
            stream: fornitoriRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final fornitori = snapshot.data!.docs;

              return DropdownButton<String>(
                // Preseleziona il fornitore attuale se esiste
                value: nuovoFornitoreId.isNotEmpty ? nuovoFornitoreId : null,
                hint: const Text("Seleziona Fornitore"),
                isExpanded: true,
                items: fornitori.map((f) {
                  return DropdownMenuItem(
                    value: f.id,
                    child: Text(f["nome"]),
                    onTap: () {
                      // Se scelgo un nuovo fornitore aggiorno nome
                      nuovoFornitoreNome = f["nome"];
                    },
                  );
                }).toList(),
                onChanged: (val) {
                  // Se cambio scelta aggiorno l'ID
                  nuovoFornitoreId = val ?? "";
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
            // Se non scelgo nulla, rimane il fornitore vecchio
            if (nuovoNome.isNotEmpty && nuovoFornitoreId.isNotEmpty) {
              onSave(nuovoNome, nuovoFornitoreId, nuovoFornitoreNome);
            }
            Navigator.pop(context);
          },
          child: const Text("Salva"),
        ),
      ],
    );
  }
}
