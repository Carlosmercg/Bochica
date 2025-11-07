import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

class ProductsRepository {
  final _col = FirebaseFirestore.instance.collection('productos').withConverter<Map<String, dynamic>>(
    fromFirestore: (snap, _) => (snap.data() ?? {}),
    toFirestore: (map, _) => map,
  );

  Stream<List<Producto>> watchAll() {
    final q = FirebaseFirestore.instance
        .collection('productos')
        .orderBy('nombre'); // <- ya no requiere índice compuesto

    return q.snapshots().map((s) {
      final list = s.docs
          .map((d) => Producto.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      return list.where((p) => p.activo).toList(); // filtro en memoria
    });
  }

  Future<Producto?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return Producto.fromDoc(snap as DocumentSnapshot<Map<String, dynamic>>);
  }
}
