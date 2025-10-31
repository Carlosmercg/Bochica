import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class AuthLoginScreen extends StatelessWidget {
  const AuthLoginScreen({super.key});

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
                        const Text('Ingresa', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        const TextField(decoration: InputDecoration(labelText: 'Correo')),
                        const SizedBox(height: 12),
                        const TextField(decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.dashboardGeneralUsuario),
                          child: const Text('Ingresa'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.authRegister),
                          child: const Text('No tienes cuenta? Regístrate'),
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


