import 'package:flutter/material.dart';

class TiendaCompraInfoScreen extends StatelessWidget {
  const TiendaCompraInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Datos para la compra')),
      body: Center(child: Text('Formulario de información de compra')),
    );
  }
}


