import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/core/routes/app_routes.dart';
import 'package:front/core/services/auth_service.dart';
import 'package:front/core/services/user_stats_service.dart';

class DashboardSoloStatsScreen extends StatefulWidget {
  const DashboardSoloStatsScreen({super.key});

  @override
  State<DashboardSoloStatsScreen> createState() => _DashboardSoloStatsScreenState();
}

class _DashboardSoloStatsScreenState extends State<DashboardSoloStatsScreen> {
  int _refreshId = 0;

  Future<void> _handleRefresh() async {
    setState(() {
      _refreshId++;
    });
    // Give the UI a moment to rebuild before completing the refresh indicator
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

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
        title: RichText(
          text: TextSpan(
            style: brand.title,
            children: const [
              TextSpan(text: 'Estadísticas '),
              TextSpan(
                text: 'Premium',
                style: TextStyle(color: Color(0xFFE24D5C)),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _handleRefresh();
            },
            tooltip: 'Actualizar estadísticas',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            final user = authService.currentUser;
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (user != null) ...[
                    _StatCard(
                      title: 'Ahorro aproximado en la factura de agua',
                      child: _SavingsBarsMini(
                        key: ValueKey('savings-${user.uid}-$_refreshId'),
                        userId: user.uid,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: 'Último Consumo',
                      trailing: const _PeriodPill(text: 'Total'),
                      child: _DonutLastConsumption(
                        key: ValueKey('donut-${user.uid}-$_refreshId'),
                        userId: user.uid,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: 'Gasto con bochica vs gasto normal',
                      child: _CompareBars(
                        key: ValueKey('compare-${user.uid}-$_refreshId'),
                        userId: user.uid,
                      ),
                    ),
                  ] else ...[
                    const _StatCard(
                      title: 'Ahorro aproximado en la factura de agua',
                      child: _SavingsBarsMini(),
                    ),
                    const SizedBox(height: 12),
                    const _StatCard(
                      title: 'Último Consumo',
                      trailing: _PeriodPill(text: 'Total'),
                      child: _DonutLastConsumption(),
                    ),
                    const SizedBox(height: 12),
                    const _StatCard(
                      title: 'Gasto con bochica vs gasto normal',
                      child: _CompareBars(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _CtaBanner(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/* =========================  CARD GENÉRICO  ========================= */

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    const brand = _Brand();
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
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // encabezado
          Row(
            children: [
              Expanded(child: Text(title, style: brand.cardTitle)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          // contenido
          child,
        ],
      ),
    );
  }
}

/* =========================  CHART 1: AHORRO MINI  ========================= */

class _SavingsBarsMini extends StatefulWidget {
  const _SavingsBarsMini({super.key, this.userId});
  final String? userId;

  @override
  State<_SavingsBarsMini> createState() => _SavingsBarsMiniState();
}

class _SavingsBarsMiniState extends State<_SavingsBarsMini> {
  final UserStatsService _userStatsService = UserStatsService();
  List<double> prom = [];
  List<double> hoy = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      // Obtener las últimas 6 fechas con consumo
      final fechas = await _userStatsService.getFechasConConsumo(widget.userId!);
      final fechasParaGrafico = fechas.take(6).toList();
      
      // Si hay menos de 6 fechas, rellenar con ceros
      while (fechasParaGrafico.length < 6) {
        fechasParaGrafico.add('');
      }

      List<double> promedios = [];
      List<double> hoyValues = [];

      // Calcular promedio de todas las fechas
      double totalPromedio = 0.0;
      int diasConDatos = 0;
      
      for (final fecha in fechas) {
        final consumos = await _userStatsService.getConsumosPorFecha(widget.userId!, fecha);
        final total = (consumos['consumoducha'] ?? 0.0) + (consumos['consumoinodoro'] ?? 0.0);
        totalPromedio += total;
        diasConDatos++;
      }
      
      final promedioGeneral = diasConDatos > 0 ? totalPromedio / diasConDatos : 0.0;

      // Para cada fecha en el gráfico
      for (var i = 0; i < 6; i++) {
        if (i < fechasParaGrafico.length && fechasParaGrafico[i].isNotEmpty) {
          final consumos = await _userStatsService.getConsumosPorFecha(
            widget.userId!, 
            fechasParaGrafico[i]
          );
          final totalHoy = (consumos['consumoducha'] ?? 0.0) + (consumos['consumoinodoro'] ?? 0.0);
          hoyValues.add(totalHoy);
          promedios.add(promedioGeneral);
        } else {
          hoyValues.add(0.0);
          promedios.add(promedioGeneral);
        }
      }

      if (mounted) {
        setState(() {
          prom = promedios;
          hoy = hoyValues;
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
    return SizedBox(
      width: double.infinity,
      height: 140,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: brand.chartBg,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomPaint(painter: _MiniBarsPainter(prom: prom, hoy: hoy)),
        ),
      ),
    );
  }
}

class _MiniBarsPainter extends CustomPainter {
  _MiniBarsPainter({required this.prom, required this.hoy});
  final List<double> prom;
  final List<double> hoy;

  final _grid =
      Paint()
        ..color = Colors.white.withOpacity(.08)
        ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    // margen interno
    const insets = EdgeInsets.fromLTRB(16, 10, 16, 16);
    final rect = Rect.fromLTWH(
      insets.left,
      insets.top,
      size.width - insets.horizontal,
      size.height - insets.vertical,
    );

    // grid
    for (var i = 1; i <= 3; i++) {
      final y = rect.top + rect.height * i / 4;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), _grid);
    }

    // 6 pares (Promedio, Hoy)
    final months = 6;
    final barW = 10.0;
    const innerGap = 4.0; // gap dentro del par
    final pairW = barW * 2 + innerGap;

    final totalPairsW = months * pairW;
    final freeW = (rect.width - totalPairsW).clamp(0, rect.width);
    final pairGap = months > 1 ? freeW / (months - 1) : 0;

    final purple = const LinearGradient(
      colors: [Color(0xFF6A5AE0), Color(0xFF8E84F2)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    final green = const LinearGradient(
      colors: [Color(0xFF1AA65A), Color(0xFF3AD07E)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    final allValues = [...prom, ...hoy];
    final maxH = allValues.isEmpty 
        ? 100.0 
        : (allValues.reduce((a, b) => a > b ? a : b)) * 1.1;
    
    if (maxH == 0) return; // No hay datos para mostrar

    for (var i = 0; i < months && i < prom.length && i < hoy.length; i++) {
      final x0 = rect.left + i * (pairW + pairGap);
      final hP = (prom[i] / maxH) * rect.height;
      final hH = (hoy[i] / maxH) * rect.height;

      final rP = Rect.fromLTWH(x0, rect.bottom - hP, barW, hP);
      final rH = Rect.fromLTWH(
        x0 + barW + innerGap,
        rect.bottom - hH,
        barW,
        hH,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rP, const Radius.circular(6)),
        Paint()..shader = purple.createShader(rP),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rH, const Radius.circular(6)),
        Paint()..shader = green.createShader(rH),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* =========================  CHART 2: DONUT  ========================= */

class _DonutLastConsumption extends StatefulWidget {
  const _DonutLastConsumption({super.key, this.userId});
  final String? userId;

  @override
  State<_DonutLastConsumption> createState() => _DonutLastConsumptionState();
}

class _DonutLastConsumptionState extends State<_DonutLastConsumption> {
  final UserStatsService _userStatsService = UserStatsService();
  double ducha = 0.0;
  double inodoro = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final consumos = await _userStatsService.getConsumosTotales(widget.userId!);
      if (mounted) {
        setState(() {
          ducha = consumos['consumoducha'] ?? 0.0;
          inodoro = consumos['consumoinodoro'] ?? 0.0;
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
    if (isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final totalLiters = ducha + inodoro;
    final duchaPercent = totalLiters > 0 ? ducha / totalLiters : 0.0;
    final inodoroPercent = totalLiters > 0 ? inodoro / totalLiters : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _DonutPainterWidget(
                showerPercent: duchaPercent,
                toiletPercent: inodoroPercent,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${totalLiters.toStringAsFixed(1)} L',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total consumido',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _LegendValue(
              color: const Color(0xFF3B7BFF),
              label: 'Ducha',
              liters: ducha,
              percent: duchaPercent,
            ),
            _LegendValue(
              color: const Color(0xFF7B61FF),
              label: 'Inodoro',
              liters: inodoro,
              percent: inodoroPercent,
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutPainterWidget extends StatelessWidget {
  const _DonutPainterWidget({
    required this.showerPercent,
    required this.toiletPercent,
  });

  final double showerPercent;
  final double toiletPercent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(showerPercent, toiletPercent),
      child: const SizedBox.expand(),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.showerPercent, this.toiletPercent);
  final double showerPercent;
  final double toiletPercent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide * .34;

    final bg =
        Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round;

    // base
    canvas.drawCircle(center, radius, bg);

    final paints = [
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF3B7BFF), Color(0xFF6AA0FF)],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFFA18BFF)],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round,
    ];

    final vals = [showerPercent, toiletPercent];
    double start = -90;

    for (var i = 0; i < vals.length; i++) {
      if (vals[i] > 0) {
        final sweep = vals[i] * 360;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          _deg2rad(start),
          _deg2rad(sweep),
          false,
          paints[i],
        );
        start += sweep;
      }
    }

  }

  double _deg2rad(double d) => d * 3.1415926535 / 180.0;

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.showerPercent != showerPercent ||
      oldDelegate.toiletPercent != toiletPercent;
}

class _LegendValue extends StatelessWidget {
  const _LegendValue({
    required this.color,
    required this.label,
    required this.liters,
    required this.percent,
  });

  final Color color;
  final String label;
  final double liters;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final percentDisplay = percent.isFinite
        ? percent <= 0
            ? '0'
            : (percent * 100).toStringAsFixed(percent * 100 < 1 ? 1 : 0)
        : '0';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label · ${liters.toStringAsFixed(1)} L ($percentDisplay%)',
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black87)),
    );
  }
}

/* =========================  CHART 3: COMPARATIVA  ========================= */

class _CompareBars extends StatefulWidget {
  const _CompareBars({super.key, this.userId});
  final String? userId;

  @override
  State<_CompareBars> createState() => _CompareBarsState();
}

class _CompareBarsState extends State<_CompareBars> {
  final UserStatsService _userStatsService = UserStatsService();
  List<double> normal = [90.0, 120.0, 150.0];
  List<double> bochica = [0.0, 0.0, 0.0];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      // Obtener consumos totales
      final consumos = await _userStatsService.getConsumosTotales(widget.userId!);
      final totalBochica = (consumos['consumoducha'] ?? 0.0) + (consumos['consumoinodoro'] ?? 0.0);
      
      // Calcular promedios diarios (asumiendo que hay datos de varios días)
      final fechas = await _userStatsService.getFechasConConsumo(widget.userId!);
      final diasConDatos = fechas.length;
      
      final promedioDiario = diasConDatos > 0 ? totalBochica / diasConDatos : 0.0;
      
      // Normalizar a los niveles básico, promedio, alta
      // Básico: 0-100, Promedio: 100-150, Alta: 150+
      final basico = promedioDiario < 100 ? promedioDiario : 0.0;
      final promedio = promedioDiario >= 100 && promedioDiario < 150 
          ? promedioDiario 
          : (promedioDiario >= 150 ? 0.0 : 0.0);
      final alta = promedioDiario >= 150 ? promedioDiario : 0.0;

      if (mounted) {
        setState(() {
          bochica = [basico, promedio, alta];
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
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: brand.chartBg,
          child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : CustomPaint(painter: _CompareBarsPainter(normal: normal, bochica: bochica)),
        ),
      ),
    );
  }
}

class _CompareBarsPainter extends CustomPainter {
  _CompareBarsPainter({required this.normal, required this.bochica});
  final List<double> normal;
  final List<double> bochica;

  final _grid =
      Paint()
        ..color = Colors.white.withOpacity(.08)
        ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    const insets = EdgeInsets.fromLTRB(16, 12, 16, 18);
    final rect = Rect.fromLTWH(
      insets.left,
      insets.top,
      size.width - insets.horizontal,
      size.height - insets.vertical,
    );

    // grid
    for (var i = 1; i <= 3; i++) {
      final y = rect.top + rect.height * i / 4;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), _grid);
    }

    final purple = const LinearGradient(
      colors: [Color(0xFF6A5AE0), Color(0xFF8E84F2)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    final green = const LinearGradient(
      colors: [Color(0xFF1AA65A), Color(0xFF3AD07E)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    final labels = ['Básico', 'Promedio', 'Alta'];

    final allValues = [...normal, ...bochica];
    final maxH = allValues.isEmpty 
        ? 150.0 
        : (allValues.reduce((a, b) => a > b ? a : b)) * 1.1;

    final groups = labels.length;
    final barW = 18.0;
    const innerGap = 8.0;
    final groupW = barW * 2 + innerGap;
    final freeW = rect.width - groups * groupW;
    final groupGap = groups > 1 ? freeW / (groups - 1) : 0;

    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < groups; i++) {
      final x0 = rect.left + i * (groupW + groupGap);

      final hN = (normal[i] / maxH) * rect.height;
      final hB = (bochica[i] / maxH) * rect.height;

      final rN = Rect.fromLTWH(x0, rect.bottom - hN, barW, hN);
      final rB = Rect.fromLTWH(
        x0 + barW + innerGap,
        rect.bottom - hB,
        barW,
        hB,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rN, const Radius.circular(8)),
        Paint()..shader = purple.createShader(rN),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rB, const Radius.circular(8)),
        Paint()..shader = green.createShader(rB),
      );

      // etiqueta bajo el grupo
      tp.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      );
      tp.layout();
      final groupCenter = x0 + groupW / 2;
      tp.paint(canvas, Offset(groupCenter - tp.width / 2, rect.bottom + 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* =========================  CTA  ========================= */

class _CtaBanner extends StatelessWidget {
  const _CtaBanner();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pushNamed(context, AppRoutes.chatbotRecomendaciones),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            children: const [
              TextSpan(text: '¡Ingresa a tu estrategia '),
              TextSpan(
                text: 'inteligente!',
                style: TextStyle(color: Color(0xFFE24D5C)),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/* =========================  ESTILOS  ========================= */

class _Brand {
  const _Brand();
  final Color bg = const Color(0xFFF5F6FA);
  final Color chartBg = const Color(0xFF2B2B2E);

  TextStyle get title => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.black87,
  );

  TextStyle get cardTitle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );
}
