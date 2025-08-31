import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Inizializza Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Lista utenti da creare
  final users = [
    {"email": "admin@sherwood.com", "password": "admin1", "role": "admin"},
    {"email": "cameriere@sherwood.com", "password": "salasala", "role": "cameriere"},
    {"email": "cucina@sherwood.com", "password": "cucina", "role": "cucina"},
  ];

  for (var u in users) {
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: u["email"]!,
        password: u["password"]!,
      );

      await firestore.collection("users").doc(cred.user!.uid).set({
        "role": u["role"],
        "email": u["email"],
      });

      print("Creato utente ${u["email"]} con ruolo ${u["role"]}");
    } catch (e) {
      print("Errore per ${u["email"]}: $e");
    }
  }
}
