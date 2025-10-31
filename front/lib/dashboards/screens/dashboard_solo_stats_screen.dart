import 'package:flutter/material.dart';

class DashboardSoloStatsScreen extends StatelessWidget {
  const DashboardSoloStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard - Estadísticas')),
      body: Center(child: Text('Gráficas y métricas')),
    );
  }
}


