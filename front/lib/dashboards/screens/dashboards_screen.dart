import 'package:flutter/material.dart';

class DashboardsScreen extends StatelessWidget {
  const DashboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboards'),
      ),
      body: const Center(
        child: Text('Pantalla de Dashboards'),
      ),
    );
  }
}


