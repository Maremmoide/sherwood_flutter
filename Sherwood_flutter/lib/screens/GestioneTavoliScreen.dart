import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestioneTavoliScreen extends StatelessWidget {
  const GestioneTavoliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tavoliRef = FirebaseFirestore.instance.collection("tavoli");
    final prenotazioniRef = FirebaseFirestore.instance.collection("prenotazioni");

    return Scaffold(
      appBar: AppBar(title: const Text("Gestione Tavoli e Prenotazioni")),
      body: StreamBuilder<QuerySnapshot>(
        stream: tavoliRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tavoli = snapshot.data!.docs;

          if (tavoli.isEmpty) {
            return const Center(child: Text("Nessun tavolo disponibile"));
          }

          return ListView.builder(
            itemCount: tavoli.length,
            itemBuilder: (context, index) {
              final t = tavoli[index];
              return Card(
                child: ExpansionTile(
                  title: Text("Tavolo: ${t["nome"]}"),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: prenotazioniRef.where("tavoloId", isEqualTo: t.id).snapshots(),
                      builder: (context, snapshotPren) {
                        if (!snapshotPren.hasData) return const CircularProgressIndicator();
                        final prenotazioni = snapshotPren.data!.docs;

                        if (prenotazioni.isEmpty) {
                          return const ListTile(title: Text("Nessuna prenotazione"));
                        }

                        return Column(
                          children: prenotazioni.map((p) {
                            return ListTile(
                              title: Text("Prenotazione: ${p["cliente"]}"),
                              subtitle: Text("Data: ${p["data"]}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => prenotazioniRef.doc(p.id).delete(),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    TextButton(
                      child: const Text("➕ Aggiungi Prenotazione"),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => _dialogPrenotazione(
                            context,
                            prenotazioniRef,
                            t.id,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // FAB per aggiungere tavolo
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi Tavolo"),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => _dialogTavolo(context, tavoliRef),
          );
        },
      ),
    );
  }

  Widget _dialogTavolo(BuildContext context, CollectionReference tavoliRef) {
    String nuovoNome = "";
    return AlertDialog(
      title: const Text("Nuovo Tavolo"),
      content: TextField(
        decoration: const InputDecoration(labelText: "Nome Tavolo"),
        onChanged: (v) => nuovoNome = v,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
        ElevatedButton(
          onPressed: () {
            if (nuovoNome.isNotEmpty) {
              tavoliRef.add({"nome": nuovoNome});
            }
            Navigator.pop(context);
          },
          child: const Text("Salva"),
        ),
      ],
    );
  }

  Widget _dialogPrenotazione(
      BuildContext context,
      CollectionReference prenotazioniRef,
      String tavoloId,
      ) {
    String cliente = "";
    String data = "";
    return AlertDialog(
      title: const Text("Nuova Prenotazione"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "Nome Cliente"),
            onChanged: (v) => cliente = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Data"),
            onChanged: (v) => data = v,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
        ElevatedButton(
          onPressed: () {
            if (cliente.isNotEmpty && data.isNotEmpty) {
              prenotazioniRef.add({
                "cliente": cliente,
                "data": data,
                "tavoloId": tavoloId,
              });
            }
            Navigator.pop(context);
          },
          child: const Text("Salva"),
        ),
      ],
    );
  }
}
