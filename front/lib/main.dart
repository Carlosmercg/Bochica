import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('✅ Firebase conectado correctamente');
  } catch (e) {
    print('❌ Error al conectar con Firebase: $e');
  }

  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.authWelcome,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
