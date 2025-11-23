import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_disp_service.dart';
import '../../tienda/services/products_repository.dart';

class RegistroDispEstadosScreen extends StatelessWidget {
  const RegistroDispEstadosScreen({super.key});

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
          backgroundColor: brand.bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text('Estado', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        body: const Center(
          child: Text('No hay sesión activa'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: brand.bg,
      appBar: AppBar(
        backgroundColor: brand.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Estado', style: TextStyle(fontWeight: FontWeight.w800)),
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
            final activeDevices = devices.where((d) => d.activo).toList();

            if (activeDevices.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No hay dispositivos vinculados'),
                ),
              );
            }

            return FutureBuilder(
              future: productsRepository.watchAll().first,
              builder: (context, productsSnapshot) {
                final productos = productsSnapshot.data ?? [];
                final productMap = {for (var p in productos) p.id: p};

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: activeDevices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final device = activeDevices[i];
                    final producto = productMap[device.tipoProducto];
                    final kind = producto?.nombre.toLowerCase().contains('sanitario') == true
                        ? _Kind.sanitario
                        : _Kind.ducha;

                    return _EstadoTile(
                      device: _Device(
                        title: device.nombre,
                        kind: kind,
                        owner: 'inteligente',
                        connected: device.activo,
                      ),
                      onHistory: () {
                        final correo = user.email;

                        if (correo == null || correo.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Inicia sesión para ver el historial')),
                          );
                          return;
                        }

                        Navigator.pushNamed(
                          context,
                          AppRoutes.estadosHistorial,
                          arguments: {
                            'deviceTitle': device.nombre,
                            'kind': kind == _Kind.sanitario ? 'sanitario' : 'ducha',
                            'connected': device.activo,
                            'correo': correo,
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 3,
        onTap: (i, ctx) => _handleNavigation(i, ctx),
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
        // Ya estamos en estado
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

/* ======= Model & UI ======= */

enum _Kind { sanitario, ducha }

class _Device {
  final String title;
  final _Kind kind;
  final String owner; // “inteligente”
  final bool connected;
  const _Device({
    required this.title,
    required this.kind,
    required this.owner,
    required this.connected,
  });
}

class _EstadoTile extends StatelessWidget {
  const _EstadoTile({required this.device, required this.onHistory});
  final _Device device;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    const blue     = Color(0xFF4F72FF);   // título (azul)
    const orange   = Color(0xFFEF6A3A);   // “sanitario inteligente”
    const lilacBkg = Color(0xFFEDE7FF);   // pill “Ver historial”
    const lilacTxt = Color(0xFF6A5AE0);   // texto del pill
    const dark     = Color(0xFF2B2B2B);   // círculo izquierdo

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          // círculo con estrella
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: dark, shape: BoxShape.circle),
            child: const Icon(Icons.star_border_rounded, color: Colors.white70, size: 22),
          ),
          const SizedBox(width: 12),

          // título en 2 líneas (azul / naranja)
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${device.title}\n',
                    style: const TextStyle(
                      color: blue, fontWeight: FontWeight.w800, fontSize: 15, height: 1.1),
                  ),
                  TextSpan(
                    text: '${device.kind == _Kind.sanitario ? 'sanitario' : 'ducha'}\n',
                    style: const TextStyle(
                      color: orange, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, fontSize: 13, height: 1.1),
                  ),
                  const TextSpan(
                    text: 'inteligente',
                    style: TextStyle(
                      color: orange, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, fontSize: 13, height: 1.1),
                  ),
                ],
              ),
            ),
          ),

          // check + “Conectado”
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                device.connected ? Icons.check_rounded : Icons.close_rounded,
                color: Colors.black,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                device.connected ? 'Conectado' : 'Desconectado',
                style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // botón “Ver historial”
          _PillButton(
            label: 'Ver Historial',
            background: lilacBkg,
            foreground: lilacTxt,
            onTap: onHistory,
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    required this.background,
    required this.foreground,
  });

  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}

class _Brand {
  const _Brand();
  final Color bg = const Color(0xFFF5F6FA);
}
