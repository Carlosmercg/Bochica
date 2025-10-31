import 'package:flutter/material.dart';

class VinculacionExitoScreen extends StatelessWidget {
  const VinculacionExitoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vinculación exitosa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Asigna un nombre al dispositivo:'),
            SizedBox(height: 8),
            TextField(decoration: InputDecoration(border: OutlineInputBorder())),
          ],
        ),
      ),
    );
  }
}


