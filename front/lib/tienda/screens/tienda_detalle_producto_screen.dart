import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../../core/routes/app_routes.dart';

class TiendaDetalleProductoScreen extends StatelessWidget {
  const TiendaDetalleProductoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final producto = ModalRoute.of(context)!.settings.arguments as Producto;

    return Scaffold(
      appBar: AppBar(title: Text(producto.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: producto.imagen == null || producto.imagen!.isEmpty
                  ? const Icon(Icons.chair_alt_rounded, size: 100)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(producto.imagen!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(producto.descripcion),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('\$ ${producto.precio ~/ 1000}.000',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.tiendaCompraInfo, arguments: producto);
                },
                child: const Text('Comprar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
