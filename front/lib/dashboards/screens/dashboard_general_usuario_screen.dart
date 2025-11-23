import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/core/routes/app_routes.dart';
import 'package:front/core/services/auth_service.dart';
import 'package:front/core/services/user_stats_service.dart';

class DashboardGeneralUsuarioScreen extends StatefulWidget {
  const DashboardGeneralUsuarioScreen({super.key});

  @override
  State<DashboardGeneralUsuarioScreen> createState() => _DashboardGeneralUsuarioScreenState();
}

class _DashboardGeneralUsuarioScreenState extends State<DashboardGeneralUsuarioScreen> {
  int _refreshId = 0;

  Future<void> _handleRefresh() async {
    setState(() {
      _refreshId++;
    });
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    const brand = _Brand(); // colores y estilos base
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    // Obtener el nombre del usuario: displayName, o primera parte del email, o "Usuario"
    String nombreUsuario = 'Usuario';
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        nombreUsuario = user.displayName!;
      } else if (user.email != null && user.email!.isNotEmpty) {
        // Si no tiene displayName, usar la parte antes del @ del email
        final emailPart = user.email!.split('@').first;
        if (emailPart.isNotEmpty) {
          // Capitalizar la primera letra
          nombreUsuario = emailPart[0].toUpperCase() +
              (emailPart.length > 1 ? emailPart.substring(1) : '');
        }
      }
    }

    return Scaffold(
      backgroundColor: brand.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _Header(nombre: nombreUsuario),
              const SizedBox(height: 12),
              if (user != null)
                _SavingsCard(
                  key: ValueKey('savings-${user.uid}-$_refreshId'),
                  userId: user.uid,
                )
              else
                const SizedBox(),
              const SizedBox(height: 12),
              if (user != null)
                _BarsCard(
                  key: ValueKey('bars-${user.uid}-$_refreshId'),
                  userId: user.uid,
                )
              else
                const SizedBox(),
              const SizedBox(height: 12),
              const _ShowerGoalCard(),
              const SizedBox(height: 12),
              const _TipOfDayCard(),
              const SizedBox(height: 24),
              if (user != null)
                ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<AuthService>().signOut();
                    if (!mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.authWelcome,
                      (route) => false,
                    );
                  },
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
                )
              else
                const SizedBox(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // Barra inferior (tabs)
      bottomNavigationBar: _BottomNav(
        currentIndex: 0, // 0 = Inicio
        onTap: (i, ctx) {
          // TODO: reemplaza por tus rutas reales si ya existen
          switch (i) {
            case 0:
              final currentRoute = ModalRoute.of(ctx)?.settings.name;
              if (currentRoute != AppRoutes.dashboardGeneralUsuario) {
                Navigator.pushNamedAndRemoveUntil(
                  ctx,
                  AppRoutes.dashboardGeneralUsuario,
                  (route) => false,
                );
              }
              break;
            case 1:
              Navigator.pushNamed(ctx, AppRoutes.dashboardConfigurar);
              break;
            case 2:
              Navigator.pushNamed(ctx, AppRoutes.dashboardVincular);
              break;
            case 3: /* Navigator.pushNamed(ctx, AppRoutes.estado);     */
              Navigator.pushNamed(ctx, AppRoutes.estados);
              break;
            case 4:
              Navigator.pushNamed(ctx, AppRoutes.dashboardPerfil);
              break;
          }
        },
      ),
    );
  }
}

/* =====================  SECCIONES  ===================== */

class _Header extends StatelessWidget {
  const _Header({required this.nombre});
  final String nombre;

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¡Hola,', style: brand.h1),
              RichText(
                text: TextSpan(
                  style: brand.h1,
                  children: [
                    TextSpan(
                      text: '$nombre',
                      style: brand.h1.copyWith(color: brand.primary),
                    ),
                    const TextSpan(text: '!'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Botón chat
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.chatbot),
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: 'Chat',
        ),
        // "Escudo" Bochica (placeholder)
        const _BadgeBochica(),
      ],
    );
  }
}

class _SavingsCard extends StatefulWidget {
  const _SavingsCard({super.key, required this.userId});
  final String userId;

  @override
  State<_SavingsCard> createState() => _SavingsCardState();
}

class _SavingsCardState extends State<_SavingsCard> {
  final UserStatsService _userStatsService = UserStatsService();
  double consumoHoy = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsumoHoy();
  }

  Future<void> _loadConsumoHoy() async {
    try {
      final consumos = await _userStatsService.getConsumosHoy(widget.userId);
      final totalHoy = (consumos['consumoducha'] ?? 0.0) + (consumos['consumoinodoro'] ?? 0.0);
      
      if (mounted) {
        setState(() {
          consumoHoy = totalHoy;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder de línea (gráfico)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: brand.chartBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const _LineChartPlaceholder(),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: brand.body,
                    children: [
                      const TextSpan(text: 'Hoy has consumido '),
                      TextSpan(
                        text: isLoading 
                            ? '...' 
                            : '${consumoHoy.toStringAsFixed(1)} litros',
                        style: brand.body.copyWith(
                          color: brand.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' de agua con Bochica'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.dashboardSoloStats);
                },
                child: Text('⋙ ver más', style: brand.link),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarsCard extends StatefulWidget {
  const _BarsCard({super.key, required this.userId});
  final String userId;

  @override
  State<_BarsCard> createState() => _BarsCardState();
}

class _BarsCardState extends State<_BarsCard> {
  final UserStatsService _userStatsService = UserStatsService();
  List<_GroupData> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Obtener consumos de hoy
      final consumosHoy = await _userStatsService.getConsumosHoy(widget.userId);
      final duchaHoy = consumosHoy['consumoducha'] ?? 0.0;
      final inodoroHoy = consumosHoy['consumoinodoro'] ?? 0.0;

      // Obtener todas las fechas para calcular promedios
      final fechas = await _userStatsService.getFechasConConsumo(widget.userId);
      
      double totalDucha = 0.0;
      double totalInodoro = 0.0;
      int diasConDatos = 0;

      // Calcular promedios basados en los últimos 7 días o todos los días disponibles
      final fechasParaPromedio = fechas.take(7).toList();
      
      for (final fecha in fechasParaPromedio) {
        final consumos = await _userStatsService.getConsumosPorFecha(widget.userId, fecha);
        totalDucha += consumos['consumoducha'] ?? 0.0;
        totalInodoro += consumos['consumoinodoro'] ?? 0.0;
        diasConDatos++;
      }

      final promedioDucha = diasConDatos > 0 ? totalDucha / diasConDatos : duchaHoy;
      final promedioInodoro = diasConDatos > 0 ? totalInodoro / diasConDatos : inodoroHoy;

      if (mounted) {
        setState(() {
          data = [
            _GroupData(
              title: 'Ducha',
              promedio: promedioDucha,
              hoy: duchaHoy,
            ),
            _GroupData(
              title: 'Inodoro',
              promedio: promedioInodoro,
              hoy: inodoroHoy,
            ),
          ];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();

    if (isLoading) {
      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: brand.chartBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: brand.chartBg,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: data.isEmpty 
                ? const Center(child: Text('No hay datos disponibles'))
                : _GroupedBarsChart(data: data),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendDot(color: Colors.deepPurple, label: 'Promedio'),
              const SizedBox(width: 12),
              _LegendDot(color: Colors.green, label: 'Hoy'),
              const Spacer(),
              Text('Comparativo por actividad', style: brand.caption),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.estados,
            ),
            child: Text('> consulta tu ecosistema', style: brand.link),
          ),
        ],
      ),
    );
  }
}

class _ShowerGoalCard extends StatefulWidget {
  const _ShowerGoalCard();

  @override
  State<_ShowerGoalCard> createState() => _ShowerGoalCardState();
}

class _ShowerGoalCardState extends State<_ShowerGoalCard> {
  bool enabled = true;
  late final TapGestureRecognizer _ecoRecognizer;

  @override
  void initState() {
    super.initState();
    _ecoRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushNamed(context, AppRoutes.estados);
      };
  }

  @override
  void dispose() {
    _ecoRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();
    return _Card(
      child: Row(
        children: [
          Switch(value: enabled, onChanged: (v) => setState(() => enabled = v)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: brand.body,
                children: [
                  TextSpan(
                    text: enabled ? 'Sí ' : 'No ',
                    style: brand.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: 'quiere 15% menos en la ducha '),
                  TextSpan(
                    text: '→ Ajusta tu ecosistema',
                    style: brand.link,
                    recognizer: _ecoRecognizer,
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

class _TipOfDayCard extends StatelessWidget {
  const _TipOfDayCard();

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.wb_sunny_outlined),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip del día: Cierra el grifo mientras lavas los platos',
              style: brand.body,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.tiendaHome),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: const Text('TIENDA'),
          ),
        ],
      ),
    );
  }
}

/* =====================  WIDGETS DE SOPORTE  ===================== */

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

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class _BadgeBochica extends StatelessWidget {
  const _BadgeBochica();

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: brand.primary.withOpacity(.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brand.primary.withOpacity(.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop, color: brand.primary, size: 18),
          const SizedBox(width: 6),
          Text(
            'BOCHICA',
            style: TextStyle(color: brand.primary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _GroupData {
  final String title;
  final double promedio;
  final double hoy; // consumo de hoy
  const _GroupData({
    required this.title,
    required this.promedio,
    required this.hoy,
  });
}

class _GroupedBarsChart extends StatelessWidget {
  const _GroupedBarsChart({required this.data});
  final List<_GroupData> data;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GroupedBarsPainter(data),
      child: const SizedBox.expand(),
    );
  }
}

class _GroupedBarsPainter extends CustomPainter {
  _GroupedBarsPainter(this.data);
  final List<_GroupData> data;

  // estilos
  final _gridPaint =
      Paint()
        ..color = Colors.white.withOpacity(.08)
        ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = const Radius.circular(12);
    // fondo ya viene por el Container; dibujamos grid
    _drawGrid(canvas, size);

    if (data.isEmpty) return;

    // Cálculo de alturas
    final maxValue =
        (data
            .map((g) => [g.promedio, g.hoy])
            .expand((e) => e)
            .reduce((a, b) => a > b ? a : b)) *
        1.2; // padding arriba

    final chartBottom = size.height - 40; // espacio para labels “Promedio/Hoy”
    final chartTop = 8.0;
    final chartHeight = chartBottom - chartTop;

    // Layout horizontal
    final groupCount = data.length;
    final groupGap = 26.0;
    final barWidth = 26.0;
    final barsPerGroup = 2;
    final groupWidth =
        barsPerGroup * barWidth + groupGap; // ancho visual de cada grupo
    final totalWidth = groupCount * groupWidth + (groupCount - 1) * groupGap;

    final startX = (size.width - totalWidth) / 2;

    final labelPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < data.length; i++) {
      final g = data[i];
      final gx = startX + i * (groupWidth + groupGap);

      // ---- Barra Promedio (morado)
      final hProm = (g.promedio / maxValue) * chartHeight;
      final promRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(gx, chartBottom - hProm, barWidth, hProm),
        radius,
      );

      final promGradient =
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF5B4ED8), Color(0xFF7E73F0)],
            ).createShader(promRect.outerRect);
      canvas.drawRRect(promRect, promGradient);

      // ---- Barra Hoy (verde)
      final hx = gx + barWidth + 14; // pequeño gap entre barras del grupo
      final hHoy = (g.hoy / maxValue) * chartHeight;
      final hoyRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(hx, chartBottom - hHoy, barWidth, hHoy),
        radius,
      );
      final hoyGradient =
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF1A9B4B), Color(0xFF35D07F)],
            ).createShader(hoyRect.outerRect);
      canvas.drawRRect(hoyRect, hoyGradient);

      // Sombra sutil
      final shadow = Paint()..color = Colors.black.withOpacity(.20);
      canvas.drawRRect(
        hoyRect.shift(const Offset(0, 2)),
        shadow..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // ---- Labels bajo cada barra
      _drawSmallLabel(
        canvas,
        labelPainter,
        'Promedio',
        Offset(gx + barWidth / 2, chartBottom + 16),
      );
      _drawSmallLabel(
        canvas,
        labelPainter,
        'Hoy',
        Offset(hx + barWidth / 2, chartBottom + 16),
      );

      // ---- Título del grupo (Sanitario/Ducha)
      _drawSmallLabel(
        canvas,
        labelPainter,
        g.title,
        Offset(gx + (hoyRect.right - gx) / 2, chartBottom + 34),
        color: Colors.white70,
      );

      // ---- Pill de porcentaje ahorro sobre la barra HOY
      final ahorroPct = _calcAhorroPct(g.promedio, g.hoy);
      final pill = _buildPillText(ahorroPct);
      final pillPos = Offset(hx + barWidth / 2, chartBottom - hHoy - 12);
      _drawPill(
        canvas,
        pill,
        pillPos,
        bg: ahorroPct >= 0 ? const Color(0xFF2AC26D) : const Color(0xFFE84D6E),
      );
    }
  }

  // % ahorro (positivo si hoy < promedio)
  int _calcAhorroPct(double promedio, double hoy) {
    if (promedio <= 0) return 0;
    final diff = (promedio - hoy) / promedio;
    return (diff * 100).round();
  }

  void _drawGrid(Canvas canvas, Size size) {
    const rows = 4;
    final dy = size.height / (rows + 1);
    for (var i = 1; i <= rows; i++) {
      final y = dy * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }
  }

  void _drawSmallLabel(
    Canvas canvas,
    TextPainter tp,
    String text,
    Offset center, {
    Color color = Colors.white70,
  }) {
    tp.text = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 12),
    );
    tp.layout();
    final off = Offset(center.dx - tp.width / 2, center.dy - tp.height / 2);
    tp.paint(canvas, off);
  }

  TextPainter _buildPillText(int pct) {
    final sign = pct > 0 ? '+' : '';
    final text = '$sign$pct%';
    return TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    )..layout();
  }

  void _drawPill(
    Canvas canvas,
    TextPainter tp,
    Offset center, {
    required Color bg,
  }) {
    final padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3);
    final rect = Rect.fromCenter(
      center: center,
      width: tp.width + padding.horizontal,
      height: tp.height + padding.vertical,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    final paint = Paint()..color = bg.withOpacity(.92);
    canvas.drawRRect(rrect, paint);
    tp.paint(canvas, Offset(rect.left + padding.left, rect.top + padding.top));
  }

  @override
  bool shouldRepaint(covariant _GroupedBarsPainter oldDelegate) =>
      oldDelegate.data != data;
}

/* ====== Placeholders de “gráficos” (puro layout sin paquetes) ====== */

class _LineChartPlaceholder extends StatelessWidget {
  const _LineChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LinePainter(), child: const SizedBox.expand());
  }
}

/* =====================  ESTILOS / PINTURAS  ===================== */

class _Brand {
  const _Brand();

  final Color primary = const Color(0xFF6A5AE0); // morado
  final Color bg = const Color(0xFFF5F6FA);
  final Color chartBg = const Color(0xFF2B2B2E);

  TextStyle get h1 =>
      const TextStyle(fontSize: 32, fontWeight: FontWeight.w800);
  TextStyle get body => const TextStyle(fontSize: 14, color: Colors.black87);
  TextStyle get caption => const TextStyle(fontSize: 12, color: Colors.black54);
  TextStyle get link => const TextStyle(
    fontSize: 14,
    color: Color(0xFF6A5AE0),
    fontWeight: FontWeight.w700,
  );
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF2B2B2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      bgPaint,
    );

    final line =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(size.width * .05, size.height * .65),
      Offset(size.width * .20, size.height * .55),
      Offset(size.width * .35, size.height * .62),
      Offset(size.width * .55, size.height * .48),
      Offset(size.width * .70, size.height * .60),
      Offset(size.width * .85, size.height * .40),
    ];
    path.moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, line);

    // “punto” resaltado
    final highlight = points[points.length - 2];
    final fill = Paint()..color = const Color(0xFF6A5AE0);
    canvas.drawCircle(highlight, 6, fill);
    canvas.drawCircle(
      highlight,
      9,
      Paint()..color = Colors.white.withOpacity(.25),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
