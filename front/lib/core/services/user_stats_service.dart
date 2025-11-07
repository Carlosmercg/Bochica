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
      debugPrint('[UserStatsService] 🔍 Verificando existencia de documento para userId: $userId');
      final doc = await _firestore.collection(_collection).doc(userId).get();
      final exists = doc.exists;
      debugPrint('[UserStatsService] ${exists ? '✅' : '❌'} Documento ${exists ? 'EXISTE' : 'NO EXISTE'} para userId: $userId');
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
      debugPrint('[UserStatsService] 📝 Iniciando creación de UserStats para userId: $userId, email: $email');
      await _firestore.collection(_collection).doc(userId).set({
        'correo': email,
        // Los consumos (consumosPorFecha) serán creados automáticamente por el backend
      });
      debugPrint('[UserStatsService] ✅ UserStats creado EXITOSAMENTE para userId: $userId, email: $email');
      debugPrint('[UserStatsService] 📊 Datos creados: {correo: $email}');
      debugPrint('[UserStatsService] ℹ️ Los consumos serán gestionados por el backend cuando lleguen datos del Arduino');
    } catch (e) {
      debugPrint('[UserStatsService] ❌ ERROR al crear UserStats para userId: $userId, email: $email - Error: $e');
      debugPrint('[UserStatsService] ❌ Tipo de error: ${e.runtimeType}');
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
    debugPrint('[UserStatsService] ⚠️ ADVERTENCIA: updateUserStats está deprecado. Los consumos son gestionados por el backend.');
    // Este método ya no actualiza los consumos, solo se mantiene por compatibilidad
    // Los consumos se actualizan automáticamente por el backend cuando llegan datos del Arduino
  }

  /// Inicializa o verifica que existe un documento de UserStats para el usuario actual
  /// Si no existe, lo crea con valores iniciales
  Future<void> initializeUserStatsIfNeeded(User user) async {
    try {
      debugPrint('[UserStatsService] 🚀 Inicializando UserStats para usuario:');
      debugPrint('[UserStatsService]    - UID: ${user.uid}');
      debugPrint('[UserStatsService]    - Email: ${user.email ?? 'NO DISPONIBLE'}');
      debugPrint('[UserStatsService]    - DisplayName: ${user.displayName ?? 'NO DISPONIBLE'}');
      
      final exists = await userStatsExists(user.uid);
      
      if (!exists) {
        debugPrint('[UserStatsService] 📌 Documento NO existe, procediendo a crear...');
        final email = user.email ?? '';
        if (email.isEmpty) {
          debugPrint('[UserStatsService] ⚠️ ADVERTENCIA: El email está vacío, se creará con email vacío');
        }
        await createUserStats(user.uid, email);
        debugPrint('[UserStatsService] ✅ Proceso de inicialización completado exitosamente');
      } else {
        debugPrint('[UserStatsService] ℹ️ Documento ya existe, no se crea nuevo documento');
      }
    } catch (e) {
      debugPrint('[UserStatsService] ❌ ERROR CRÍTICO al inicializar UserStats:');
      debugPrint('[UserStatsService]    - Usuario UID: ${user.uid}');
      debugPrint('[UserStatsService]    - Email: ${user.email ?? 'NO DISPONIBLE'}');
      debugPrint('[UserStatsService]    - Error: $e');
      debugPrint('[UserStatsService]    - Tipo de error: ${e.runtimeType}');
      debugPrint('[UserStatsService]    - StackTrace: ${StackTrace.current}');
      // Si falla, no bloquea el login pero se registra el error
      throw Exception('Error al inicializar UserStats: $e');
    }
  }
}

