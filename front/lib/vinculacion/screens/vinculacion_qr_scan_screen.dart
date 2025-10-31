import 'package:flutter/material.dart';

class VinculacionQrScanScreen extends StatelessWidget {
  const VinculacionQrScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vinculación - Escanear QR')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Abrir cámara para escanear QR'),
        ),
      ),
    );
  }
}


