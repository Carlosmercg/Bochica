import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().signInWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      if (mounted) Navigator.of(context).pop(); // o pushNamed a tu dashboard
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (v) =>
                        (v == null || !v.contains('@'))
                            ? 'Email inválido'
                            : null,
              ),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator:
                    (v) =>
                        (v == null || v.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _login,
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
