import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Modelo para representar un dispositivo del usuario
class UserDevice {
  final String id;
  final String nombre;
  final String tipoProducto;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  UserDevice({
    required this.id,
    required this.nombre,
    required this.tipoProducto,
    required this.activo,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory UserDevice.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserDevice(
      id: doc.id,
      nombre: (data['nombre'] ?? '').toString(),
      tipoProducto: (data['tipoProducto'] ?? '').toString(),
      activo: (data['activo'] as bool?) ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'tipoProducto': tipoProducto,
        'activo': activo,
        'fechaCreacion': Timestamp.fromDate(fechaCreacion),
        if (fechaActualizacion != null)
          'fechaActualizacion': Timestamp.fromDate(fechaActualizacion!),
      };
}

/// Servicio para manejar los dispositivos del usuario en Firestore
class UserDispService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'UserDisp';

  /// Crea un nuevo dispositivo para el usuario
  Future<String> createDevice({
    required String userId,
    required String nombre,
    required String tipoProducto,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      await docRef.set({
        'userId': userId,
        'nombre': nombre,
        'tipoProducto': tipoProducto,
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      debugPrint('[UserDispService] ✅ Dispositivo creado con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[UserDispService] ❌ ERROR al crear dispositivo: $e');
      throw Exception('Error al crear dispositivo: $e');
    }
  }

  /// Obtiene todos los dispositivos de un usuario
  Future<List<UserDevice>> getUserDevices(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => UserDevice.fromDoc(doc))
          .toList();
    } catch (e) {
      debugPrint('[UserDispService] ❌ Error al obtener dispositivos: $e');
      throw Exception('Error al obtener dispositivos: $e');
    }
  }

  /// Obtiene un stream de dispositivos del usuario (para actualización en tiempo real)
  Stream<List<UserDevice>> streamUserDevices(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserDevice.fromDoc(doc))
          .toList();
    });
  }

  /// Actualiza el estado activo de un dispositivo
  Future<void> updateDeviceStatus(String deviceId, bool activo) async {
    try {
      await _firestore.collection(_collection).doc(deviceId).update({
        'activo': activo,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
      debugPrint('[UserDispService] ✅ Estado actualizado para dispositivo: $deviceId');
    } catch (e) {
      debugPrint('[UserDispService] ❌ ERROR al actualizar estado: $e');
      throw Exception('Error al actualizar estado: $e');
    }
  }

  /// Elimina un dispositivo
  Future<void> deleteDevice(String deviceId) async {
    try {
      await _firestore.collection(_collection).doc(deviceId).delete();
      debugPrint('[UserDispService] ✅ Dispositivo eliminado: $deviceId');
    } catch (e) {
      debugPrint('[UserDispService] ❌ ERROR al eliminar dispositivo: $e');
      throw Exception('Error al eliminar dispositivo: $e');
    }
  }

  /// Obtiene un dispositivo por ID
  Future<UserDevice?> getDeviceById(String deviceId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(deviceId).get();
      if (doc.exists) {
        return UserDevice.fromDoc(doc);
      }
      return null;
    } catch (e) {
      debugPrint('[UserDispService] ❌ Error al obtener dispositivo: $e');
      throw Exception('Error al obtener dispositivo: $e');
    }
  }
}

