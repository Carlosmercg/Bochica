import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class AuthRegistroScreen extends StatelessWidget {
  const AuthRegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF26C6DA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Regístrate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        const TextField(decoration: InputDecoration(labelText: 'Nombre completo')),
                        const SizedBox(height: 12),
                        const TextField(decoration: InputDecoration(labelText: 'Correo')),
                        const SizedBox(height: 12),
                        const TextField(decoration: InputDecoration(labelText: 'Fecha de nacimiento')),
                        const SizedBox(height: 12),
                        const TextField(decoration: InputDecoration(labelText: 'Número telefónico')),
                        const SizedBox(height: 12),
                        const TextField(decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.authLogin),
                          child: const Text('Registrarte'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.authLogin),
                          child: const Text('Ya tienes cuenta? Ingresa'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


