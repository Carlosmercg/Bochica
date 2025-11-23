import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../tienda/models/producto.dart';
import '../../tienda/services/products_repository.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_disp_service.dart';

class DashboardVincularScreen extends StatefulWidget {
  const DashboardVincularScreen({super.key});

  @override
  State<DashboardVincularScreen> createState() => _DashboardVincularScreenState();
}

class _DashboardVincularScreenState extends State<DashboardVincularScreen> {
  final ProductsRepository _productsRepository = ProductsRepository();
  final UserDispService _userDispService = UserDispService();
  Producto? _selectedProduct;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleVincular() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un producto')),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el nombre del dispositivo')),
      );
      return;
    }

    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el código')),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sesión activa')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Guardar dispositivo en UserDisp
      await _userDispService.createDevice(
        userId: user.uid,
        nombre: _nameController.text.trim(),
        tipoProducto: _selectedProduct!.id,
      );

      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al vincular: $e')),
        );
      }
    }
  }

  void _resetAndGoHome() {
    setState(() {
      _selectedProduct = null;
      _codeController.clear();
      _nameController.clear();
      _showSuccess = false;
    });
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.dashboardGeneralUsuario,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();

    if (_showSuccess) {
      return Scaffold(
        backgroundColor: brand.bg,
        appBar: AppBar(
          title: const Text('Vinculación'),
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: brand.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¡Vinculación Exitosa!',
                    style: brand.h1.copyWith(color: brand.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'El dispositivo "${_nameController.text}" ha sido vinculado correctamente.',
                    style: brand.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _resetAndGoHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Volver al inicio'),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: 2,
          onTap: (i, ctx) => _handleNavigation(i, ctx),
        ),
      );
    }

    return Scaffold(
      backgroundColor: brand.bg,
      appBar: AppBar(
        title: const Text('Vincular Dispositivo'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            Text(
              'Selecciona un producto',
              style: brand.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'Elige el dispositivo que deseas vincular',
              style: brand.body.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Lista de productos
            StreamBuilder<List<Producto>>(
              stream: _productsRepository.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Error al cargar productos: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final productos = snapshot.data ?? [];
                if (productos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No hay productos disponibles',
                        style: brand.body,
                      ),
                    ),
                  );
                }

                return Column(
                  children: productos.map((producto) {
                    final isSelected = _selectedProduct?.id == producto.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProductCard(
                        producto: producto,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedProduct = producto;
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            if (_selectedProduct != null) ...[
              const SizedBox(height: 32),
              // Campo de nombre
              Text(
                'Nombre del dispositivo',
                style: brand.h3,
              ),
              const SizedBox(height: 12),
              Container(
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
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej: Baño Piso 1, Ducha Principal',
                    prefixIcon: Icon(Icons.label, color: brand.primary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Campo de código
              Text(
                'Ingresa el código del dispositivo',
                style: brand.h3,
              ),
              const SizedBox(height: 12),
              Container(
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
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Código',
                    hintText: 'Ingresa el código del dispositivo',
                    prefixIcon: Icon(Icons.qr_code, color: brand.primary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Botón vincular
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVincular,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brand.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Vincular'),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 2,
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
        // Ya estamos en vincular
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          AppRoutes.estados,
          (route) => false,
        );
        break;
      case 4:
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          AppRoutes.dashboardPerfil,
          (route) => false,
        );
        break;
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.producto,
    required this.isSelected,
    required this.onTap,
  });

  final Producto producto;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? brand.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen o icono
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: brand.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: producto.imagen != null && producto.imagen!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        producto.imagen!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.devices_other,
                      color: brand.primary,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: brand.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    producto.descripcion,
                    style: brand.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Indicador de selección
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: brand.primary,
                size: 28,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey[400],
                size: 28,
              ),
          ],
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
  TextStyle get h2 => const TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  TextStyle get h3 => const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  TextStyle get body => const TextStyle(fontSize: 14, color: Colors.black87);
  TextStyle get caption => const TextStyle(fontSize: 12, color: Colors.black54);
}

