import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Servicio para manejar la información adicional del usuario en Firestore
class UserInfoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'UserInfo';

  /// Verifica si existe un documento de UserInfo para el usuario
  Future<bool> userInfoExists(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      final exists = doc.exists;
      return exists;
    } catch (e) {
      debugPrint('[UserInfoService] ❌ ERROR al verificar UserInfo para userId: $userId - Error: $e');
      throw Exception('Error al verificar UserInfo: $e');
    }
  }

  /// Crea un documento de UserInfo para el usuario con campos vacíos
  /// Solo debe llamarse si no existe ya un documento para ese usuario
  Future<void> createUserInfo(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).set({
        'direccion': '',
        'telefono': '',
        'ciudad': '',
        'codigoPostal': '',
        'pais': '',
        'fechaCreacion': FieldValue.serverTimestamp(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
      debugPrint('[UserInfoService] ✅ UserInfo creado para userId: $userId');
    } catch (e) {
      debugPrint('[UserInfoService] ❌ ERROR al crear UserInfo para userId: $userId - Error: $e');
      throw Exception('Error al crear UserInfo: $e');
    }
  }

  /// Obtiene los datos de UserInfo del usuario
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('[UserInfoService] ❌ Error al obtener UserInfo: $e');
      throw Exception('Error al obtener UserInfo: $e');
    }
  }

  /// Actualiza los datos de UserInfo del usuario
  Future<void> updateUserInfo(String userId, Map<String, dynamic> data) async {
    try {
      data['fechaActualizacion'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(userId).update(data);
      debugPrint('[UserInfoService] ✅ UserInfo actualizado para userId: $userId');
    } catch (e) {
      debugPrint('[UserInfoService] ❌ ERROR al actualizar UserInfo para userId: $userId - Error: $e');
      throw Exception('Error al actualizar UserInfo: $e');
    }
  }

  /// Inicializa o verifica que existe un documento de UserInfo para el usuario actual
  /// Si no existe, lo crea con valores iniciales vacíos
  Future<void> initializeUserInfoIfNeeded(User user) async {
    try {
      final exists = await userInfoExists(user.uid);
      
      if (!exists) {
        await createUserInfo(user.uid);
        debugPrint('[UserInfoService] ✅ UserInfo inicializado para usuario: ${user.uid}');
      }
    } catch (e) {
      debugPrint('[UserInfoService] ❌ ERROR CRÍTICO al inicializar UserInfo para usuario ${user.uid}: $e');
      throw Exception('Error al inicializar UserInfo: $e');
    }
  }

  /// Obtiene un stream de UserInfo (para actualización en tiempo real)
  Stream<Map<String, dynamic>?> streamUserInfo(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return snapshot.data();
    });
  }
}

