import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CucinaScreen extends StatelessWidget {
  const CucinaScreen({super.key});

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
              final items = List<Map<String, dynamic>>.from(data["items"] ?? []);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Tavolo $tavolo"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items.map((item) {
                      return Text("${item['nome']} x${item['qty']}");
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
