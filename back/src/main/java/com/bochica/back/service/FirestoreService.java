package com.bochica.back.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.FieldValue;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.WriteBatch;
import com.google.firebase.cloud.FirestoreClient;

@Service
public class FirestoreService {
    
    private static final Logger logger = LoggerFactory.getLogger(FirestoreService.class);
    private static final String COLLECTION_NAME = "UserStats";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    
    /**
     * Actualiza los consumos agrupados por fecha en todos los documentos
     * de la colección UserStats.
     * 
     * Estructura en Firestore:
     * consumosPorFecha: {
     *   "2024-01-15": {
     *     "consumoducha": 10.5,
     *     "consumoinodoro": 18.0
     *   },
     *   "2024-01-16": {
     *     "consumoducha": 5.2,
     *     "consumoinodoro": 9.0
     *   }
     * }
     * 
     * @param consumoDucha Consumo de ducha a sumar (en litros)
     * @param consumoInodoro Consumo de inodoro a sumar (en litros)
     */
    public void updateAllUserStats(double consumoDucha, double consumoInodoro) {
        try {
            // Obtener la fecha actual en formato YYYY-MM-DD
            String fechaActual = LocalDate.now().format(DATE_FORMATTER);
            
            Firestore db = FirestoreClient.getFirestore();
            
            // Obtener todos los documentos de la colección UserStats
            var documents = db.collection(COLLECTION_NAME).listDocuments();
            
            // Crear un batch para actualizar todos los documentos de manera eficiente
            WriteBatch batch = db.batch();
            int batchCount = 0;
            final int BATCH_LIMIT = 500; // Firestore limita los batches a 500 operaciones
            
            for (var docRefObj : documents) {
                DocumentReference docRef = (DocumentReference) docRefObj;
                Map<String, Object> updates = new HashMap<>();
                
                // Construir las rutas para los campos anidados por fecha
                String pathDucha = String.format("consumosPorFecha.%s.consumoducha", fechaActual);
                String pathInodoro = String.format("consumosPorFecha.%s.consumoinodoro", fechaActual);
                
                // Si hay consumo de ducha, incrementar el valor en la fecha actual
                if (consumoDucha > 0) {
                    updates.put(pathDucha, FieldValue.increment(consumoDucha));
                }
                
                // Si hay consumo de inodoro, incrementar el valor en la fecha actual
                if (consumoInodoro > 0) {
                    updates.put(pathInodoro, FieldValue.increment(consumoInodoro));
                }
                
                if (!updates.isEmpty()) {
                    batch.update(docRef, updates);
                    batchCount++;
                    
                    // Si alcanzamos el límite, ejecutamos el batch y creamos uno nuevo
                    if (batchCount >= BATCH_LIMIT) {
                        batch.commit().get();
                        batch = db.batch();
                        batchCount = 0;
                    }
                }
            }
            
            // Ejecutar el último batch si hay operaciones pendientes
            if (batchCount > 0) {
                batch.commit().get();
            }
            
            logger.info("✅ Actualizados todos los documentos en UserStats para la fecha {} - Ducha: {}L, Inodoro: {}L", 
                       fechaActual,
                       String.format("%.2f", consumoDucha), 
                       String.format("%.2f", consumoInodoro));
            
        } catch (InterruptedException | ExecutionException e) {
            logger.error("❌ Error al actualizar Firestore: {}", e.getMessage(), e);
            Thread.currentThread().interrupt();
            throw new RuntimeException("Error al actualizar Firestore", e);
        }
    }
    
    /**
     * Actualiza los consumos agrupados por fecha para un usuario específico
     * 
     * @param userId ID del usuario (document ID en Firestore)
     * @param consumoDucha Consumo de ducha a sumar (en litros)
     * @param consumoInodoro Consumo de inodoro a sumar (en litros)
     */
    public void updateUserStats(String userId, double consumoDucha, double consumoInodoro) {
        try {
            // Obtener la fecha actual en formato YYYY-MM-DD
            String fechaActual = LocalDate.now().format(DATE_FORMATTER);
            
            Firestore db = FirestoreClient.getFirestore();
            DocumentReference docRef = db.collection(COLLECTION_NAME).document(userId);
            
            Map<String, Object> updates = new HashMap<>();
            
            // Construir las rutas para los campos anidados por fecha
            String pathDucha = String.format("consumosPorFecha.%s.consumoducha", fechaActual);
            String pathInodoro = String.format("consumosPorFecha.%s.consumoinodoro", fechaActual);
            
            // Si hay consumo de ducha, incrementar el valor en la fecha actual
            if (consumoDucha > 0) {
                updates.put(pathDucha, FieldValue.increment(consumoDucha));
            }
            
            // Si hay consumo de inodoro, incrementar el valor en la fecha actual
            if (consumoInodoro > 0) {
                updates.put(pathInodoro, FieldValue.increment(consumoInodoro));
            }
            
            if (!updates.isEmpty()) {
                docRef.update(updates).get();
                logger.info("✅ Actualizado UserStats para usuario {} en fecha {} - Ducha: {}L, Inodoro: {}L", 
                           userId,
                           fechaActual,
                           String.format("%.2f", consumoDucha), 
                           String.format("%.2f", consumoInodoro));
            }
            
        } catch (InterruptedException | ExecutionException e) {
            logger.error("❌ Error al actualizar UserStats para usuario {}: {}", userId, e.getMessage(), e);
            Thread.currentThread().interrupt();
            throw new RuntimeException("Error al actualizar UserStats para usuario: " + userId, e);
        }
    }
    
    /**
     * Obtiene la fecha actual en formato YYYY-MM-DD
     * Útil para testing o consultas
     */
    public String getFechaActual() {
        return LocalDate.now().format(DATE_FORMATTER);
    }
}

