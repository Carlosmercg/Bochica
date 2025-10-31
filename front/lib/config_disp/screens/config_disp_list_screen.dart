import 'package:flutter/material.dart';

class ConfigDispListScreen extends StatelessWidget {
  const ConfigDispListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis dispositivos')),
      body: Center(child: Text('Listado de dispositivos')),
    );
  }
}


