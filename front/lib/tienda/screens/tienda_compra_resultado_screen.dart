import 'package:flutter/material.dart';

class TiendaCompraResultadoScreen extends StatelessWidget {
  const TiendaCompraResultadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resultado de la compra')),
      body: Center(child: Text('Validación: éxito o error de la compra')),
    );
  }
}


