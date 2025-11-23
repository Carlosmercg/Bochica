# 🌊 Bochica — Ecosistema IoT de Ahorro de Agua

Bochica es un ecosistema IoT diseñado para monitorear y optimizar el consumo de agua en el hogar.  
Este repositorio integra los tres componentes principales del sistema:

- **Arduino (Firmware del dispositivo físico)**
- **Backend en Java (Gateway IoT y sincronización con Firebase)**
- **Aplicación móvil en Flutter (Interfaz del usuario final)**

El flujo completo del sistema es:

**Arduino → Backend Java → Firebase → App Flutter**

---

## Estructura del Repositorio

/bochica

│── /arduino/            # Código del dispositivo IoT (se abre en Arduino IDE)

/backend-java/           # Backend en Java: recibe datos y publica en Firebase

/app-flutter/            # Aplicación móvil en Flutter

└── README.md            # Este documento


---

# 1. Arduino — Firmware del Dispositivo IoT

El código del Arduino se encuentra en formato `.txt` porque debe ser abierto y compilado en **Arduino IDE**.

### Funcionalidad
- Lee el consumo de agua mediante sensores físicos.
- Maneja intervalos de muestreo y reintentos básicos.

### Requisitos
- Arduino IDE instalado.
- Librerías del sensor correspondiente.
- Conexión USB/Serial activa.


# 2. Backend en Java — Procesamiento y Publicación en Firebase

El backend actúa como intermediario entre el dispositivo físico y la nube.

### Flujo de operación
1. Recibe datos por un endpoint desde el Arduino.  
2. Interpreta y valida la información.  
3. Publica los cambios en **Firebase** usando Firebase Admin SDK.  
4. Los datos quedan disponibles en tiempo real para la app Flutter.

### Tecnologías utilizadas
- Firebase Admin SDK
- SprinBoot
- Maven

### Responsabilidades del backend
- Parseo de los datos enviados por el Arduino.
- Normalización del consumo.
- Envío de datos a Firebase.
- Logs para depuración.

---

# 3. Aplicación Flutter — App del Usuario Final

La aplicación móvil permite visualizar el consumo en tiempo real y gestionar los dispositivos del hogar.

### Funcionalidades principales
- Inicio de sesión y registro con **Firebase Auth**.
- Dashboard con:
  - Consumo diario
  - Comparación con el promedio histórico
  - Gráficas reales del día
- Gestión de dispositivos:
  - Vincular  
  - Desvincular  
  - Eliminar  
- Perfil de usuario editable.

### Tecnologías
- Flutter 3.x
- Firebase Auth
- Firebase Firestore o Realtime Database
- Streams para datos en tiempo real
---

# 🚀 Cómo Ejecutar el Proyecto

### 1. Arduino
- Abrir en Arduino IDE
- Tener una placa ESP8266
- Copiar en sketch `.ino`
- agregar credenciales de internet
- Compilar y subir  
- Confirmar puerto Serial

### 2. Backend Java
Compilar con springBoot

### 3. Front Flutter
- Tener un emulador de android (de android studio)
- Flutter emulators --launch <nombre emulador>
- flutter run


