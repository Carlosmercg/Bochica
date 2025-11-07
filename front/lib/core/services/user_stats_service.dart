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

  /// Crea un documento de UserStats para el usuario con valores iniciales
  /// Solo debe llamarse si no existe ya un documento para ese usuario
  Future<void> createUserStats(String userId, String email) async {
    try {
      debugPrint('[UserStatsService] 📝 Iniciando creación de UserStats para userId: $userId, email: $email');
      await _firestore.collection(_collection).doc(userId).set({
        'correo': email,
        'consumoducha': 0,
        'consumoinodoro': 0,
      });
      debugPrint('[UserStatsService] ✅ UserStats creado EXITOSAMENTE para userId: $userId, email: $email');
      debugPrint('[UserStatsService] 📊 Datos creados: {correo: $email, consumoducha: 0, consumoinodoro: 0}');
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

  /// Actualiza los valores de consumo
  Future<void> updateUserStats({
    required String userId,
    int? consumoducha,
    int? consumoinodoro,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (consumoducha != null) {
        updateData['consumoducha'] = consumoducha;
      }
      if (consumoinodoro != null) {
        updateData['consumoinodoro'] = consumoinodoro;
      }

      await _firestore.collection(_collection).doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Error al actualizar UserStats: $e');
    }
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

