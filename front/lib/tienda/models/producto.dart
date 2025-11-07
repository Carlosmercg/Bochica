<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';

=======
>>>>>>> 7278422fab9b7f798348c44b5deda41397079e09
class Producto {
  final String id;
  final String nombre;
  final String descripcion;
<<<<<<< HEAD
  final int precio;        // COP
  final String? imagen;    // url o asset opcional
  final bool activo;       // para filtrar visibles
=======
  final int precio; // COP
  final String? imagen; // asset o url
>>>>>>> 7278422fab9b7f798348c44b5deda41397079e09

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagen,
<<<<<<< HEAD
    this.activo = true,
  });

  factory Producto.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final numPrecio = d['precio'];
    return Producto(
      id: doc.id,
      nombre: (d['nombre'] ?? '').toString(),
      descripcion: (d['descripcion'] ?? '').toString(),
      precio: numPrecio is int ? numPrecio : (numPrecio is num ? numPrecio.toInt() : 0),
      imagen: (d['imagen'] as String?),
      activo: (d['activo'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'imagen': imagen,
    'activo': activo,
  };
=======
  });
>>>>>>> 7278422fab9b7f798348c44b5deda41397079e09
}
