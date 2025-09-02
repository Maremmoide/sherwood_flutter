import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestioneAcquistiScreen extends StatelessWidget {
  const GestioneAcquistiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acquistiRef = FirebaseFirestore.instance.collection("acquisti");
    final fornitoriRef = FirebaseFirestore.instance.collection("fornitori");

    String prodotto = "";
    int quantita = 0;
    double costo = 0.0;
    String fornitoreId = "";

    return Scaffold(
      appBar: AppBar(title: const Text("Gestione Acquisti")),
      body: StreamBuilder<QuerySnapshot>(
        stream: acquistiRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final acquisti = snapshot.data!.docs;

          if (acquisti.isEmpty) {
            return const Center(child: Text("Nessun acquisto registrato"));
          }

          return ListView.builder(
            itemCount: acquisti.length,
            itemBuilder: (context, index) {
              final a = acquisti[index];
              return ListTile(
                title: Text("${a["prodotto"]} - x${a["quantita"]}"),
                subtitle: Text("Fornitore: ${a["fornitoreNome"] ??
                    "N/A"} - €${a["costo"]}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => acquistiRef.doc(a.id).delete(),
                ),
              );
            },
          );
        },
      ),

      // FAB al posto del bottone in fondo
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi Acquisto"),
        onPressed: () {
          prodotto = "";
          quantita = 0;
          costo = 0.0;
          fornitoreId = "";
          showDialog(
            context: context,
            builder: (_) =>
                _dialogAcquisto(
                  context,
                  fornitoriRef,
                  prodotto,
                  quantita,
                  costo,
                  fornitoreId,
                      (prod, qty, cost, fId, fNome) {
                    acquistiRef.add({
                      "prodotto": prod,
                      "quantita": qty,
                      "costo": cost,
                      "fornitoreId": fId,
                      "fornitoreNome": fNome,
                      "data": DateTime.now(),
                    });
                  },
                ),
          );
        },
      ),
    );
  }

  Widget _dialogAcquisto(BuildContext context,
      CollectionReference fornitoriRef,
      String prodotto,
      int quantita,
      double costo,
      String fornitoreId,
      Function(String, int, double, String, String) onSave,) {
    String nuovoProdotto = prodotto;
    int nuovaQuantita = quantita;
    double nuovoCosto = costo;
    String nuovoFornitoreId = fornitoreId;
    String nuovoFornitoreNome = "";

    final prodottiRef = FirebaseFirestore.instance.collection("prodotti");

    return AlertDialog(
      title: const Text("Nuovo Acquisto"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dropdown prodotti
          StreamBuilder<QuerySnapshot>(
            stream: prodottiRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final prodotti = snapshot.data!.docs;

              return DropdownButton<String>(
                value: nuovoProdotto.isNotEmpty ? nuovoProdotto : null,
                hint: const Text("Seleziona Prodotto"),
                isExpanded: true,
                items: prodotti.map((p) {
                  final nome = p["nome"] as String;
                  final fId = p["fornitoreId"] as String;
                  final fNome = p["fornitoreNome"] as String;

                  return DropdownMenuItem<String>(
                    value: nome,
                    child: Text(nome),
                    onTap: () {
                      // Quando scelgo un prodotto, imposto fornitore automatico
                      nuovoFornitoreId = fId;
                      nuovoFornitoreNome = fNome;
                    },
                  );
                }).toList(),
                onChanged: (val) {
                  nuovoProdotto = val ?? "";
                },
              );

            },
          ),

          TextField(
            decoration: const InputDecoration(labelText: "Quantità"),
            keyboardType: TextInputType.number,
            onChanged: (v) => nuovaQuantita = int.tryParse(v) ?? 0,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Costo"),
            keyboardType: TextInputType.number,
            onChanged: (v) => nuovoCosto = double.tryParse(v) ?? 0.0,
          ),
          const SizedBox(height: 12),

          // Fornitore mostrato ma non modificabile
          TextField(
            decoration: const InputDecoration(labelText: "Fornitore"),
            controller: TextEditingController(text: nuovoFornitoreNome),
            enabled: false, // non modificabile
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annulla"),
        ),
        ElevatedButton(
          onPressed: () {
            if (nuovoProdotto.isNotEmpty && nuovoFornitoreId.isNotEmpty) {
              onSave(
                nuovoProdotto,
                nuovaQuantita,
                nuovoCosto,
                nuovoFornitoreId,
                nuovoFornitoreNome,
              );
            }
            Navigator.pop(context);
          },
          child: const Text("Salva"),
        ),
      ],
    );
  }
}