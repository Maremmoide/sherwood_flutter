import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'sala_crea_ordine_screen.dart';

class SalaTavoliScreen extends StatelessWidget {
  const SalaTavoliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Griglia tavoli fissi 1..20 (puoi leggerli da Firestore se vuoi)
    final tavoli = List<int>.generate(20, (i) => i + 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala - Tavoli'),
        actions: [
          IconButton(
            tooltip: 'Paga tavolo...',
            onPressed: () async {
              final tavolo = await _chiediTavolo(context);
              if (tavolo != null) {
                await FirebaseService.pagaOrdiniDelTavolo(tavolo);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tavolo $tavolo pagato e liberato')),
                  );
                }
              }
            },
            icon: const Icon(Icons.payments),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.2),
        itemCount: tavoli.length,
        itemBuilder: (context, index) {
          final numTavolo = tavoli[index];
          return _TavoloTile(numTavolo: numTavolo);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SalaCreaOrdineScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Ordine'),
      ),
    );
  }

  Future<int?> _chiediTavolo(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Paga tavolo'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Numero tavolo'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text);
              Navigator.pop(ctx, n);
            },
            child: const Text('Conferma'),
          )
        ],
      ),
    );
  }
}

class _TavoloTile extends StatelessWidget {
  final int numTavolo;
  const _TavoloTile({required this.numTavolo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseService.streamOrdiniTavolo(numTavolo),
      builder: (context, snap) {
        final statoIcon = _iconByOrders(snap.data);
        return InkWell(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => SalaCreaOrdineScreen(tavoloSelezionato: numTavolo))),
          child: Card(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tavolo $numTavolo', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Icon(statoIcon, size: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _iconByOrders(QuerySnapshot<Map<String, dynamic>>? data) {
    if (data == null || data.docs.isEmpty) return Icons.event_available_outlined; // libero

    // Se tutti gli ordini sono "Pronto", mostra un'icona specifica
    final allPronto = data.docs.every((d) => (d.data()['stato'] ?? '') == 'Pronto');
    if (allPronto) return Icons.check_circle;

    // Se ce n'è almeno uno in preparazione
    final anyPrep = data.docs.any((d) => (d.data()['stato'] ?? '') == 'In preparazione');
    if (anyPrep) return Icons.soup_kitchen;

    // Se ce n'è almeno uno inviato
    final anyInviato = data.docs.any((d) => (d.data()['stato'] ?? '') == 'Inviato');
    if (anyInviato) return Icons.pending;

    return Icons.restaurant_menu;
  }
}
