import 'package:flutter/material.dart';

class TiendaDetalleProductoScreen extends StatelessWidget {
  const TiendaDetalleProductoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle del producto')),
      body: Center(child: Text('Información del producto seleccionado')),
    );
  }
}


