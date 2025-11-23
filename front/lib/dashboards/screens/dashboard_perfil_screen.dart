import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_info_service.dart';

class DashboardPerfilScreen extends StatefulWidget {
  const DashboardPerfilScreen({super.key});

  @override
  State<DashboardPerfilScreen> createState() => _DashboardPerfilScreenState();
}

class _DashboardPerfilScreenState extends State<DashboardPerfilScreen> {
  final UserInfoService _userInfoService = UserInfoService();
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos editables
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _ciudadController;
  late TextEditingController _codigoPostalController;
  late TextEditingController _paisController;

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _correoController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _ciudadController = TextEditingController();
    _codigoPostalController = TextEditingController();
    _paisController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _codigoPostalController.dispose();
    _paisController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Obtener información de autenticación
      final nombre = user.displayName ?? 
          (user.email != null ? user.email!.split('@').first : 'Usuario');
      final correo = user.email ?? '';

      // Obtener información adicional de UserInfo
      final userInfo = await _userInfoService.getUserInfo(user.uid);
      
      setState(() {
        _nombreController.text = nombre;
        _correoController.text = correo;
        _telefonoController.text = userInfo?['telefono'] ?? '';
        _direccionController.text = userInfo?['direccion'] ?? '';
        _ciudadController.text = userInfo?['ciudad'] ?? '';
        _codigoPostalController.text = userInfo?['codigoPostal'] ?? '';
        _paisController.text = userInfo?['pais'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar datos del usuario: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay sesión activa')),
          );
        }
        return;
      }

      // Actualizar displayName si cambió
      if (_nombreController.text.trim() != (user.displayName ?? '')) {
        await user.updateDisplayName(_nombreController.text.trim());
      }

      // Actualizar UserInfo
      await _userInfoService.updateUserInfo(user.uid, {
        'telefono': _telefonoController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'ciudad': _ciudadController.text.trim(),
        'codigoPostal': _codigoPostalController.text.trim(),
        'pais': _paisController.text.trim(),
      });

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información guardada exitosamente')),
        );
        await _loadUserData(); // Recargar datos
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await context.read<AuthService>().signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.authWelcome,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: brand.bg,
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _BottomNav(
          currentIndex: 4,
          onTap: (i, ctx) => _handleNavigation(i, ctx),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: brand.bg,
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No hay sesión activa.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.authLogin,
                ),
                child: const Text('Ir a Iniciar sesión'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: 4,
          onTap: (i, ctx) => _handleNavigation(i, ctx),
        ),
      );
    }

    return Scaffold(
      backgroundColor: brand.bg,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Foto de perfil y nombre de usuario
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: brand.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: brand.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _nombreController.text.isNotEmpty
                          ? _nombreController.text
                          : 'Usuario',
                      style: brand.h1.copyWith(color: brand.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campo Nombre
              _InfoField(
                label: 'Nombre',
                controller: _nombreController,
                icon: Icons.person,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Campo Correo
              _InfoField(
                label: 'Correo',
                controller: _correoController,
                icon: Icons.email,
                enabled: false, // El correo no se puede editar
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Campo Teléfono
              _InfoField(
                label: 'Teléfono',
                controller: _telefonoController,
                icon: Icons.phone,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // Campo Dirección
              _InfoField(
                label: 'Dirección',
                controller: _direccionController,
                icon: Icons.home,
                enabled: _isEditing,
              ),
              const SizedBox(height: 12),

              // Campo Ciudad
              _InfoField(
                label: 'Ciudad',
                controller: _ciudadController,
                icon: Icons.location_city,
                enabled: _isEditing,
              ),
              const SizedBox(height: 12),

              // Campo Código Postal
              _InfoField(
                label: 'Código Postal',
                controller: _codigoPostalController,
                icon: Icons.markunread_mailbox,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Campo País
              _InfoField(
                label: 'País',
                controller: _paisController,
                icon: Icons.public,
                enabled: _isEditing,
              ),
              const SizedBox(height: 24),

              // Botones de acción
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                setState(() => _isEditing = false);
                                _loadUserData(); // Recargar datos originales
                              },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Guardar'),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar información'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              const SizedBox(height: 24),

              // Botón cerrar sesión
              ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brand.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 4,
        onTap: (i, ctx) => _handleNavigation(i, ctx),
      ),
    );
  }

  void _handleNavigation(int index, BuildContext ctx) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          AppRoutes.dashboardGeneralUsuario,
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          AppRoutes.dashboardConfigurar,
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          AppRoutes.dashboardVincular,
          (route) => false,
        );
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          AppRoutes.estados,
          (route) => false,
        );
        break;
      case 4:
        // Ya estamos en perfil
        break;
    }
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.controller,
    required this.icon,
    this.enabled = true,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: brand.primary),
          suffixIcon: enabled
              ? Icon(Icons.edit, color: brand.primary.withOpacity(0.5), size: 20)
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int index, BuildContext ctx) onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => onTap(i, context),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Configurar',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Vincular',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Estado',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}

class _Brand {
  const _Brand();
  final Color primary = const Color(0xFF6A5AE0);
  final Color bg = const Color(0xFFF5F6FA);
  TextStyle get h1 => const TextStyle(fontSize: 32, fontWeight: FontWeight.w800);
}

