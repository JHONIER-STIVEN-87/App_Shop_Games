import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final Logger logger = Logger();
  List<Map<String, dynamic>> carrito = [];

  @override
  void initState() {
    super.initState();
    _obtenerRolUsuario();
  }

  void _mostrarCarrito(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Carrito de Compras'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: carrito.map((producto) {
              int index =
                  carrito.indexOf(producto); // Obtener el índice del producto

              return ListTile(
                leading: producto['imageUrl'] != ''
                    ? Image.network(producto['imageUrl'], width: 50, height: 50)
                    : const Icon(Icons.image_not_supported),
                title: Text(producto['nombre']),
                subtitle: Text('Precio: \$${producto['precio']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      carrito
                          .removeAt(index); // Eliminar el producto del carrito
                    });
                    Navigator.of(context).pop(); // Cerrar el diálogo actual
                    _mostrarCarrito(context); // Reabrir el diálogo actualizado
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar compra'),
              onPressed: () {
                setState(() {
                  carrito.clear(); // Vaciar el carrito tras la compra
                });
                Navigator.of(context).pop();
                _mostrarCompraExitosa(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarCompraExitosa(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content:
              const Text('¡Compra exitosa!', style: TextStyle(fontSize: 20)),
          actions: [
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar un producto del carrito
  // Función para obtener el rol del usuario autenticado
  String? rolUsuario;

  Future<void> _obtenerRolUsuario() async {
    User? usuarioActual = FirebaseAuth.instance.currentUser;

    if (usuarioActual != null) {
      // Obtén el documento del usuario en Firestore
      var documentoUsuario = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioActual.uid)
          .get();

      if (documentoUsuario.exists) {
        setState(() {
          rolUsuario = documentoUsuario.data()?['rol'];
        });

        logger.i('Rol del usuario: $rolUsuario');
      } else {
        logger.e('El usuario no tiene un rol asignado.');
      }
    }
  }

  void _produtoAgregado(BuildContext context, String nombreProducto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Text(
              '¡Producto Agregado al carrito!... Ya puedes ir a ver y comprar el pruducto!',
              style: TextStyle(fontSize: 20, color: Colors.green)),
          actions: [
            TextButton(
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colors.green, fontSize: 20),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        backgroundColor: const Color.fromARGB(255, 6, 252, 104),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 0),
        width: double.infinity,
        height: double.infinity,
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 246, 246, 246)),
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('productos').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No hay productos disponibles'));
            }

            // Construye una lista de Cards para cada producto
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var product = snapshot.data!.docs[index];
                var imageUrl = product['imagenProductoURL'] ?? '';
                var nombreProducto = product['nombre_producto'] ?? 'Sin nombre';
                var descripcion = product['descripcion'] ?? 'Sin descripción';
                var precio = product['precio']?.toString() ?? 'Sin precio';

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: imageUrl.isNotEmpty
                            ? Image.network(imageUrl,
                                width: 60, height: 60, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(nombreProducto),
                        subtitle: Text(descripcion),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Precio: \$ $precio'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          if (rolUsuario == 'Cliente')
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  carrito.add({
                                    'nombre': nombreProducto,
                                    'precio': precio,
                                    'imageUrl': imageUrl,
                                  });
                                });
                                _produtoAgregado(context, nombreProducto);
                                logger.i(
                                    'Producto agregado al carrito: $nombreProducto');
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Comprar'),
                                  SizedBox(width: 5),
                                  Icon(Icons.add_shopping_cart_sharp),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: Stack(
        children: [
          if (rolUsuario == 'Administrador')
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Agregar Productos',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    heroTag: 'boton1',
                    child: const Icon(Icons.add_business_rounded),
                    onPressed: () {
                      Navigator.pushNamed(context, '/RegistroProducto');
                    },
                  ),
                ],
              ),
            ),
          Positioned(
            left: 25,
            bottom: 0,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                heroTag: 'boton2',
                child: const Icon(Icons.shopping_cart_sharp),
                onPressed: () {
                  if (carrito.isNotEmpty) {
                    _mostrarCarrito(context);
                  } else {
                    logger.e('El carrito está vacío');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El carrito está vacío')),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
