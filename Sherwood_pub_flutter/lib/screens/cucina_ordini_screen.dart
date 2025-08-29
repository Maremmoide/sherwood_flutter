import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class CucinaOrdiniScreen extends StatelessWidget {
  const CucinaOrdiniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cucina - Ordini')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseService.streamOrdiniCucina(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nessun ordine'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data();
              final tav = data['numeroTavolo'];
              final cam = data['cameriere'] ?? '';
              final stato = data['stato'] ?? '';
              final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

              final allPronto = items.isNotEmpty && items.every((it) => (it['status'] ?? '') == 'Pronto');

              return Card(
                child: ExpansionTile(
                  leading: Icon(allPronto ? Icons.check_circle : Icons.soup_kitchen),
                  title: Text('Tavolo $tav • $stato'),
                  subtitle: Text('Cameriere: $cam'),
                  children: [
                    ...items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final it = entry.value;
                      final nome = it['nome'] ?? '';
                      final qty = it['qty'] ?? 0;
                      final note = (it['note'] ?? '').toString();
                      final status = (it['status'] ?? '').toString();

                      final icon = switch (status) {
                        'Inviato' => Icons.pending,
                        'In preparazione' => Icons.soup_kitchen,
                        'Pronto' => Icons.check_circle,
                        _ => Icons.help_outline,
                      };

                      return ListTile(
                        leading: Icon(icon),
                        title: Text('$nome  x$qty'),
                        subtitle: note.isNotEmpty ? Text('Nota: $note') : null,
                        trailing: PopupMenuButton<String>(
                          onSelected: (sel) => FirebaseService.updateItemStatus(d.id, idx, sel),
                          itemBuilder: (ctx) => const [
                            PopupMenuItem(value: 'Inviato', child: Text('Inviato')),
                            PopupMenuItem(value: 'In preparazione', child: Text('In preparazione')),
                            PopupMenuItem(value: 'Pronto', child: Text('Pronto')),
                          ],
                          child: Chip(label: Text(status.isEmpty ? 'Stato' : status)),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
