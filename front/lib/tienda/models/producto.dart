class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final int precio; // COP
  final String? imagen; // asset o url

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagen,
  });
}
