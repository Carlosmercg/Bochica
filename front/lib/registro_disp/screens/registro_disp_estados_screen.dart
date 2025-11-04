import 'package:flutter/material.dart';

class RegistroDispEstadosScreen extends StatelessWidget {
  const RegistroDispEstadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estados de dispositivos')),
      body: Center(child: Text('Estados actuales de tus dispositivos')),
    );
  }
}


