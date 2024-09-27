import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FocusNode _correoFocusNode = FocusNode();
  final FocusNode _contrasenaFocusNode = FocusNode();

  final Logger logger = Logger();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // _checkUserStatus();
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

  // void _checkUserStatus() {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   User? user = auth.currentUser;

  //   if (user == null) {
  //     // Si el usuario no está autenticado, redirigir a la pantalla de inicio de sesión
  //     logger.e('Usuario no esta autenticado');
  //   } else {
  //     // Si el usuario está autenticado, continuar en la pantalla
  //     logger.e('Usuario autenticado: ${user.email}');
  //   }
  // }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se destruye

    _correoController.dispose();
    _contrasenaController.dispose();

    _correoFocusNode.dispose();
    _contrasenaFocusNode.dispose();

    super.dispose();
  }

  bool _correoIsEmpty = true;
  bool _contrasenaIsEmpty = true;

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

  Future<void> _login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
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

    if (!_isEmailValid(email)) {
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

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('correo', isEqualTo: email)
        .get();

    if (result.docs.isNotEmpty) {
      final bd = result.docs.first;
      final contrasenaValid = bd.get('idCon');
      if (contrasenaValid == password) {
        try {
          // Intentar autenticar al usuario
          UserCredential userCredential = await _auth
              .signInWithEmailAndPassword(email: email, password: password);

          // Si la autenticación es exitosa
          if (userCredential.user != null) {
            String? token = await userCredential.user!.getIdToken();
            logger.i('Token del usuario: $token');

            if (mounted) {
              Navigator.pushNamed(context, '/Home');
            }
          } else {
            _showDialog(
              '¡Error al iniciar sesión usuario o contraseña invalidos...!',
              Icons.highlight_off_outlined,
              Colors.red,
            );
          }
        } on Exception catch (e) {
          logger.e('Error al iniciar sesión: $e');

          _showDialog(
            'Error inesperado: ${e.toString()}',
            Icons.highlight_off_outlined,
            Colors.red,
          );
        }
      } else {
        _showDialog(
          '¡La contraseña es incorrecta!',
          Icons.highlight_off_outlined,
          Colors.red,
        );
      }
    } else {
      _showDialog(
        'Usuario no registrado',
        Icons.highlight_off_outlined,
        Colors.red,
      );
    }
  }

  // void _handleAuthError(String errorCode) {
  //   String message;
  //   switch (errorCode) {
  //     case 'user-not-found':
  //       message = '¡El correo no está registrado!';
  //       break;
  //     case 'invalid-credential':
  //       message = '¡Las credenciales son inválidas o han expirado!';
  //       break;
  //     case 'wrong-password':
  //       message = '¡La contraseña es incorrecta!';
  //       break;
  //     case 'invalid-email':
  //       message = '¡La formato del correo es incorrecto!';
  //       break;
  //     default:
  //       message = '¡Error al iniciar sesión!';
  //       break;
  //   }
  //   _showDialog(message, Icons.error_outline, Colors.red);
  // }

  void _showDialog(String message, IconData icon, Color iconColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 60,
              )
            ],
          ),
          content: Text(
            message,
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

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Iniciar Sesion'),
        backgroundColor: const Color.fromARGB(255, 220, 255, 19),
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
              child: Image.asset("assets/Vector1.png", fit: BoxFit.cover),
            ),
            Align(
              alignment: Alignment.topLeft,
              child:
                  SizedBox(height: 296, child: Image.asset("assets/Logo1.png")),
            ),
            Positioned(
              top: 235,
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
              top: 300,
              right: 0,
              left: 0,
              child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Column(
                    children: [
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
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(60.0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(_correoFocusNode,
                                        _correoIsEmpty, _correoTouched),
                                    width: 2),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(60.0),
                                ),
                              ),
                              hintText: 'Ingrese su Email...',
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
                                _correoTouched = true;
                              });
                            }),
                      ),
                      SizedBox(
                        width: 332,
                        child: TextField(
                            controller: _contrasenaController,
                            focusNode: _contrasenaFocusNode,
                            obscureText: _obscurePassword,
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
              top: 420,
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
                        onPressed: () {
                          String correo = _correoController.text;
                          String contrasena = _contrasenaController.text;
                          _login(correo, contrasena);
                        },
                        child: const Text('Ingresar')),
                  )),
            ),
            Positioned(
              top: 480,
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
                          Navigator.pushNamed(context, '/Registro');
                        },
                        child: const Text('Registrarse')),
                  )),
            ),
            // Positioned(
            //   top: 530,
            //   left: 40,
            //   right: 0,
            //   child: Align(
            //       alignment: Alignment.centerLeft,
            //       child: SizedBox(
            //         width: 150,
            //         child: FilledButton(
            //             style: ButtonStyle(
            //               foregroundColor: WidgetStateProperty.all<Color>(
            //                   const Color.fromARGB(255, 0, 0, 0)),
            //               backgroundColor: WidgetStateProperty.all<Color>(
            //                   const Color(0xFFFF889E)),
            //               shape:
            //                   WidgetStateProperty.all<RoundedRectangleBorder>(
            //                       const RoundedRectangleBorder(
            //                           borderRadius: BorderRadius.only(
            //                 topLeft: Radius.circular(
            //                     60), // Esquina superior izquierda

            //                 bottomRight:
            //                     Radius.circular(60), // Esquina inferior derecha
            //               ))),
            //             ),
            //             onPressed: () {
            //               Navigator.pushNamed(context, '/BD');
            //             },
            //             child: const Text('base de datos')),
            //       )),
            // ),
            Positioned(
              top: 480,
              left: 100,
              right: -55,
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    width: 140,
                    child: GestureDetector(
                      // onTap: _onLinkTap,
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
              height: 272,
              child: Image.asset("assets/Vector2.png", fit: BoxFit.cover),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child:
                  SizedBox(height: 325, child: Image.asset("assets/Logo2.png")),
            ),
          ],
        ),
      ),
    );
  }
}
