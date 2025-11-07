import 'package:flutter/material.dart';
import 'package:front/core/routes/app_routes.dart';

class DashboardSoloStatsScreen extends StatelessWidget {
  const DashboardSoloStatsScreen({super.key});

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
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: const [
            _StatCard(
              title: 'Ahorro aproximado en la factura de agua',
              child: _SavingsBarsMini(),
            ),
            SizedBox(height: 12),
            _StatCard(
              title: 'Último Consumo',
              trailing: _PeriodPill(text: 'Apr–Jun'),
              subtitleRight: Text(
                '- 25%',
                style: TextStyle(color: Colors.black54),
              ),
              child: _DonutLastConsumption(),
              footer: _LegendRow(
                items: [
                  _LegendItem('Sanitario', Color(0xFF20C06D)),
                  _LegendItem('Ducha', Color(0xFF3B7BFF)),
                  _LegendItem('Inodoro', Color(0xFF7B61FF)),
                ],
              ),
            ),
            SizedBox(height: 12),
            _StatCard(
              title: 'Gasto con bochica vs gasto normal',
              subtitleRight: Text(
                '- 10%',
                style: TextStyle(color: Colors.black54),
              ),
              child: _CompareBars(),
            ),
            SizedBox(height: 16),
            _CtaBanner(),
          ],
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
    this.subtitleRight,
    this.footer,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final Widget? subtitleRight;
  final Widget? footer;

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
          if (subtitleRight != null) ...[
            const SizedBox(height: 2),
            Row(children: [const Spacer(), subtitleRight!]),
          ],
          const SizedBox(height: 10),
          // contenido
          child,
          if (footer != null) ...[const SizedBox(height: 10), footer!],
        ],
      ),
    );
  }
}

/* =========================  CHART 1: AHORRO MINI  ========================= */

class _SavingsBarsMini extends StatelessWidget {
  const _SavingsBarsMini();

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
          child: CustomPaint(painter: _MiniBarsPainter()),
        ),
      ),
    );
  }
}

class _MiniBarsPainter extends CustomPainter {
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

    final prom = [50, 60, 58, 72, 65, 70];
    final hoy = [48, 55, 62, 68, 60, 66];

    final maxH = ([...prom, ...hoy].reduce((a, b) => a > b ? a : b)) * 1.1;

    for (var i = 0; i < months; i++) {
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

class _DonutLastConsumption extends StatelessWidget {
  const _DonutLastConsumption();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          _DonutPainterWidget(sanitary: 0.35, shower: 0.45, toilet: 0.20),
          Positioned(
            bottom: 6,
            right: 12,
            child: Text(
              'Distribución',
              style: TextStyle(color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainterWidget extends StatelessWidget {
  const _DonutPainterWidget({
    super.key,
    required this.sanitary,
    required this.shower,
    required this.toilet,
  });

  final double sanitary;
  final double shower;
  final double toilet;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(sanitary, shower, toilet),
      child: const SizedBox.expand(),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.a, this.b, this.c);
  final double a, b, c;

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
          colors: [Color(0xFF1AB56A), Color(0xFF37D07E)],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round,
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

    final vals = [a, b, c];
    double start = -90;

    for (var i = 0; i < vals.length; i++) {
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

    // texto central
    final tp = TextPainter(
      text: const TextSpan(
        text: '-25%',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  double _deg2rad(double d) => d * 3.1415926535 / 180.0;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.items});
  final List<_LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children:
          items
              .map(
                (e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: e.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.label,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              )
              .toList(),
    );
  }
}

class _LegendItem {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);
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

class _CompareBars extends StatelessWidget {
  const _CompareBars();

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
          child: CustomPaint(painter: _CompareBarsPainter()),
        ),
      ),
    );
  }
}

class _CompareBarsPainter extends CustomPainter {
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
    final normal = [90.0, 120.0, 150.0];
    final bochica = [80.0, 110.0, 135.0];

    final maxH =
        ([...normal, ...bochica].reduce((a, b) => a > b ? a : b)) * 1.1;

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
