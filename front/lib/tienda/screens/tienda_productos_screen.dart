import 'package:flutter/material.dart';

class TiendaProductosScreen extends StatelessWidget {
  const TiendaProductosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tienda - Productos disponibles')),
      body: Center(child: Text('Listado de productos')),
    );
  }
}


