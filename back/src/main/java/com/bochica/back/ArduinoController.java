package com.bochica.back;

import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.bochica.back.dto.ArduinoRequest;
import com.bochica.back.dto.TokenRequest;
import com.bochica.back.service.ActiveUserService;
import com.bochica.back.service.ConsumoService;
import com.bochica.back.service.FirestoreService;

@RestController
@RequestMapping("/public/arduino")
public class ArduinoController {
    
    private static final Logger logger = LoggerFactory.getLogger(ArduinoController.class);
    
    @Autowired
    private ConsumoService consumoService;
    
    @Autowired
    private FirestoreService firestoreService;
    
    @Autowired
    private ActiveUserService activeUserService;
    
    /**
     * Endpoint para recibir datos del Arduino
     * 
     * toggle: Simula la ducha. Cuando cambia a activo, se temporiza el tiempo
     *         y se calcula el consumo basado en litros por segundo.
     * 
     * momentaneo: Simula el inodoro. Cuando se activa, se acumula un consumo
     *             fijo aproximado de agua de inodoro.
     * 
     * URL: http://localhost:8080/public/arduino/data
     * Método: POST
     * Content-Type: application/json
     * 
     * Body ejemplo:
     * {
     *   "toggle": true,
     *   "momentaneo": false
     * }
     */
    @PostMapping("/data")
    public ResponseEntity<Map<String, Object>> receiveArduinoData(@RequestBody ArduinoRequest request) {
        try {
            // Validar que al menos uno de los parámetros esté presente
            if (request.getToggle() == null && request.getMomentaneo() == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Al menos uno de los parámetros (toggle o momentaneo) debe estar presente");
                return ResponseEntity.badRequest().body(error);
            }
            
            double consumoDucha = 0.0;
            double consumoInodoro = 0.0;
            
            // Procesar toggle (ducha) - temporización
            // Solo calcula y actualiza cuando se desactiva (false)
            if (request.getToggle() != null) {
                if (Boolean.FALSE.equals(request.getToggle())) {
                    // Toggle se desactivó - calcular consumo y añadir a consumoducha
                    consumoDucha = consumoService.processToggle(false);
                    logger.info("🚿 Toggle desactivado - Consumo calculado: {} litros", 
                               String.format("%.2f", consumoDucha));
                } else if (Boolean.TRUE.equals(request.getToggle())) {
                    // Toggle se activó - solo guardar tiempo de inicio, NO actualizar Firestore
                    consumoService.processToggle(true);
                    logger.info("🚿 Toggle activado - Esperando desactivación para calcular consumo");
                }
            }
            
            // Procesar momentaneo (inodoro) - acumulación inmediata
            // Solo procesa cuando es true (ignora false)
            if (request.getMomentaneo() != null && Boolean.TRUE.equals(request.getMomentaneo())) {
                consumoInodoro = consumoService.processMomentaneo(true);
                logger.info("🚽 Momentaneo activado - Consumo añadido: {} litros", 
                           String.format("%.2f", consumoInodoro));
            }
            
            // Actualizar Firestore solo si hay consumo que registrar
            // Toggle: solo cuando se desactiva (consumoDucha > 0)
            // Momentaneo: solo cuando se activa (consumoInodoro > 0)
            String fechaActual = null;
            if (consumoDucha > 0 || consumoInodoro > 0) {
                // Obtener el userId del usuario activo (registrado por Flutter)
                String activeUserId = activeUserService.getActiveUserId();
                
                if (activeUserId != null && !activeUserId.isEmpty()) {
                    // Actualizar solo el usuario activo
                    firestoreService.updateUserStats(activeUserId, consumoDucha, consumoInodoro);
                    logger.info("📊 Actualizando consumos para usuario activo: {}", activeUserId);
                } else {
                    // Si no hay usuario activo, actualizar todos (comportamiento legacy)
                    logger.warn("⚠️ No hay usuario activo registrado, actualizando todos los usuarios");
                    firestoreService.updateAllUserStats(consumoDucha, consumoInodoro);
                }
                
                fechaActual = firestoreService.getFechaActual();
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Datos recibidos y procesados correctamente");
            response.put("toggle", request.getToggle());
            response.put("momentaneo", request.getMomentaneo());
            
            if (fechaActual != null) {
                response.put("fecha", fechaActual);
            }
            
            if (consumoDucha > 0) {
                response.put("consumoDucha", String.format("%.2f", consumoDucha) + " litros");
            }
            if (consumoInodoro > 0) {
                response.put("consumoInodoro", String.format("%.2f", consumoInodoro) + " litros");
            }
            
            // Incluir consumos acumulados totales
            response.put("consumoDuchaAcumulado", 
                        String.format("%.2f", consumoService.getConsumoDuchaAcumulado()) + " litros");
            response.put("consumoInodoroAcumulado", 
                        String.format("%.2f", consumoService.getConsumoInodoroAcumulado()) + " litros");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("❌ Error al procesar datos del Arduino: {}", e.getMessage(), e);
            
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "Error al procesar los datos: " + e.getMessage());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Endpoint para que Flutter registre el token del usuario autenticado
     * Flutter debe llamar a este endpoint cuando el usuario inicia sesión
     * 
     * URL: http://localhost:8080/public/arduino/register-user
     * Método: POST
     * Content-Type: application/json
     * 
     * Body ejemplo:
     * {
     *   "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij..."
     * }
     */
    @PostMapping("/register-user")
    public ResponseEntity<Map<String, Object>> registerActiveUser(@RequestBody TokenRequest request) {
        try {
            if (request.getToken() == null || request.getToken().isEmpty()) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "El token es requerido");
                return ResponseEntity.badRequest().body(error);
            }
            
            // Registrar el usuario activo validando el token
            String userId = activeUserService.registerActiveUser(request.getToken());
            
            if (userId != null) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "Usuario registrado correctamente");
                response.put("userId", userId);
                logger.info("✅ Usuario {} registrado como activo", userId);
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("message", "Token inválido o expirado");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }
            
        } catch (Exception e) {
            logger.error("❌ Error al registrar usuario activo: {}", e.getMessage(), e);
            
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "Error al procesar el token: " + e.getMessage());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Endpoint para que Flutter elimine el usuario activo (cuando cierra sesión)
     * 
     * URL: http://localhost:8080/public/arduino/logout-user
     * Método: POST
     */
    @PostMapping("/logout-user")
    public ResponseEntity<Map<String, Object>> logoutActiveUser() {
        try {
            activeUserService.clearActiveUser();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Usuario desregistrado correctamente");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("❌ Error al desregistrar usuario activo: {}", e.getMessage(), e);
            
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "Error al desregistrar usuario: " + e.getMessage());
            
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * Endpoint de prueba para verificar que el servidor está funcionando
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "ok");
        response.put("message", "Arduino endpoint está funcionando");
        return ResponseEntity.ok(response);
    }
}

