import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shop_games_app/screens/conexion_screen.dart';
import 'package:shop_games_app/screens/home_screen.dart';
import 'package:shop_games_app/screens/login_screen.dart';
import 'package:shop_games_app/screens/registrar_producto.dart';
import 'package:shop_games_app/screens/registro_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  final Logger logger = Logger();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runZonedGuarded(() {
    runApp(
        const MyApp()); // Aquí no uses `const` si `MyApp` no tiene un constructor constante
  }, (error, stackTrace) {
    // Aquí puedes manejar cualquier error no capturado en la app
    logger.e('Error capturado globalmente: $error');
    // También puedes registrar el error o mostrar un diálogo en la UI
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: const LoginScreen(),
      routes: {
        '/Login': (context) => const LoginScreen(),
        '/Registro': (context) => const RegistroScreen(),
        '/Home': (context) => const HomeScreen(),
        '/RegistroProducto': (context) => const RegistrarProducto(),
        '/BD': (context) => const ConexionScreen(),
      },
    );
  }
}
