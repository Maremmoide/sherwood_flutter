import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final auth = FirebaseAuth.instance;
  static final db = FirebaseFirestore.instance;

  /// Login con PIN presi da Firestore: doc `config/pins` { salaPin: "1234", cucinaPin: "5678" }
  static Future<String?> loginWithPin(String pin) async {
    // assicuro auth anonimo (una sessione utente serve per le rules)
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    final doc = await db.collection('config').doc('pins').get();
    final data = doc.data() ?? {};
    final salaPin = (data['salaPin'] ?? '').toString();
    final cucinaPin = (data['cucinaPin'] ?? '').toString();

    if (pin == salaPin) return 'sala';
    if (pin == cucinaPin) return 'cucina';
    return null;
  }

  /// Crea un ordine “inviato” dalla sala
  static Future<void> creaOrdine({
    required int tavolo,
    required List<Map<String, dynamic>> items,
    required String cameriere,
  }) async {
    await db.collection('orders').add({
      'numeroTavolo': tavolo,
      'cameriere': cameriere,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'stato': 'Inviato', // stato ordine globale
      // each item: {nome, qty, note, status}
      'items': items,
    });
  }

  /// Stream ordini per la CUCINA (solo quelli inviati/non pagati)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamOrdiniCucina() {
    return db.collection('orders')
        .where('stato', whereIn: ['Inviato', 'In preparazione', 'Parziale pronto', 'Pronto'])
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Stream ordini per SALA di un tavolo
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamOrdiniTavolo(int tavolo) {
    return db.collection('orders')
        .where('numeroTavolo', isEqualTo: tavolo)
        .where('stato', isNotEqualTo: 'Pagato') // nascondo pagati
        .orderBy('stato')
        .snapshots();
  }

  /// Aggiorna lo stato di un item (in cucina)
  static Future<void> updateItemStatus(String orderId, int itemIndex, String newStatus) async {
    final ref = db.collection('orders').doc(orderId);
    await db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      if (itemIndex < 0 || itemIndex >= items.length) return;
      items[itemIndex]['status'] = newStatus;

      // ricalcolo stato globale ordine
      final stati = items.map((e) => (e['status'] ?? '').toString()).toList();
      final allPronto = stati.every((s) => s == 'Pronto');
      final anyInPrep = stati.any((s) => s == 'In preparazione');
      final anyInviato = stati.any((s) => s == 'Inviato');

      String statoGlobale = 'Inviato';
      if (allPronto) {
        statoGlobale = 'Pronto';
      } else if (anyInPrep) {
        statoGlobale = 'In preparazione';
      } else if (!allPronto && !anyInPrep && !anyInviato) {
        statoGlobale = 'Parziale pronto';
      }

      tx.update(ref, {'items': items, 'stato': statoGlobale});
    });
  }

  /// Paga e “libera” tavolo: marca ordine come Pagato (non eliminare)
  static Future<void> pagaOrdiniDelTavolo(int tavolo) async {
    final q = await db.collection('orders')
        .where('numeroTavolo', isEqualTo: tavolo)
        .where('stato', isNotEqualTo: 'Pagato')
        .get();

    final batch = db.batch();
    for (final d in q.docs) {
      batch.update(d.reference, {'stato': 'Pagato'});
    }
    await batch.commit();
  }
}
