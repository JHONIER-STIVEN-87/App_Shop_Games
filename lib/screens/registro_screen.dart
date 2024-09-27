import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  RegistroScreenState createState() => RegistroScreenState();
}

class RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  final FocusNode _nombreFocusNode = FocusNode();
  final FocusNode _correoFocusNode = FocusNode();
  final FocusNode _contrasenaFocusNode = FocusNode();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nombreController.addListener(() {
      setState(() {
        _nombreIsEmpty = _nombreController.text.isEmpty;
      });
    });

    _correoController.addListener(() {
      setState(() {
        _correoIsEmpty = _correoController.text.isEmpty;
      }); // Actualiza el estado cuando el enfoque cambia
    });
    _contrasenaController.addListener(() {
      setState(() {
        _contrasenaIsEmpty = _contrasenaController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se destruye
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();

    _nombreFocusNode.dispose();
    _correoFocusNode.dispose();
    _contrasenaFocusNode.dispose();

    super.dispose();
  }

  bool _nombreIsEmpty = true;
  bool _correoIsEmpty = true;
  bool _contrasenaIsEmpty = true;

  bool _nombreTouched = false;
  bool _correoTouched = false;
  bool _contrasenaTouched = false;
  Color _getBorderColor2(FocusNode focusNode, bool isEmpty, bool touched) {
    if (focusNode.hasFocus) {
      return isEmpty
          ? Colors.red
          : Colors.green; // Rojo si está vacío, verde si tiene texto
    }
    if (!touched) {
      return Colors.grey; // Gris si aún no ha sido tocado
    }
    return isEmpty
        ? Colors.red
        : Colors.green; // Rojo si está vacío después de haber sido tocado
    // Gris si no está enfocado y vacío, verde si tiene texto
  }

  Future<void> _registrarUsuario() async {
    if (_nombreController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _contrasenaController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.yellow,
                  size: 60,
                )
              ],
            ),
            content: const Text(
              '¡Por favor diligencie todos los campos para póder continuar!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "Aceptar",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 231, 207, 0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailPattern);

    if (!regex.hasMatch(_correoController.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                )
              ],
            ),
            content: const Text(
              '¡El formato del correo no es valido...!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "Aceptar",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _correoController.text,
              password: _contrasenaController.text);

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nombre': _nombreController.text,
        'correo': _correoController.text,
        'idCon': _contrasenaController.text,
        'rol': 'Cliente'
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: Colors.green,
                    size: 60,
                  )
                ],
              ),
              content: const Text(
                '¡El usuario a sido registrado exitosamente!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/Login');
                  },
                ),
              ],
            );
          },
        );
      }

      _nombreController.clear();
      _correoController.clear();
      _contrasenaController.clear();
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.highlight_off_outlined,
                    color: Colors.red,
                    size: 60,
                  )
                ],
              ),
              content: Text(
                '¡Error al registrar el usuario!: $e',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: const Color.fromARGB(255, 6, 252, 104),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 0),
        width: double.infinity,
        height: double.infinity,
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 246, 246, 246)),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              height: 266,
              child: Image.asset("assets/Vector 3.png", fit: BoxFit.cover),
            ),
            Align(
              alignment: Alignment.topLeft,
              child:
                  SizedBox(height: 296, child: Image.asset("assets/Logo1.png")),
            ),
            Positioned(
              top: 215,
              right: 40,
              child: RichText(
                text: const TextSpan(
                  text: 'Shop',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF59C2E7),
                      fontSize: 30),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Games 🎮',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF889E))),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 274,
              right: 0,
              left: 0,
              child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 332,
                        child: TextField(
                            controller: _nombreController,
                            focusNode: _nombreFocusNode,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(_nombreFocusNode,
                                        _nombreIsEmpty, _nombreTouched),
                                    width: 2),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(60.0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(_nombreFocusNode,
                                        _nombreIsEmpty, _nombreTouched),
                                    width: 2),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(60.0),
                                ),
                              ),
                              hintText: 'Ingrese su Nombre de Usuario...',
                              filled: true,
                              fillColor: const Color(0xFFD0D0D0),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(right: 10.0, top: 5),
                                child: Icon(
                                  Icons.account_circle_outlined,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  size: 30,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _nombreTouched = true;
                              });
                            }),
                      ),
                      SizedBox(
                        width: 332,
                        child: TextField(
                            controller: _correoController,
                            focusNode: _correoFocusNode,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(_correoFocusNode,
                                        _correoIsEmpty, _correoTouched),
                                    width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(_correoFocusNode,
                                        _correoIsEmpty, _correoTouched),
                                    width: 2),
                              ),
                              hintText: 'Ingrese su Email...',
                              filled: true,
                              fillColor: const Color(0xFFD0D0D0),
                              suffixIcon: const Padding(
                                padding:
                                    EdgeInsets.only(right: 10.0, bottom: 0),
                                child: Icon(
                                  Icons.email_outlined,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  size: 30,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _correoTouched = true;
                              });
                            }),
                      ),
                      SizedBox(
                        width: 332,
                        child: TextField(
                            controller: _contrasenaController,
                            obscureText: _obscurePassword,
                            focusNode: _contrasenaFocusNode,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(
                                        _contrasenaFocusNode,
                                        _contrasenaIsEmpty,
                                        _contrasenaTouched),
                                    width: 2),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(60.0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(
                                        _contrasenaFocusNode,
                                        _contrasenaIsEmpty,
                                        _contrasenaTouched),
                                    width: 2),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(60.0),
                                ),
                              ),
                              hintText: 'Ingrese su Contraseña...',
                              filled: true,
                              fillColor: const Color(0xFFD0D0D0),
                              suffixIcon: GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    _obscurePassword =
                                        false; // Mostrar contraseña
                                  });
                                },
                                onLongPressUp: () {
                                  setState(() {
                                    _obscurePassword =
                                        true; // Ocultar contraseña
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10.0, bottom: 10),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons
                                            .visibility_off, // Icono cambia según visibilidad
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _contrasenaTouched = true;
                              });
                            }),
                      ),
                    ],
                  )),
            ),
            Positioned(
              top: 450,
              left: 0,
              right: 0,
              child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150,
                    child: FilledButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromARGB(255, 0, 0, 0)),
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color(0xFF59C2E7)),
                        ),
                        onPressed: _registrarUsuario,
                        child: const Text('Registrarse')),
                  )),
            ),
            Positioned(
              top: 498,
              left: 10,
              right: 0,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 150,
                    child: FilledButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromARGB(255, 0, 0, 0)),
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color(0xFFFF889E)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                60), // Esquina superior izquierda
                            bottomRight:
                                Radius.circular(60), // Esquina inferior derecha
                          ))),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/Login');
                        },
                        child: const Text('Ingresar')),
                  )),
            ),
            Positioned(
              top: 490,
              left: 0,
              right: -16,
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    width: 100,
                    child: GestureDetector(
                      child: const Text(
                        'Olvido su contraseña?',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  )),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 272,
              child: Image.asset(
                "assets/Vector 4.png",
                fit: BoxFit.cover,
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: SafeArea(
                  child: SizedBox(
                      height: 325, child: Image.asset("assets/Logo2.png")),
                )),
          ],
        ),
      ),
    );
  }
}
