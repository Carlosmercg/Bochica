package com.bochica.back.service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * Servicio para manejar el cálculo de consumo de agua
 * - toggle (ducha): Temporiza el tiempo activo y calcula consumo
 * - momentaneo (inodoro): Acumula consumo cada vez que se activa
 */
@Service
public class ConsumoService {
    
    private static final Logger logger = LoggerFactory.getLogger(ConsumoService.class);
    
    // Constantes de consumo (en litros)
    private static final double CONSUMO_DUCHA_LITROS_POR_SEGUNDO = 0.15; // ~9 litros/minuto
    private static final double CONSUMO_INODORO_LITROS_POR_USO = 9.0; // ~9 litros por descarga
    
    // Almacenar el tiempo de inicio cuando toggle se activa
    // Usamos ConcurrentHashMap para thread-safety
    private final Map<String, Instant> toggleStartTimes = new ConcurrentHashMap<>();
    
    // Almacenar consumos acumulados por sesión (opcional, para tracking)
    private double consumoDuchaAcumulado = 0.0;
    private double consumoInodoroAcumulado = 0.0;
    
    /**
     * Procesa el estado del toggle (ducha)
     * - Si se activa (true): guarda el tiempo de inicio, NO calcula consumo
     * - Si se desactiva (false): calcula el tiempo activo y retorna el consumo
     * 
     * IMPORTANTE: Solo retorna consumo > 0 cuando se desactiva (false)
     */
    public double processToggle(Boolean toggle) {
        String key = "ducha"; // Clave única para identificar la ducha
        
        if (Boolean.TRUE.equals(toggle)) {
            // Toggle se activó - guardar tiempo de inicio, NO calcular consumo aún
            if (!toggleStartTimes.containsKey(key)) {
                toggleStartTimes.put(key, Instant.now());
                logger.info("🚿 Ducha activada - Iniciando temporización (esperando desactivación)");
            }
            return 0.0; // NO hay consumo aún, solo se activó
        } else if (Boolean.FALSE.equals(toggle)) {
            // Toggle se desactivó - calcular consumo basado en tiempo activo
            Instant startTime = toggleStartTimes.remove(key);
            if (startTime != null) {
                long segundos = Instant.now().getEpochSecond() - startTime.getEpochSecond();
                double consumo = segundos * CONSUMO_DUCHA_LITROS_POR_SEGUNDO;
                consumoDuchaAcumulado += consumo;
                
                logger.info("🚿 Ducha desactivada - Tiempo activo: {} segundos, Consumo calculado: {} litros", 
                           segundos, String.format("%.2f", consumo));
                
                return consumo; // Retornar consumo para añadir a Firestore
            } else {
                logger.warn("⚠️ Toggle se desactivó pero no había tiempo de inicio guardado");
            }
        }
        
        return 0.0;
    }
    
    /**
     * Procesa el estado momentaneo (inodoro)
     * - Solo procesa cuando es true (se activa)
     * - Ignora cuando es false (no hace nada)
     * - Retorna el consumo estándar para añadir a consumoinodoro
     */
    public double processMomentaneo(Boolean momentaneo) {
        if (Boolean.TRUE.equals(momentaneo)) {
            // Momentaneo se activó - añadir consumo estándar a consumoinodoro
            consumoInodoroAcumulado += CONSUMO_INODORO_LITROS_POR_USO;
            logger.info("🚽 Inodoro activado - Añadiendo {} litros a consumoinodoro", 
                       String.format("%.2f", CONSUMO_INODORO_LITROS_POR_USO));
            return CONSUMO_INODORO_LITROS_POR_USO; // Retornar consumo para añadir a Firestore
        }
        
        // Si es false, no hacer nada (ignorar)
        return 0.0;
    }
    
    /**
     * Obtiene el consumo acumulado de ducha
     */
    public double getConsumoDuchaAcumulado() {
        return consumoDuchaAcumulado;
    }
    
    /**
     * Obtiene el consumo acumulado de inodoro
     */
    public double getConsumoInodoroAcumulado() {
        return consumoInodoroAcumulado;
    }
    
    /**
     * Resetea los consumos acumulados (útil para testing o reinicio diario)
     */
    public void resetConsumos() {
        consumoDuchaAcumulado = 0.0;
        consumoInodoroAcumulado = 0.0;
        toggleStartTimes.clear();
        logger.info("🔄 Consumos reseteados");
    }
    
    /**
     * Obtiene las constantes de consumo (útil para configuración)
     */
    public double getConsumoDuchaLitrosPorSegundo() {
        return CONSUMO_DUCHA_LITROS_POR_SEGUNDO;
    }
    
    public double getConsumoInodoroLitrosPorUso() {
        return CONSUMO_INODORO_LITROS_POR_USO;
    }
}

