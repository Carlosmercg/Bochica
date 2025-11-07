import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/routes/app_routes.dart';

class RegistroDispEstadosScreen extends StatelessWidget {
  const RegistroDispEstadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();

    // Datos mock (cámbialos luego por Firestore si quieres)
    final items = const [
      _Device(title: 'Baño Piso 1', kind: _Kind.sanitario, owner: 'inteligente', connected: true),
      _Device(title: 'Baño Piso 2', kind: _Kind.sanitario, owner: 'inteligente', connected: true),
      _Device(title: 'Ducha Pedro', kind: _Kind.ducha,     owner: 'inteligente', connected: true),
    ];

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
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _EstadoTile(
            device: items[i],
            onHistory: () {
              final correo = FirebaseAuth.instance.currentUser?.email;

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
                  'deviceTitle': items[i].title,
                  'kind': items[i].kind == _Kind.sanitario ? 'sanitario' : 'ducha',
                  'connected': items[i].connected,
                  'correo': correo, // 👈 se envía al historial
                },
              );
            },
          ),
        ),
      ),
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
  final Color bg = const Color(0xFFF5F1F6);
}
