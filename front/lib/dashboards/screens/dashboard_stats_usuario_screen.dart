import 'package:flutter/material.dart';

class DashboardStatsUsuarioScreen extends StatelessWidget {
  const DashboardStatsUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard - Usuario y estadísticas')),
      body: Center(child: Text('Resumen del usuario + métricas')),
    );
  }
}


