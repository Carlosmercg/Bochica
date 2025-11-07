import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'user_stats_service.dart';
import 'backend_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserStatsService _userStatsService = UserStatsService();
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
    debugPrint('[AuthService] 📝 Iniciando proceso de REGISTRO');
    debugPrint('[AuthService]    - Email: $email');
    debugPrint('[AuthService]    - DisplayName: ${displayName ?? 'NO PROPORCIONADO'}');
    
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      debugPrint('[AuthService] ✅ Registro exitoso en Firebase Auth');

      final user = credential.user;
      if (user != null) {
        debugPrint('[AuthService] 👤 Nuevo usuario creado:');
        debugPrint('[AuthService]    - UID: ${user.uid}');
        debugPrint('[AuthService]    - Email: ${user.email ?? 'NO DISPONIBLE'}');
        
        // Actualiza el perfil si viene displayName
        if (displayName != null && displayName.trim().isNotEmpty) {
          debugPrint('[AuthService] 📝 Actualizando displayName: $displayName');
          await user.updateDisplayName(displayName.trim());
          debugPrint('[AuthService] ✅ DisplayName actualizado');
        }

        // Crear UserStats para el nuevo usuario
        debugPrint('[AuthService] 📊 Iniciando creación de UserStats para nuevo usuario...');
        try {
          await _userStatsService.initializeUserStatsIfNeeded(user);
          debugPrint('[AuthService] ✅ UserStats creado exitosamente para nuevo usuario');
        } catch (e) {
          // Si falla, no bloquea el registro pero se registra el error
          debugPrint('[AuthService] ❌ ERROR al inicializar UserStats (NO bloquea el registro):');
          debugPrint('[AuthService]    - Error: $e');
          debugPrint('[AuthService]    - Tipo: ${e.runtimeType}');
        }
        
        // Registrar el usuario activo en el backend para que reciba datos del Arduino
        debugPrint('[AuthService] 🔗 Registrando usuario activo en el backend...');
        try {
          final token = await user.getIdToken();
          if (token != null && token.isNotEmpty) {
            await _backendService.registerActiveUser(token);
            debugPrint('[AuthService] ✅ Usuario registrado en el backend exitosamente');
          } else {
            debugPrint('[AuthService] ⚠️ No se pudo obtener el token de Firebase');
          }
        } catch (e) {
          // Si falla, no bloquea el registro pero se registra el error
          debugPrint('[AuthService] ❌ ERROR al registrar usuario en el backend (NO bloquea el registro):');
          debugPrint('[AuthService]    - Error: $e');
        }
      } else {
        debugPrint('[AuthService] ⚠️ ADVERTENCIA: Usuario registrado pero user es null');
      }

      notifyListeners();
      debugPrint('[AuthService] ✅ Proceso de REGISTRO completado');
      return user;
    } catch (e) {
      debugPrint('[AuthService] ❌ ERROR en proceso de REGISTRO:');
      debugPrint('[AuthService]    - Email intentado: $email');
      debugPrint('[AuthService]    - Error: $e');
      debugPrint('[AuthService]    - Tipo: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Login con email y password
  /// Después del login, verifica y crea el documento UserStats si no existe
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint('[AuthService] 🔐 Iniciando proceso de LOGIN');
    debugPrint('[AuthService]    - Email: $email');
    
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      debugPrint('[AuthService] ✅ Login exitoso en Firebase Auth');

      final user = credential.user;
      if (user != null) {
        debugPrint('[AuthService] 👤 Usuario autenticado:');
        debugPrint('[AuthService]    - UID: ${user.uid}');
        debugPrint('[AuthService]    - Email: ${user.email ?? 'NO DISPONIBLE'}');
        debugPrint('[AuthService]    - DisplayName: ${user.displayName ?? 'NO DISPONIBLE'}');
        
        // Verificar y crear UserStats si no existe
        debugPrint('[AuthService] 📊 Iniciando verificación/creación de UserStats...');
        try {
          await _userStatsService.initializeUserStatsIfNeeded(user);
          debugPrint('[AuthService] ✅ Proceso de UserStats completado exitosamente');
        } catch (e) {
          // Si falla, no bloquea el login pero se registra el error
          debugPrint('[AuthService] ❌ ERROR al inicializar UserStats (NO bloquea el login):');
          debugPrint('[AuthService]    - Error: $e');
          debugPrint('[AuthService]    - Tipo: ${e.runtimeType}');
        }
        
        // Registrar el usuario activo en el backend para que reciba datos del Arduino
        debugPrint('[AuthService] 🔗 Registrando usuario activo en el backend...');
        try {
          final token = await user.getIdToken();
          if (token != null && token.isNotEmpty) {
            await _backendService.registerActiveUser(token);
            debugPrint('[AuthService] ✅ Usuario registrado en el backend exitosamente');
          } else {
            debugPrint('[AuthService] ⚠️ No se pudo obtener el token de Firebase');
          }
        } catch (e) {
          // Si falla, no bloquea el login pero se registra el error
          debugPrint('[AuthService] ❌ ERROR al registrar usuario en el backend (NO bloquea el login):');
          debugPrint('[AuthService]    - Error: $e');
        }
      } else {
        debugPrint('[AuthService] ⚠️ ADVERTENCIA: Usuario autenticado pero user es null');
      }

      notifyListeners();
      debugPrint('[AuthService] ✅ Proceso de LOGIN completado');
      return user;
    } catch (e) {
      debugPrint('[AuthService] ❌ ERROR en proceso de LOGIN:');
      debugPrint('[AuthService]    - Email intentado: $email');
      debugPrint('[AuthService]    - Error: $e');
      debugPrint('[AuthService]    - Tipo: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    // Desregistrar el usuario activo del backend antes de cerrar sesión
    debugPrint('[AuthService] 🔗 Desregistrando usuario activo del backend...');
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
