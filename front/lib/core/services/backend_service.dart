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
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true) {
          debugPrint('[BackendService] ✅ Usuario registrado en el backend');
          return true;
        }
      }
      
      debugPrint('[BackendService] ❌ Error al registrar usuario: ${response.statusCode}');
      return false;
      
    } on http.ClientException catch (e) {
      debugPrint('[BackendService] ❌ Error de conexión: $e');
      return false;
    } catch (e) {
      debugPrint('[BackendService] ❌ Error inesperado: $e');
      return false;
    }
  }
  
  /// Elimina el usuario activo del backend (cuando cierra sesión)
  Future<bool> logoutActiveUser() async {
    try {
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
        debugPrint('[BackendService] ✅ Usuario desregistrado del backend');
        return true;
      }
      
      debugPrint('[BackendService] ❌ Error al desregistrar usuario: ${response.statusCode}');
      return false;
      
    } catch (e) {
      debugPrint('[BackendService] ❌ Error al desregistrar usuario: $e');
      return false;
    }
  }
}

