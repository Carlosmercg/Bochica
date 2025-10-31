import 'package:flutter/material.dart';

class RegistroDispScreen extends StatelessWidget {
  const RegistroDispScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Dispositivo'),
      ),
      body: const Center(
        child: Text('Pantalla de Registro de Dispositivo'),
      ),
    );
  }
}


