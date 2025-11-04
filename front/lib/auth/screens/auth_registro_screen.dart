import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👈 Falta este import
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';

class AuthRegistroScreen extends StatefulWidget {
  const AuthRegistroScreen({super.key});

  @override
  State<AuthRegistroScreen> createState() => _AuthRegistroScreenState();
}

class _AuthRegistroScreenState extends State<AuthRegistroScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(); // 👈 Agregado
  bool _loading = false;

  Future<void> _registrar() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;

    setState(() => _loading = true);
    try {
      await context.read<AuthService>().registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        displayName: _nameCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Usuario creado con éxito')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.authLogin);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Regístrate',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loading ? null : _registrar,
                          child:
                              _loading
                                  ? const CircularProgressIndicator()
                                  : const Text('Crear cuenta'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed:
                              () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.authLogin,
                              ),
                          child: const Text('¿Ya tienes cuenta? Ingresa aquí'),
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
