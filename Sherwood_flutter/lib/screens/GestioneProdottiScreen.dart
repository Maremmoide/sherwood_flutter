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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: prodottiRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final prodotti = snapshot.data!.docs;

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
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              nome = p["nome"];
                              fornitoreId = p["fornitoreId"];
                              showDialog(
                                context: context,
                                builder: (_) => _dialogProdotto(
                                  context,
                                  fornitoriRef,
                                  nome,
                                  fornitoreId,
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
          ),
          ElevatedButton(
            child: const Text("Aggiungi Prodotto"),
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
                      (nuovoNome, nuovoFornitoreId, nuovoFornitoreNome) {
                    prodottiRef.add({
                      "nome": nuovoNome,
                      "fornitoreId": nuovoFornitoreId,
                      "fornitoreNome": nuovoFornitoreNome,
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dialogProdotto(
      BuildContext context,
      CollectionReference fornitoriRef,
      String nome,
      String fornitoreId,
      Function(String, String, String) onSave,
      ) {
    String nuovoNome = nome;
    String nuovoFornitoreId = fornitoreId;
    String nuovoFornitoreNome = "";

    return AlertDialog(
      title: const Text("Prodotto"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "Nome"),
            controller: TextEditingController(text: nome),
            onChanged: (v) => nuovoNome = v,
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: fornitoriRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final fornitori = snapshot.data!.docs;

              return DropdownButton<String>(
                value: nuovoFornitoreId.isNotEmpty ? nuovoFornitoreId : null,
                hint: const Text("Seleziona Fornitore"),
                isExpanded: true,
                items: fornitori.map((f) {
                  return DropdownMenuItem(
                    value: f.id,
                    child: Text(f["nome"]),
                    onTap: () => nuovoFornitoreNome = f["nome"],
                  );
                }).toList(),
                onChanged: (val) {
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
