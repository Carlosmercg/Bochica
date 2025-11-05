import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../../core/routes/app_routes.dart';

class TiendaProductosScreen extends StatelessWidget {
  const TiendaProductosScreen({super.key});

  List<Producto> get _items => const [
    Producto(
      id: 'sanitario',
      nombre: 'Sanitario Bochica',
      descripcion: 'Kit de dispositivos para convertir tu inodoro en inteligente.',
      precio: 500000,
    ),
    Producto(
      id: 'ducha',
      nombre: 'Ducha Bochica',
      descripcion: 'Regulador inteligente para ahorro de agua en la ducha.',
      precio: 350000,
    ),
    Producto(
      id: 'lavadora',
      nombre: 'Lavadora Bochica',
      descripcion: 'Módulo de control de consumo para lavadoras convencionales.',
      precio: 420000,
    ),
  ];

  void _abrirDetalle(BuildContext ctx, Producto p) {
    Navigator.pushNamed(ctx, AppRoutes.tiendaDetalle, arguments: p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos Disponibles')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (ctx, i) {
          final p = _items[i];
          return ListTile(
            leading: const Icon(Icons.devices_other),
            title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(p.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text('\$ ${p.precio ~/ 1000}.000'),
            onTap: () => _abrirDetalle(ctx, p),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: _items.length,
      ),
    );
  }
}
