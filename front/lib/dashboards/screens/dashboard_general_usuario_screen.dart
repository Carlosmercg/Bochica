import 'package:flutter/material.dart';

class DashboardGeneralUsuarioScreen extends StatelessWidget {
  const DashboardGeneralUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard - General usuario')),
      body: Center(child: Text('Información general del usuario')),
    );
  }
}


