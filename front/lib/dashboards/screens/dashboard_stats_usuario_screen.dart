import 'package:flutter/material.dart';

class DashboardStatsUsuarioScreen extends StatelessWidget {
  const DashboardStatsUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();

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
        title: const Text(
          'Estado',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: const [
            _DeviceCard(
              title: 'Baño Piso 1',
              kind: _DeviceKind.sanitario,
              owner: 'inteligente',
              connected: true,
            ),
            SizedBox(height: 10),
            _DeviceCard(
              title: 'Baño Piso 2',
              kind: _DeviceKind.sanitario,
              owner: 'inteligente',
              connected: true,
            ),
            SizedBox(height: 10),
            _DeviceCard(
              title: 'Ducha Pedro',
              kind: _DeviceKind.ducha,
              owner: 'inteligente',
              connected: true,
            ),
          ],
        ),
      ),
      // Bottom (si ya tienes uno global, quítalo aquí)
      bottomNavigationBar: const _BottomStub(),
    );
  }
}

/* ====================== ITEM DISPOSITIVO ====================== */

enum _DeviceKind { sanitario, ducha }

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.title,
    required this.kind,
    required this.owner,
    required this.connected,
  });

  final String title;
  final _DeviceKind kind;
  final String owner;
  final bool connected;

  Color get _accent =>
      kind == _DeviceKind.sanitario
          ? const Color(0xFF7B61FF)
          : const Color(0xFF3B7BFF);

  String get _kindLabel =>
      kind == _DeviceKind.sanitario ? 'sanitario' : 'ducha';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Stripe lateral con icono favorito
          Container(
            width: 54,
            height: 92,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.85),
                  Colors.black.withOpacity(.65),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.star_border_rounded,
                color: Colors.white70,
                size: 26,
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + badges
                  Row(
                    children: [
                      Expanded(
                        child: _TitleWithBadges(
                          title: title,
                          kindLabel: _kindLabel,
                          accent: _accent,
                          owner: owner,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusPill(connected: connected),
                      const SizedBox(width: 8),
                      _GhostButton(text: 'Ver historial', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleWithBadges extends StatelessWidget {
  const _TitleWithBadges({
    required this.title,
    required this.kindLabel,
    required this.accent,
    required this.owner,
  });

  final String title;
  final String kindLabel;
  final Color accent;
  final String owner;

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: Colors.black87,
      height: 1.1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(title, style: titleStyle),
        const SizedBox(height: 2),
        // “sanitario/ducha” + “inteligente” con acentos
        Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ChipText(text: kindLabel, color: accent),
            _ChipText(text: owner, color: const Color(0xFFE24D5C)),
          ],
        ),
      ],
    );
  }
}

/* ====================== COMPONENTES UI ====================== */

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
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
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
    final icon = connected ? Icons.check_rounded : Icons.close_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),

        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6A5AE0).withOpacity(.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6A5AE0).withOpacity(.35)),
        ),
        child: const Text(
          'Ver historial',
          style: TextStyle(
            color: Color(0xFF6A5AE0),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/* ====================== BOTTOM (placeholder) ====================== */

class _BottomStub extends StatelessWidget {
  const _BottomStub();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 2, // “Vincular/Estado” según tu app
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          label: 'Configurar',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          label: 'Vincular',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          label: 'Estado',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }
}

/* ====================== ESTILOS BASE ====================== */

class _Brand {
  const _Brand();
  final Color bg = const Color(0xFFF5F6FA);
}
