import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CucinaScreen extends StatelessWidget {
  const CucinaScreen({super.key});

  // Funzione per avanzare lo stato di un singolo item
  Future<void> _avanzaStatoItem(DocumentSnapshot ordineDoc, int index) async {
    final data = ordineDoc.data() as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(data["items"] ?? []);

    final statoCorrente = items[index]["stato"] ?? "In attesa";
    String nuovoStato;

    if (statoCorrente == "In attesa") {
      nuovoStato = "In preparazione";
    } else if (statoCorrente == "In preparazione") {
      nuovoStato = "Pronto";
    } else {
      return; // Se già pronto, non fare nulla
    }

    // Aggiorna lo stato dell'item
    items[index]["stato"] = nuovoStato;

    // Calcola lo stato complessivo dell'ordine
    String nuovoStatoOrdine;
    final stati = items.map((e) => e["stato"]).toList();
    if (stati.every((s) => s == "In attesa")) {
      nuovoStatoOrdine = "In attesa";
    } else if (stati.every((s) => s == "Pronto")) {
      nuovoStatoOrdine = "Pronto";
    } else {
      nuovoStatoOrdine = "In preparazione";
    }

    // Aggiorna su Firestore
    await ordineDoc.reference.update({
      "items": items,
      "stato": nuovoStatoOrdine,
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordiniRef = FirebaseFirestore.instance.collection("ordini");

    return Scaffold(
      appBar: AppBar(title: const Text('Cucina')),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordiniRef.orderBy("timestamp", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ordini = snapshot.data?.docs ?? [];
          if (ordini.isEmpty) {
            return const Center(child: Text("Nessun ordine ricevuto"));
          }

          return ListView.builder(
            itemCount: ordini.length,
            itemBuilder: (context, index) {
              final doc = ordini[index];
              final data = doc.data() as Map<String, dynamic>;
              final tavolo = data["tavolo"];
              final statoOrdine = data["stato"] ?? "In attesa";
              final items = List<Map<String, dynamic>>.from(data["items"] ?? []);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text("Tavolo $tavolo"),
                  subtitle: Text("Stato ordine: $statoOrdine"),
                  children: items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final stato = item["stato"] ?? "In attesa";

                    return ListTile(
                      title: Text("${item['nome']} x${item['qty']}"),
                      subtitle: Text("Stato: $stato"),
                      trailing: ElevatedButton(
                        onPressed: stato == "Pronto"
                            ? null
                            : () => _avanzaStatoItem(doc, i),
                        child: Text(
                          stato == "In attesa"
                              ? "Inizia"
                              : stato == "In preparazione"
                              ? "Completa"
                              : "Pronto",
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
