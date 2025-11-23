import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'user_stats_service.dart';
import 'user_info_service.dart';
import 'backend_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserStatsService _userStatsService = UserStatsService();
  final UserInfoService _userInfoService = UserInfoService();
  final BackendService _backendService = BackendService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Registro con email y password
  /// Después del registro, crea el documento UserStats para el nuevo usuario
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      debugPrint('[AuthService] ✅ Registro exitoso en Firebase Auth');

      final user = credential.user;
      if (user != null) {
        // Actualiza el perfil si viene displayName
        if (displayName != null && displayName.trim().isNotEmpty) {
          await user.updateDisplayName(displayName.trim());
          debugPrint('[AuthService] ✅ DisplayName actualizado');
        }

        // Crear UserStats para el nuevo usuario
        try {
          await _userStatsService.initializeUserStatsIfNeeded(user);
          debugPrint('[AuthService] ✅ UserStats creado exitosamente');
        } catch (e) {
          debugPrint('[AuthService] ❌ ERROR al inicializar UserStats: $e');
        }

        // Crear UserInfo para el nuevo usuario
        try {
          await _userInfoService.initializeUserInfoIfNeeded(user);
          debugPrint('[AuthService] ✅ UserInfo creado exitosamente');
        } catch (e) {
          debugPrint('[AuthService] ❌ ERROR al inicializar UserInfo: $e');
        }
        
        // Registrar el usuario activo en el backend para que reciba datos del Arduino
        try {
          final token = await user.getIdToken();
          if (token != null && token.isNotEmpty) {
            await _backendService.registerActiveUser(token);
            debugPrint('[AuthService] ✅ Usuario registrado en el backend');
          }
        } catch (e) {
          debugPrint('[AuthService] ❌ ERROR al registrar usuario en el backend: $e');
        }
      }

      notifyListeners();
      debugPrint('[AuthService] ✅ Proceso de REGISTRO completado');
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] ❌ ERROR en proceso de REGISTRO: ${e.code} - ${e.message}');
      throw Exception(_getFriendlyAuthErrorMessage(e));
    } catch (e) {
      debugPrint('[AuthService] ❌ ERROR en proceso de REGISTRO: $e');
      rethrow;
    }
  }

  /// Login con email y password
  /// Después del login, verifica y crea el documento UserStats si no existe
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      debugPrint('[AuthService] ✅ Login exitoso en Firebase Auth');

      final user = credential.user;
      if (user != null) {
        // Verificar y crear UserStats si no existe
        try {
          await _userStatsService.initializeUserStatsIfNeeded(user);
          debugPrint('[AuthService] ✅ UserStats inicializado');
        } catch (e) {
          debugPrint('[AuthService] ❌ ERROR al inicializar UserStats: $e');
        }

        // Verificar y crear UserInfo si no existe
        try {
          await _userInfoService.initializeUserInfoIfNeeded(user);
          debugPrint('[AuthService] ✅ UserInfo inicializado');
        } catch (e) {
          debugPrint('[AuthService] ❌ ERROR al inicializar UserInfo: $e');
        }
        
        // Registrar el usuario activo en el backend para que reciba datos del Arduino
        try {
          final token = await user.getIdToken();
          if (token != null && token.isNotEmpty) {
            await _backendService.registerActiveUser(token);
            debugPrint('[AuthService] ✅ Usuario registrado en el backend');
          }
        } catch (e) {
          debugPrint('[AuthService] ❌ ERROR al registrar usuario en el backend: $e');
        }
      }

      notifyListeners();
      debugPrint('[AuthService] ✅ Proceso de LOGIN completado');
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] ❌ ERROR en proceso de LOGIN: ${e.code} - ${e.message}');
      // Re-lanzar con mensaje amigable
      throw Exception(_getFriendlyAuthErrorMessage(e));
    } catch (e) {
      debugPrint('[AuthService] ❌ ERROR en proceso de LOGIN: $e');
      rethrow;
    }
  }

  /// Convierte errores de Firebase Auth a mensajes amigables
  String _getFriendlyAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Este usuario no existe';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Por favor intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está en uso';
      case 'weak-password':
        return 'La contraseña es muy débil';
      default:
        return 'Error al iniciar sesión: ${e.message ?? e.code}';
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    // Desregistrar el usuario activo del backend antes de cerrar sesión
    try {
      await _backendService.logoutActiveUser();
      debugPrint('[AuthService] ✅ Usuario desregistrado del backend');
    } catch (e) {
      debugPrint('[AuthService] ❌ ERROR al desregistrar usuario del backend: $e');
      // No bloquear el logout si falla
    }
    
    await _auth.signOut();
    notifyListeners();
  }

  /// Token seguro (evita null y substring sobre null)
  Future<String> getIdToken({bool forceRefresh = false}) async {
    final token = await _auth.currentUser?.getIdToken(forceRefresh);
    return token ?? '';
  }

  /// Ejemplo de "preview" de token sin crashear cuando sea corto o null
  Future<String> getIdTokenPreview() async {
    final t = await getIdToken();
    if (t.isEmpty) return '';
    final end = t.length < 10 ? t.length : 10;
    return t.substring(0, end);
  }
}
