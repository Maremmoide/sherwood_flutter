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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: acquistiRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final acquisti = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: acquisti.length,
                  itemBuilder: (context, index) {
                    final a = acquisti[index];
                    return ListTile(
                      title: Text("${a["prodotto"]} - x${a["quantita"]}"),
                      subtitle: Text("Fornitore: ${a["fornitoreNome"] ?? "N/A"} - €${a["costo"]}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => acquistiRef.doc(a.id).delete(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            child: const Text("Aggiungi Acquisto"),
            onPressed: () {
              prodotto = "";
              quantita = 0;
              costo = 0.0;
              fornitoreId = "";
              showDialog(
                context: context,
                builder: (_) => _dialogAcquisto(
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
        ],
      ),
    );
  }

  Widget _dialogAcquisto(
      BuildContext context,
      CollectionReference fornitoriRef,
      String prodotto,
      int quantita,
      double costo,
      String fornitoreId,
      Function(String, int, double, String, String) onSave,
      ) {
    String nuovoProdotto = prodotto;
    int nuovaQuantita = quantita;
    double nuovoCosto = costo;
    String nuovoFornitoreId = fornitoreId;
    String nuovoFornitoreNome = "";

    return AlertDialog(
      title: const Text("Nuovo Acquisto"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "Prodotto"),
            onChanged: (v) => nuovoProdotto = v,
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
            if (nuovoProdotto.isNotEmpty && nuovoFornitoreId.isNotEmpty) {
              onSave(nuovoProdotto, nuovaQuantita, nuovoCosto, nuovoFornitoreId, nuovoFornitoreNome);
            }
            Navigator.pop(context);
          },
          child: const Text("Salva"),
        ),
      ],
    );
  }
}
