import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Servicio para manejar las estadísticas de usuario en Firestore
class UserStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'UserStats';

  /// Verifica si existe un documento de UserStats para el usuario
  Future<bool> userStatsExists(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      final exists = doc.exists;
      return exists;
    } catch (e) {
      debugPrint('[UserStatsService] ❌ ERROR al verificar UserStats para userId: $userId - Error: $e');
      throw Exception('Error al verificar UserStats: $e');
    }
  }

  /// Crea un documento de UserStats para el usuario con solo el correo
  /// Los consumos serán gestionados automáticamente por el backend cuando lleguen datos del Arduino
  /// Solo debe llamarse si no existe ya un documento para ese usuario
  Future<void> createUserStats(String userId, String email) async {
    try {
      await _firestore.collection(_collection).doc(userId).set({
        'correo': email,
        // Los consumos (consumosPorFecha) serán creados automáticamente por el backend
      });
      debugPrint('[UserStatsService] ✅ UserStats creado para userId: $userId');
    } catch (e) {
      debugPrint('[UserStatsService] ❌ ERROR al crear UserStats para userId: $userId - Error: $e');
      throw Exception('Error al crear UserStats: $e');
    }
  }

  /// Obtiene los datos de UserStats del usuario
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener UserStats: $e');
    }
  }

  /// DEPRECADO: Los consumos ahora son gestionados automáticamente por el backend
  /// Este método se mantiene por compatibilidad pero no debería usarse
  /// Los consumos se actualizan automáticamente cuando el Arduino envía datos al backend
  @Deprecated('Los consumos son gestionados por el backend. No usar este método.')
  Future<void> updateUserStats({
    required String userId,
    int? consumoducha,
    int? consumoinodoro,
  }) async {
    debugPrint('[UserStatsService] ADVERTENCIA: updateUserStats está deprecado. Los consumos son gestionados por el backend.');
    // Este método ya no actualiza los consumos, solo se mantiene por compatibilidad
    // Los consumos se actualizan automáticamente por el backend cuando llegan datos del Arduino
  }

  /// Inicializa o verifica que existe un documento de UserStats para el usuario actual
  /// Si no existe, lo crea con valores iniciales
  Future<void> initializeUserStatsIfNeeded(User user) async {
    try {
      final exists = await userStatsExists(user.uid);
      
      if (!exists) {
        final email = user.email ?? '';
        await createUserStats(user.uid, email);
        debugPrint('[UserStatsService] ✅ UserStats inicializado para usuario: ${user.uid}');
      }
    } catch (e) {
      debugPrint('[UserStatsService] ❌ ERROR CRÍTICO al inicializar UserStats para usuario ${user.uid}: $e');
      throw Exception('Error al inicializar UserStats: $e');
    }
  }

  /// Obtiene los consumos totales sumando todas las fechas
  /// Retorna un mapa con consumoducha y consumoinodoro totales
  Future<Map<String, double>> getConsumosTotales(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) {
        return {'consumoducha': 0.0, 'consumoinodoro': 0.0};
      }
      
      final data = doc.data();
      final consumosPorFecha = data?['consumosPorFecha'] as Map<String, dynamic>?;
      
      double totalDucha = 0.0;
      double totalInodoro = 0.0;
      
      if (consumosPorFecha != null) {
        consumosPorFecha.forEach((fecha, consumos) {
          if (consumos is Map<String, dynamic>) {
            final ducha = consumos['consumoducha'];
            final inodoro = consumos['consumoinodoro'];
            
            if (ducha is num) totalDucha += ducha.toDouble();
            if (inodoro is num) totalInodoro += inodoro.toDouble();
          }
        });
      }
      
      return {
        'consumoducha': totalDucha,
        'consumoinodoro': totalInodoro,
      };
    } catch (e) {
      debugPrint('[UserStatsService] ❌ Error al obtener consumos totales: $e');
      return {'consumoducha': 0.0, 'consumoinodoro': 0.0};
    }
  }

  /// Obtiene los consumos de una fecha específica
  /// Formato de fecha: 'YYYY-MM-DD' (ej: '2024-01-15')
  Future<Map<String, double>> getConsumosPorFecha(String userId, String fecha) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) {
        return {'consumoducha': 0.0, 'consumoinodoro': 0.0};
      }
      
      final data = doc.data();
      final consumosPorFecha = data?['consumosPorFecha'] as Map<String, dynamic>?;
      
      if (consumosPorFecha == null || !consumosPorFecha.containsKey(fecha)) {
        return {'consumoducha': 0.0, 'consumoinodoro': 0.0};
      }
      
      final consumos = consumosPorFecha[fecha] as Map<String, dynamic>?;
      
      double ducha = 0.0;
      double inodoro = 0.0;
      
      if (consumos != null) {
        final duchaValue = consumos['consumoducha'];
        final inodoroValue = consumos['consumoinodoro'];
        
        if (duchaValue is num) ducha = duchaValue.toDouble();
        if (inodoroValue is num) inodoro = inodoroValue.toDouble();
      }
      
      return {
        'consumoducha': ducha,
        'consumoinodoro': inodoro,
      };
    } catch (e) {
      debugPrint('[UserStatsService] ❌ Error al obtener consumos por fecha: $e');
      return {'consumoducha': 0.0, 'consumoinodoro': 0.0};
    }
  }

  /// Obtiene los consumos de hoy
  Future<Map<String, double>> getConsumosHoy(String userId) async {
    final hoy = DateTime.now();
    final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    return getConsumosPorFecha(userId, fechaHoy);
  }

  /// Obtiene un stream de los consumos totales (para actualización en tiempo real)
  Stream<Map<String, double>> streamConsumosTotales(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {'consumoducha': 0.0, 'consumoinodoro': 0.0};
      }
      
      final data = snapshot.data();
      final consumosPorFecha = data?['consumosPorFecha'] as Map<String, dynamic>?;
      
      double totalDucha = 0.0;
      double totalInodoro = 0.0;
      
      if (consumosPorFecha != null) {
        consumosPorFecha.forEach((fecha, consumos) {
          if (consumos is Map<String, dynamic>) {
            final ducha = consumos['consumoducha'];
            final inodoro = consumos['consumoinodoro'];
            
            if (ducha is num) totalDucha += ducha.toDouble();
            if (inodoro is num) totalInodoro += inodoro.toDouble();
          }
        });
      }
      
      return {
        'consumoducha': totalDucha,
        'consumoinodoro': totalInodoro,
      };
    });
  }

  /// Obtiene todas las fechas con consumo ordenadas
  Future<List<String>> getFechasConConsumo(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!doc.exists) {
        return [];
      }
      
      final data = doc.data();
      final consumosPorFecha = data?['consumosPorFecha'] as Map<String, dynamic>?;
      
      if (consumosPorFecha == null) {
        return [];
      }
      
      final fechas = consumosPorFecha.keys.toList();
      fechas.sort((a, b) => b.compareTo(a)); // Ordenar descendente (más reciente primero)
      
      return fechas;
    } catch (e) {
      debugPrint('[UserStatsService] ❌ Error al obtener fechas con consumo: $e');
      return [];
    }
  }
}

