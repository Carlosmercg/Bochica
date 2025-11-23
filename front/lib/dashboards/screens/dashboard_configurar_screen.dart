import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_disp_service.dart';
import '../../tienda/services/products_repository.dart';
import '../../tienda/models/producto.dart';

class DashboardConfigurarScreen extends StatelessWidget {
  const DashboardConfigurarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final userDispService = UserDispService();
    final productsRepository = ProductsRepository();

    if (user == null) {
      return Scaffold(
        backgroundColor: brand.bg,
        appBar: AppBar(
          title: const Text('Configurar'),
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No hay sesión activa'),
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: 1,
          onTap: (i, ctx) => _handleNavigation(i, ctx),
        ),
      );
    }

    return Scaffold(
      backgroundColor: brand.bg,
      appBar: AppBar(
        title: const Text('Configurar Dispositivos'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: userDispService.streamUserDevices(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final devices = snapshot.data ?? [];

            if (devices.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.devices_other,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay dispositivos registrados',
                        style: brand.body.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return FutureBuilder(
              future: productsRepository.watchAll().first,
              builder: (context, productsSnapshot) {
                final productos = productsSnapshot.data ?? [];
                final productMap = {for (var p in productos) p.id: p};

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final device = devices[i];
                    final producto = productMap[device.tipoProducto];
                    return _DeviceCard(
                      device: device,
                      producto: producto,
                      onTap: () => DashboardConfigurarScreen._showDeviceOptions(context, device, producto, userDispService),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 1,
        onTap: (i, ctx) => _handleNavigation(i, ctx),
      ),
    );
  }

  static void _showDeviceOptions(
    BuildContext context,
    UserDevice device,
    Producto? producto,
    UserDispService userDispService,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DeviceOptionsSheet(
        device: device,
        producto: producto,
        userDispService: userDispService,
      ),
    );
  }

  static void _handleNavigation(int index, BuildContext ctx) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          ctx,
          AppRoutes.dashboardGeneralUsuario,
          (route) => false,
        );
        break;
      case 1:
        // Ya estamos en configurar
        break;
      case 2:
        Navigator.pushNamed(ctx, AppRoutes.dashboardVincular);
        break;
      case 3:
        Navigator.pushNamed(ctx, AppRoutes.estados);
        break;
      case 4:
        Navigator.pushNamed(ctx, AppRoutes.dashboardPerfil);
        break;
    }
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    this.producto,
    required this.onTap,
  });

  final UserDevice device;
  final Producto? producto;
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: brand.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.devices_other,
                color: brand.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.nombre,
                    style: brand.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    producto?.nombre ?? 'Producto desconocido',
                    style: brand.caption,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: device.activo
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                device.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: device.activo ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceOptionsSheet extends StatefulWidget {
  const _DeviceOptionsSheet({
    required this.device,
    this.producto,
    required this.userDispService,
  });

  final UserDevice device;
  final Producto? producto;
  final UserDispService userDispService;

  @override
  State<_DeviceOptionsSheet> createState() => _DeviceOptionsSheetState();
}

class _DeviceOptionsSheetState extends State<_DeviceOptionsSheet> {
  bool _isLoading = false;

  Future<void> _handleDesvincular() async {
    setState(() => _isLoading = true);
    try {
      await widget.userDispService.updateDeviceStatus(widget.device.id, false);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispositivo desvinculado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleActivar() async {
    setState(() => _isLoading = true);
    try {
      await widget.userDispService.updateDeviceStatus(widget.device.id, true);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispositivo activado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleEliminar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${widget.device.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await widget.userDispService.deleteDevice(widget.device.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispositivo eliminado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    const brand = _Brand();
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.device.nombre,
            style: brand.h2,
          ),
          if (widget.producto != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.producto!.nombre,
              style: brand.caption,
            ),
          ],
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            if (widget.device.activo)
              _OptionButton(
                icon: Icons.link_off,
                label: 'Desvincular',
                color: Colors.orange,
                onTap: _handleDesvincular,
              )
            else
              _OptionButton(
                icon: Icons.link,
                label: 'Activar',
                color: Colors.green,
                onTap: _handleActivar,
              ),
            const SizedBox(height: 12),
            _OptionButton(
              icon: Icons.delete,
              label: 'Eliminar',
              color: Colors.red,
              onTap: _handleEliminar,
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
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
  TextStyle get h2 => const TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  TextStyle get body => const TextStyle(fontSize: 14, color: Colors.black87);
  TextStyle get caption => const TextStyle(fontSize: 12, color: Colors.black54);
}

