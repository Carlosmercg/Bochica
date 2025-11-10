import 'package:flutter/material.dart';

class ChatbotRecomendacionesScreen extends StatelessWidget {
  const ChatbotRecomendacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Recomendaciones de consumo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Encabezado estilo “Tu estrategia de ahorro”
          Text(
            'Tu estrategia de ahorro',
            style: text.titleSmall?.copyWith(color: cs.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Basado en tu consumo histórico,',
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Bloque de “tendencias” (placeholder gráfico)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_graph),
                    const SizedBox(width: 8),
                    Text('Tendencias de consumo', style: text.titleMedium),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('+25%', style: text.labelLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Barras dummy (placeholder)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    _Bar(h: 24), SizedBox(width: 10),
                    _Bar(h: 46), SizedBox(width: 10),
                    _Bar(h: 30), SizedBox(width: 10),
                    _Bar(h: 70), SizedBox(width: 10),
                    _Bar(h: 38), SizedBox(width: 10),
                    _Bar(h: 90),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tarjeta de recomendaciones
          Card(
            elevation: 0,
            color: cs.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bullet(
                    textSpans: [
                      const TextSpan(text: 'Bochica ' , style: TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: 'ajustó tu '),
                      const TextSpan(text: 'meta de ahorro ', style: TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: 'en un 5%.'),
                    ],
                  ),
                  _Bullet(
                    textSpans: [
                      const TextSpan(text: 'El '),
                      const TextSpan(text: 'modo de ahorro ', style: TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: 'se activará después de las 8 pm.'),
                    ],
                  ),
                  _Bullet(
                    textSpans: [
                      const TextSpan(text: 'Tu '),
                      const TextSpan(text: 'ducha matutina ', style: TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: 'de 10 min costó 15L. ¿Quieres reducirla mañana?'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Simulación de ahorro en proceso…')),
                        );
                      },
                      child: const Text('> simula tu ahorro'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // (Opcional) Siguientes pasos
          Card(
            elevation: 0,
            color: cs.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Programa el modo ahorro a las 8:00 pm'),
              subtitle: const Text('Ahorro automático en horas pico'),
              trailing: FilledButton.tonal(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Modo ahorro programado')),
                  );
                },
                child: const Text('Activar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double h;
  const _Bar({required this.h});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final List<TextSpan> textSpans;
  const _Bullet({required this.textSpans});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(TextSpan(children: textSpans)),
          ),
        ],
      ),
    );
  }
}
