import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final int precio;        // COP
  final String? imagen;    // url o asset opcional
  final bool activo;       // para filtrar visibles

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagen,
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
}
