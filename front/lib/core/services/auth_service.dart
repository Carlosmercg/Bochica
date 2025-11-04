import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Registro con email y password
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Actualiza el perfil si viene displayName
    if (displayName != null && displayName.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(displayName.trim());
    }

    notifyListeners();
    return credential.user;
  }

  /// Login con email y password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    notifyListeners();
    return credential.user;
  }

  /// Cerrar sesión
  Future<void> signOut() async {
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
