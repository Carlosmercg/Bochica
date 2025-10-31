import 'package:flutter/material.dart';

class TiendaScreen extends StatelessWidget {
  const TiendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
      ),
      body: const Center(
        child: Text('Pantalla de Tienda'),
      ),
    );
  }
}


