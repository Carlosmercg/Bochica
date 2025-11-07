import 'package:flutter/material.dart';
import '../models/producto.dart';

class TiendaCompraResultadoScreen extends StatelessWidget {
  const TiendaCompraResultadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final Producto p = args['producto'];
    final String nombre = args['nombre'];
    final int cantidad = args['cantidad'];
    final String metodo = args['metodoPago'];
    final DateTime fecha = args['fecha'];
    final String ref = args['referencia'];

    return Scaffold(
      appBar: AppBar(title: const Text('Pago exitoso')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // QR (usa qr_flutter si lo agregas al pubspec)
          Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black12, borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('QR'),
          ),
          const SizedBox(height: 16),
          _row('Nombre', nombre),
          _row('Cantidad', '$cantidad'),
          _row('Fecha', '${fecha.day}/${fecha.month}/${fecha.year}'),
          _row('Referencia', ref),
          _row('Producto(s)', p.nombre),
          _row('Método de pago', metodo),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF20C06D).withOpacity(.12),
              border: Border.all(color: const Color(0xFF20C06D).withOpacity(.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('MUCHAS GRACIAS',
              style: TextStyle(color: Color(0xFF20C06D), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _row(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(a, style: const TextStyle(fontWeight: FontWeight.w700))),
        Text(b),
      ],
    ),
  );
}
