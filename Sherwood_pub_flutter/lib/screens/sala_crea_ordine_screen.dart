import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class SalaCreaOrdineScreen extends StatefulWidget {
  final int? tavoloSelezionato;
  const SalaCreaOrdineScreen({super.key, this.tavoloSelezionato});

  @override
  State<SalaCreaOrdineScreen> createState() => _SalaCreaOrdineScreenState();
}

class _SalaCreaOrdineScreenState extends State<SalaCreaOrdineScreen> {
  final tavoloCtrl = TextEditingController();
  final cameriereCtrl = TextEditingController(text: 'Sala');
  final items = <_ItemRow>[];

  @override
  void initState() {
    super.initState();
    if (widget.tavoloSelezionato != null) {
      tavoloCtrl.text = widget.tavoloSelezionato.toString();
    }
    // parte con una riga
    items.add(_ItemRow());
  }

  void _addRow() {
    setState(() => items.add(_ItemRow()));
  }

  Future<void> _salva() async {
    final tavolo = int.tryParse(tavoloCtrl.text);
    if (tavolo == null || tavolo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Numero tavolo non valido')));
      return;
    }

    final data = items.map((e) => e.toMap()).where((m) => (m['nome'] as String).isNotEmpty && (m['qty'] as int) > 0).toList();
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aggiungi almeno un piatto')));
      return;
    }

    await FirebaseService.creaOrdine(tavolo: tavolo, items: data, cameriere: cameriereCtrl.text.trim().isEmpty ? 'Sala' : cameriereCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ordine inviato in cucina')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo Ordine')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: tavoloCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Numero Tavolo'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: cameriereCtrl,
            decoration: const InputDecoration(labelText: 'Cameriere (opzionale)'),
          ),
          const Divider(height: 32),
          ...items.map((r) => r),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text('Aggiungi Piatto')),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: _salva, icon: const Icon(Icons.send), label: const Text('Invia in cucina')),
        ],
      ),
    );
  }
}

class _ItemRow extends StatefulWidget {
  final nomeCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final noteCtrl = TextEditingController();

  Map<String, dynamic> toMap() => {
    'nome': nomeCtrl.text.trim(),
    'qty': int.tryParse(qtyCtrl.text) ?? 0,
    'note': noteCtrl.text.trim(),
    'status': 'Inviato',
  };

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: widget.nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome piatto'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantità'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.noteCtrl,
                    decoration: const InputDecoration(labelText: 'Note'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
