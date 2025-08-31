import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin - Ordini")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("ordini").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ordini = snapshot.data!.docs;

          if (ordini.isEmpty) {
            return const Center(child: Text("Nessun ordine presente"));
          }

          return ListView.builder(
            itemCount: ordini.length,
            itemBuilder: (context, index) {
              final ordine = ordini[index].data() as Map<String, dynamic>;
              final tavolo = ordine["tavolo"];
              final items = List<Map<String, dynamic>>.from(ordine["items"]);

              return Card(
                child: ExpansionTile(
                  title: Text("Tavolo $tavolo"),
                  children: items
                      .map((item) => ListTile(
                    title: Text(item["nome"]),
                    trailing: Text("x${item["qty"]}"),
                  ))
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
