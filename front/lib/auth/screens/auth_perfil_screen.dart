import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';

class AuthPerfilScreen extends StatefulWidget {
  const AuthPerfilScreen({super.key});

  @override
  State<AuthPerfilScreen> createState() => _AuthPerfilScreenState();
}

class _AuthPerfilScreenState extends State<AuthPerfilScreen> {
  final _auth = AuthService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      setState(() {
        _profile = {
          'uid': user?.uid ?? '',
          'email': user?.email ?? '',
          'displayName': user?.displayName ?? '',
          'isEmailVerified': user?.emailVerified ?? false,
          'providerId':
              user?.providerData.isNotEmpty == true
                  ? user!.providerData.first.providerId
                  : '',
        };
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error perfil: $e')));
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.authWelcome,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No hay sesión activa.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.authLogin,
                    ),
                child: const Text('Ir a Iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UID: ${_profile?['uid'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Correo: ${_profile?['email'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Nombre: ${_profile?['displayName'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Verificado: ${_profile?['isEmailVerified'] ?? false}'),
                  const SizedBox(height: 8),
                  Text('Proveedor: ${_profile?['providerId'] ?? ''}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
