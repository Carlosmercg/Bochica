import 'package:cloud_firestore/cloud_firestore.dart';

class ConsumoDiario {
  final DateTime fecha;
  final double consumoDucha;
  final double consumoInodoro;

  ConsumoDiario({
    required this.fecha,
    required this.consumoDucha,
    required this.consumoInodoro,
  });
}

class UserStatsRepository {
  final _col = FirebaseFirestore.instance.collection('UserStats');

  DateTime? _parseDateKey(String k) {
    try {
      // tus claves vienen como "2025-11-06"
      return DateTime.parse(k);
    } catch (_) {
      return null;
    }
  }

  /// Si [correo] viene, filtra por ese usuario; si no, trae todo (agrega todo el histórico).
  Stream<List<ConsumoDiario>> watchConsumos({String? correo}) {
    final Query<Map<String, dynamic>> q =
        correo == null ? _col : _col.where('correo', isEqualTo: correo);

    return q.snapshots().map((snap) {
      final out = <ConsumoDiario>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final consumos = data['consumosPorFecha'];
        if (consumos is Map) {
          consumos.forEach((key, val) {
            final fecha = _parseDateKey(key.toString());
            if (fecha != null && val is Map) {
              final ducha =
                  (val['consumoducha'] as num?)?.toDouble() ?? 0.0;
              final inodoro =
                  (val['consumoinodoro'] as num?)?.toDouble() ?? 0.0;
              out.add(ConsumoDiario(
                fecha: fecha,
                consumoDucha: ducha,
                consumoInodoro: inodoro,
              ));
            }
          });
        }
      }
      // más reciente primero
      out.sort((a, b) => b.fecha.compareTo(a.fecha));
      return out;
    });
  }
}
