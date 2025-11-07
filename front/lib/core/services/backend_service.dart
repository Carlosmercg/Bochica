import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Servicio para comunicarse con el backend
class BackendService {
  // ⚙️ Configura la URL de tu backend aquí
  static const String baseUrl = 'http://192.168.1.4:8080';
  // Para producción, cambiar a: 'https://tu-dominio.com'
  
  /// Registra el token del usuario autenticado en el backend
  /// El backend guardará este usuario como "activo" para recibir datos del Arduino
  Future<bool> registerActiveUser(String firebaseToken) async {
    try {
      debugPrint('[BackendService] 📤 Registrando usuario activo en el backend...');
      
      final body = jsonEncode({
        'token': firebaseToken,
      });
      
      final response = await http.post(
        Uri.parse('$baseUrl/public/arduino/register-user'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: El servidor no respondió a tiempo');
        },
      );
      
      debugPrint('[BackendService] 📥 Respuesta del servidor: ${response.statusCode}');
      debugPrint('[BackendService]    - Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true) {
          debugPrint('[BackendService] ✅ Usuario registrado correctamente en el backend');
          debugPrint('[BackendService]    - UserId: ${responseData['userId']}');
          return true;
        }
      }
      
      debugPrint('[BackendService] ❌ Error al registrar usuario: ${response.statusCode}');
      return false;
      
    } on http.ClientException catch (e) {
      debugPrint('[BackendService] ❌ Error de conexión: $e');
      // No lanzar excepción, solo retornar false para no bloquear el login
      return false;
    } catch (e) {
      debugPrint('[BackendService] ❌ Error inesperado: $e');
      // No lanzar excepción, solo retornar false para no bloquear el login
      return false;
    }
  }
  
  /// Elimina el usuario activo del backend (cuando cierra sesión)
  Future<bool> logoutActiveUser() async {
    try {
      debugPrint('[BackendService] 📤 Desregistrando usuario activo del backend...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/public/arduino/logout-user'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Timeout: El servidor no respondió a tiempo');
        },
      );
      
      if (response.statusCode == 200) {
        debugPrint('[BackendService] ✅ Usuario desregistrado correctamente');
        return true;
      }
      
      debugPrint('[BackendService] ❌ Error al desregistrar usuario: ${response.statusCode}');
      return false;
      
    } catch (e) {
      debugPrint('[BackendService] ❌ Error al desregistrar usuario: $e');
      // No lanzar excepción, solo retornar false
      return false;
    }
  }
}

