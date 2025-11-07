package com.bochica.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Bean
    public FirebaseApp firebaseApp() throws Exception {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        try (InputStream serviceAccount = this.getClass()
                .getClassLoader()
                .getResourceAsStream("firebase/firebase-service-account.json")) {

            if (serviceAccount == null) {
                throw new IllegalStateException(
                    "No se encontró firebase/firebase-service-account.json en resources");
            }

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            FirebaseApp app = FirebaseApp.initializeApp(options);
            System.out.println("🔥 Firebase Admin inicializado correctamente");
            return app;
        }
    }
}
