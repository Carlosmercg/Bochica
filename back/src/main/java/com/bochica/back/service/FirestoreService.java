package com.bochica.back.service;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.WriteBatch;
import com.google.firebase.cloud.FirestoreClient;

@Service
public class FirestoreService {
    
    private static final Logger logger = LoggerFactory.getLogger(FirestoreService.class);
    private static final String COLLECTION_NAME = "UserStats";
    
    /**
     * Actualiza los campos consumoducha y consumoinodoro en todos los documentos
     * de la colección UserStats con valores acumulados
     * 
     * @param consumoDucha Consumo de ducha a sumar (en litros)
     * @param consumoInodoro Consumo de inodoro a sumar (en litros)
     */
    public void updateAllUserStats(double consumoDucha, double consumoInodoro) {
        try {
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
                
                // Si hay consumo de ducha, incrementar el valor acumulado
                if (consumoDucha > 0) {
                    updates.put("consumoducha", 
                        com.google.cloud.firestore.FieldValue.increment(consumoDucha));
                }
                
                // Si hay consumo de inodoro, incrementar el valor acumulado
                if (consumoInodoro > 0) {
                    updates.put("consumoinodoro", 
                        com.google.cloud.firestore.FieldValue.increment(consumoInodoro));
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
            
            logger.info("✅ Actualizados todos los documentos en UserStats - Ducha: {}L, Inodoro: {}L", 
                       String.format("%.2f", consumoDucha), 
                       String.format("%.2f", consumoInodoro));
            
        } catch (InterruptedException | ExecutionException e) {
            logger.error("❌ Error al actualizar Firestore: {}", e.getMessage(), e);
            Thread.currentThread().interrupt();
            throw new RuntimeException("Error al actualizar Firestore", e);
        }
    }
}

