import 'package:flutter/material.dart';

class ConfigDispScreen extends StatelessWidget {
  const ConfigDispScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Dispositivo'),
      ),
      body: const Center(
        child: Text('Pantalla de Configuración de Dispositivo'),
      ),
    );
  }
}


