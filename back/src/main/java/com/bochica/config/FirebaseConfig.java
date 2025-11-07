package com.bochica.config;

import java.io.InputStream;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

@Configuration
public class FirebaseConfig {

    @Bean
    public FirebaseApp firebaseApp() throws Exception {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        try (InputStream serviceAccount = this.getClass()
                .getClassLoader()
                .getResourceAsStream("firebase/bochica-55981-firebase-adminsdk-fbsvc-9467f4578d.json")) {

            if (serviceAccount == null) {
                throw new IllegalStateException(
                    "No se encontró firebase/bochica-55981-firebase-adminsdk-fbsvc-9467f4578d.json en resources");
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
