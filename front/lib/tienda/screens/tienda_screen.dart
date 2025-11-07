import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class TiendaScreen extends StatelessWidget {
  const TiendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Puedes convertirla en una pantalla con tabs si quieres.
    // Por ahora, navega directo a la lista de productos.
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, AppRoutes.tiendaProductos);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
