import 'package:flutter/material.dart';

class ConfigDispDetalleScreen extends StatelessWidget {
  const ConfigDispDetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle del dispositivo')),
      body: Center(child: Text('Información del dispositivo seleccionado')),
    );
  }
}


