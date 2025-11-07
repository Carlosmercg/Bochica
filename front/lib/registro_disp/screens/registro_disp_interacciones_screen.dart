import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/user_stats_repository.dart';

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
      backgroundColor: const Color(0xFFF5F1F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1F6),
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

              // Barra de buscar (sólo UI)
              Row(
                children: [
                  _GhostSquare(icon: Icons.tune_rounded, onTap: () {}),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

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
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Fecha')),
                            DataColumn(label: Text('Ducha (L)')),
                            DataColumn(label: Text('Inodoro (L)')),
                            DataColumn(label: Text('')),
                          ],
                          rows: rows
                              .map(
                                (e) => DataRow(
                                  cells: [
                                    DataCell(Text(df.format(e.fecha))),
                                    DataCell(Text('${e.consumoDucha}')),
                                    DataCell(Text('${e.consumoInodoro}')),
                                    const DataCell(Icon(Icons.remove_red_eye_outlined)),
                                  ],
                                ),
                              )
                              .toList(),
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
    );
  }
}

/* ====== Soporte UI (igual al mock) ====== */

class _GhostSquare extends StatelessWidget {
  const _GhostSquare({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Icon(icon),
      ),
    );
  }
}

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
