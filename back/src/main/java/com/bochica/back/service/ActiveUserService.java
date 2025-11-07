package com.bochica.back.service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

/**
 * Servicio para gestionar el usuario activo que recibirá los datos del Arduino
 * Flutter envía el token del usuario autenticado y este servicio lo guarda
 */
@Service
public class ActiveUserService {
    
    private static final Logger logger = LoggerFactory.getLogger(ActiveUserService.class);
    
    // Guardar el userId del usuario activo (el que está usando la app)
    // Usamos ConcurrentHashMap para thread-safety
    private final Map<String, String> activeUsers = new ConcurrentHashMap<>();
    
    // Clave única para identificar el usuario activo (puede ser "default" o un ID de dispositivo)
    private static final String DEFAULT_KEY = "default";
    
    /**
     * Registra un usuario activo validando su token de Firebase
     * Flutter llama a este método cuando el usuario inicia sesión
     * 
     * @param firebaseToken Token de Firebase del usuario autenticado
     * @return userId del usuario si el token es válido, null si no
     */
    public String registerActiveUser(String firebaseToken) {
        try {
            // Validar el token de Firebase
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(firebaseToken);
            String userId = decodedToken.getUid();
            
            // Guardar el userId como usuario activo
            activeUsers.put(DEFAULT_KEY, userId);
            
            logger.info("✅ Usuario activo registrado: {} (email: {})", 
                       userId, decodedToken.getEmail());
            
            return userId;
            
        } catch (Exception e) {
            logger.error("❌ Error al validar token de Firebase: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * Obtiene el userId del usuario activo
     * Se usa cuando el Arduino envía datos para saber a qué usuario actualizar
     * 
     * @return userId del usuario activo, o null si no hay ninguno registrado
     */
    public String getActiveUserId() {
        return activeUsers.get(DEFAULT_KEY);
    }
    
    /**
     * Elimina el usuario activo (cuando el usuario cierra sesión)
     */
    public void clearActiveUser() {
        activeUsers.remove(DEFAULT_KEY);
        logger.info("🔄 Usuario activo eliminado");
    }
    
    /**
     * Verifica si hay un usuario activo registrado
     */
    public boolean hasActiveUser() {
        return activeUsers.containsKey(DEFAULT_KEY) && activeUsers.get(DEFAULT_KEY) != null;
    }
}

