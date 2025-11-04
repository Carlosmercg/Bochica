import 'package:flutter/material.dart';

class RegistroDispInteraccionesScreen extends StatelessWidget {
  const RegistroDispInteraccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Interacciones del dispositivo')),
      body: Center(child: Text('Registros de interacciones del dispositivo seleccionado')),
    );
  }
}


