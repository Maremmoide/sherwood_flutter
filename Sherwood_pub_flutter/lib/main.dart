import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/sala_tavoli_screen.dart';
import 'screens/cucina_ordini_screen.dart';
import 'firebase_options.dart'; // generato da FlutterFire CLI

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Se ho già salvato il ruolo, salto il login
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('role'); // 'sala' | 'cucina' | null

  runApp(MyApp(initialRole: role));
}

class MyApp extends StatelessWidget {
  final String? initialRole;
  const MyApp({super.key, this.initialRole});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Risto Manager',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: switch (initialRole) {
        'sala' => const SalaTavoliScreen(),
        'cucina' => const CucinaOrdiniScreen(),
        _ => const LoginScreen(),
      },
      routes: {
        '/login': (_) => const LoginScreen(),
        '/sala': (_) => const SalaTavoliScreen(),
        '/cucina': (_) => const CucinaOrdiniScreen(),
      },
    );
  }
}
