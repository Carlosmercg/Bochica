import 'package:flutter/material.dart';

class ConfigDispInstruccionesScreen extends StatelessWidget {
  const ConfigDispInstruccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Instrucciones del dispositivo')),
      body: Center(child: Text('Guía y pasos de configuración')),
    );
  }
}


