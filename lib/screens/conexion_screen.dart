import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConexionScreen extends StatefulWidget {
  const ConexionScreen({
    super.key,
  });
  @override
  ConexionScreenState createState() => ConexionScreenState();
}

class ConexionScreenState extends State<ConexionScreen> {
  String _connectionStatus = 'Desconocido';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      // Intentar obtener un documento de Firestore
      var document = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc('aH7CSRLTeZmBhxDF7n5j')
          .get();
      if (document.exists) {
        setState(() {
          _connectionStatus = 'Conectado a Firebase';
        });
      } else {
        setState(() {
          _connectionStatus = 'Documento no encontrado';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error de conexión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprobar Conexión'),
      ),
      body: Center(
        child: Text('Estado de conexión: $_connectionStatus'),
      ),
    );
  }
}
