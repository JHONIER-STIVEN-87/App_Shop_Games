import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class RegistrarProducto extends StatefulWidget {
  const RegistrarProducto({super.key});

  @override
  RegistrarProductoState createState() => RegistrarProductoState();
}

class RegistrarProductoState extends State<RegistrarProducto> {
  final TextEditingController _accesorioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _nombreProductoController =
      TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  final FocusNode _descripcionFocusNode = FocusNode();
  final FocusNode _nombreProductoFocusNode = FocusNode();
  final FocusNode _precioFocusNode = FocusNode();

  final Logger logger = Logger();

  final List<String> _accesorioOpciones = [
    'Consolas',
    'Video Juegos',
    'Controles',
    'Accesorios para consola',
    'Otros'
  ];
  final List<String> _estadoOpciones = ['Nuevo', 'Usado'];

  List<String> _accesorioSelectedItems = [];
  List<String> _estadoSelectedItems = [];

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _descripcionFocusNode.addListener(() {
      setState(() {
        _descripcionIsEmpty = _descripcionController.text.isEmpty;
      });
    });

    _nombreProductoController.addListener(() {
      setState(() {
        _nombreProductoIsEmpty = _nombreProductoController.text.isEmpty;
      }); // Actualiza el estado cuando el enfoque cambia
    });
    _precioController.addListener(() {
      setState(() {
        _precioIsEmpty = _precioController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se destruye
    _accesorioController.dispose();
    _descripcionController.dispose();
    _estadoController.dispose();
    _nombreProductoController.dispose();
    _precioController.dispose();

    _descripcionFocusNode.dispose();
    _nombreProductoFocusNode.dispose();
    _precioFocusNode.dispose();

    super.dispose();
  }

  bool _descripcionIsEmpty = true;
  bool _nombreProductoIsEmpty = true;
  bool _precioIsEmpty = true;

  bool _descripcionTouched = false;
  bool _nombreProductoTouched = false;
  bool _precioTouched = false;

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

  void _showSingleSelect(BuildContext context) async {
    // Asignamos un valor inicial para selectedItem que es un String no nulo.
    String? selectedItem;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Seleccione una opción'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: _accesorioOpciones.map((option) {
                    return RadioListTile<String>(
                      value: option,
                      groupValue:
                          selectedItem, // Valor actualmente seleccionado
                      title: Text(option),
                      activeColor: Colors
                          .green, // Color del radio cuando está seleccionado
                      // Cambia el color de fondo
                      onChanged: (value) {
                        setState(() {
                          selectedItem =
                              value; // Actualiza la selección temporal
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(ctx)
                    .pop(); // Cierra el diálogo sin guardar cambios
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                setState(() {
                  if (selectedItem != null) {
                    _accesorioSelectedItems = [
                      selectedItem!
                    ]; // Agrega el elemento seleccionado, forzando a String
                  } else {
                    _accesorioSelectedItems
                        .clear(); // O simplemente limpia la lista
                  }
                  _accesorioController.text =
                      selectedItem ?? ''; // Asigna el valor o cadena vacía
                });
                Navigator.of(ctx)
                    .pop(); // Cierra el diálogo y guarda la opción seleccionada
              },
            ),
          ],
        );
      },
    );
  }

  void _showSingleSelect2(BuildContext context) async {
    // Asignamos un valor inicial para selectedItem que es un String no nulo.
    String? selectedItem;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Seleccione una opción'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: _estadoOpciones.map((option) {
                    return RadioListTile<String>(
                      value: option,
                      groupValue:
                          selectedItem, // Valor actualmente seleccionado
                      title: Text(option),
                      activeColor: Colors
                          .green, // Color del radio cuando está seleccionado
                      // Cambia el color de fondo
                      onChanged: (value) {
                        setState(() {
                          selectedItem =
                              value; // Actualiza la selección temporal
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(ctx)
                    .pop(); // Cierra el diálogo sin guardar cambios
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                setState(() {
                  if (selectedItem != null) {
                    _estadoSelectedItems = [
                      selectedItem!
                    ]; // Agrega el elemento seleccionado, forzando a String
                  } else {
                    _estadoSelectedItems
                        .clear(); // O simplemente limpia la lista
                  }
                  _estadoController.text =
                      selectedItem ?? ''; // Asigna el valor o cadena vacía
                });
                Navigator.of(ctx)
                    .pop(); // Cierra el diálogo y guarda la opción seleccionada
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      logger.e('Ruta de la imagen seleccionada: ${_image!.path}');
      // Llama a cargaImagen después de seleccionar la imagen
    } else {
      logger.e('No se ha seleccionado ninguna imagen');
    }
  }

  String? imagenCargadaURL;
  Future<void> cargaImagen() async {
    String? imageUrl;

    if (_image != null) {
      final file = File(_image!.path);

      if (await file.exists()) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('productos/$fileName');

        try {
          UploadTask uploadTask = storageReference.putFile(file);

          await uploadTask; // Esperar a que la tarea se complete

          imageUrl = await storageReference.getDownloadURL();
          imagenCargadaURL = imageUrl;
          logger.e('URL de la imagen subida: $imagenCargadaURL');
        } catch (e) {
          logger.e('Error al subir la imagen: $e');
        }
      } else {
        logger.e('La imagen no existe en la ruta: ${file.path}');
      }
    }
  }

  Future<void> _registrarProducto() async {
    if (_accesorioController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _estadoController.text.isEmpty ||
        _nombreProductoController.text.isEmpty ||
        _precioController.text.isEmpty) {
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

    const fomatoNumerico = r'^\d+(\.\d+)?$';
    final regex = RegExp(fomatoNumerico);

    if (!regex.hasMatch(_precioController.text)) {
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
              '¡El formato del precio no es valido...!',
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

    await cargaImagen();

    try {
      await FirebaseFirestore.instance.collection('productos').add({
        'accesorio': _accesorioController.text,
        'descripcion': _descripcionController.text,
        'estado': _estadoController.text,
        'nombre_producto': _nombreProductoController.text,
        'precio': double.parse(_precioController.text),
        'imagenProductoURL': imagenCargadaURL
        // 'imagen_url': imageUrl,
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
                    Navigator.of(context).pushReplacementNamed('/Home');
                  },
                ),
              ],
            );
          },
        );
      }

      _accesorioController.clear();
      _descripcionController.clear();
      _estadoController.clear();
      _nombreProductoController.clear();
      _precioController.clear();
      _image = null;
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
                '¡Error al registrar el producto!: $e',
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
        title: const Text('Registrar Productos'),
        backgroundColor: const Color.fromARGB(255, 227, 6, 252),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 0),
        width: double.infinity,
        height: double.infinity,
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 246, 246, 246)),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child:
                  SizedBox(height: 150, child: Image.asset("assets/Logo1.png")),
            ),
            Positioned(
              top: 120,
              right: 0,
              left: 0,
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Registrar Producto',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 30),
                ),
              ),
            ),
            Positioned(
              top: 170,
              right: 0,
              left: 0,
              child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 332,
                        child: TextField(
                          controller: _accesorioController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(60.0),
                                  topLeft: Radius.circular(60.0)),
                            ),
                            hintText: 'Seleccione el accesorio a registrar...',
                            filled: true,
                            fillColor: const Color(0xFFD0D0D0),
                            suffixIcon: IconButton(
                              padding:
                                  const EdgeInsets.only(right: 20.0, top: 5),
                              icon: const Icon(
                                Icons.arrow_circle_down_sharp,
                                color: Color.fromARGB(255, 0, 0, 0),
                                size: 30,
                              ),
                              onPressed: () {
                                _showSingleSelect(context);
                              },
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      SizedBox(
                        width: 332,
                        child: TextField(
                            controller: _descripcionController,
                            focusNode: _descripcionFocusNode,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(
                                        _descripcionFocusNode,
                                        _descripcionIsEmpty,
                                        _descripcionTouched),
                                    width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(
                                        _descripcionFocusNode,
                                        _descripcionIsEmpty,
                                        _descripcionTouched),
                                    width: 2),
                              ),
                              hintText:
                                  'Ingrese una descripcion del producto...',
                              filled: true,
                              fillColor: const Color(0xFFD0D0D0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _descripcionTouched = true;
                              });
                            }),
                      ),
                      SizedBox(
                        width: 332,
                        child: TextField(
                          controller: _estadoController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Seleccione el estado a registrar...',
                            filled: true,
                            fillColor: const Color(0xFFD0D0D0),
                            suffixIcon: IconButton(
                              padding:
                                  const EdgeInsets.only(right: 20.0, top: 5),
                              icon: const Icon(
                                Icons.arrow_circle_down_sharp,
                                color: Color.fromARGB(255, 0, 0, 0),
                                size: 30,
                              ),
                              onPressed: () {
                                _showSingleSelect2(context);
                              },
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      SizedBox(
                        width: 332,
                        child: TextField(
                            controller: _nombreProductoController,
                            focusNode: _nombreProductoFocusNode,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(
                                        _nombreProductoFocusNode,
                                        _nombreProductoIsEmpty,
                                        _nombreProductoTouched),
                                    width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(
                                        _nombreProductoFocusNode,
                                        _nombreProductoIsEmpty,
                                        _nombreProductoTouched),
                                    width: 2),
                              ),
                              hintText: 'Ingrese el nombre del producto...',
                              filled: true,
                              fillColor: const Color(0xFFD0D0D0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _nombreProductoTouched = true;
                              });
                            }),
                      ),
                      SizedBox(
                        width: 332,
                        child: TextField(
                            controller: _precioController,
                            focusNode: _precioFocusNode,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(_precioFocusNode,
                                        _precioIsEmpty, _precioTouched),
                                    width: 2),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(60.0),
                                  bottomLeft: Radius.circular(60.0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _getBorderColor2(_precioFocusNode,
                                        _precioIsEmpty, _precioTouched),
                                    width: 2),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(60.0),
                                  bottomLeft: Radius.circular(60.0),
                                ),
                              ),
                              hintText: 'Ingrese el precio del producto...',
                              filled: true,
                              fillColor: const Color(0xFFD0D0D0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _precioTouched = true;
                              });
                            }),
                      ),
                    ],
                  )),
            ),
            Positioned(
                top: 460,
                left: 0,
                right: 0,
                child: Align(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _image != null
                          ? Image.file(_image!, width: 100, height: 100)
                          : const Text(
                              'No se ha seleccionado ninguna imagen...'),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.image_rounded),
                        label: const Text('Subir Imagen'),
                        onPressed: _pickImage,
                      )
                    ],
                  ),
                )),
            Positioned(
              top: 640,
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
                        onPressed: _registrarProducto,
                        child: const Text('Registrar')),
                  )),
            ),
            Positioned(
              top: 695,
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
                          Navigator.pushNamed(context, '/Home');
                        },
                        child: const Text('Atras')),
                  )),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: SafeArea(
                  child: SizedBox(
                      height: 150, child: Image.asset("assets/Logo2.png")),
                )),
          ],
        ),
      ),
    );
  }
}
