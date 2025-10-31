import 'package:flutter/material.dart';

class AuthPerfilScreen extends StatelessWidget {
  const AuthPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil de usuario')),
      body: Center(child: Text('Datos del perfil')),
    );
  }
}


