import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/user_stats_repository.dart';
import '../../core/routes/app_routes.dart';

class RegistroDispInteraccionesScreen extends StatelessWidget {
  const RegistroDispInteraccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final title     = (args['deviceTitle'] as String?) ?? 'Dispositivo';
    final kind      = (args['kind'] as String?) ?? 'sanitario';
    final connected = (args['connected'] as bool?) ?? true;
    final correo    = (args['correo'] as String?); // <— pásalo desde Estado si lo tienes

    final repo = UserStatsRepository();
    final df = DateFormat('dd/MM/yyyy'); // sólo fecha (tu dato no trae hora)

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Estado', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // Header con nombre + chips + estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star_border_rounded),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 6,
                          children: [
                            _ChipText(
                              text: kind,
                              color: kind == 'sanitario' ? const Color(0xFF7B61FF) : const Color(0xFF3B7BFF),
                            ),
                            const _ChipText(text: 'inteligente', color: Color(0xFFE24D5C)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(connected: connected),
                ],
              ),
              const SizedBox(height: 12),

              // Tabla con datos en vivo desde Firestore
              Expanded(
                child: StreamBuilder<List<ConsumoDiario>>(
                  stream: repo.watchConsumos(correo: correo),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          'Error cargando historial:\n${snap.error}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final rows = snap.data ?? const [];
                    if (rows.isEmpty) {
                      return const Center(child: Text('Sin registros.'));
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(label: Text('Fecha', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                              DataColumn(
                                label: Text('Ducha (L)', 
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text('Inodoro (L)', 
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                numeric: true,
                              ),
                            ],
                            rows: rows
                                .map(
                                  (e) => DataRow(
                                    cells: [
                                      DataCell(Text(df.format(e.fecha), style: const TextStyle(fontSize: 13))),
                                      DataCell(
                                        Text('${e.consumoDucha}', 
                                          style: const TextStyle(fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      DataCell(
                                        Text('${e.consumoInodoro}', 
                                          style: const TextStyle(fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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

/* ====== Soporte UI (igual al mock) ====== */

class _ChipText extends StatelessWidget {
  const _ChipText({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(.12),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700, height: 1)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.connected});
  final bool connected;
  @override
  Widget build(BuildContext context) {
    final color = connected ? const Color(0xFF20C06D) : const Color(0xFFE24D5C);
    final label = connected ? 'Conectado' : 'Desconectado';
    final icon  = connected ? Icons.check_rounded : Icons.close_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        border: Border.all(color: color.withOpacity(.4)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
    );
  }
}
