import 'package:flutter/material.dart';

class ChatbotRecomendacionesScreen extends StatelessWidget {
  const ChatbotRecomendacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recomendaciones de consumo')),
      body: Center(child: Text('Sugerencias basadas en tu consumo')),
    );
  }
}


