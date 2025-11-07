import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/routes/app_routes.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  String _nombre = 'Amigo/a';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1) Si pasaron el nombre por argumentos, úsalo
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final argName = (args['nombre'] as String?)?.trim();

    if (argName != null && argName.isNotEmpty) {
      _nombre = argName;
      return;
    }

    // 2) Sino, toma el usuario autenticado (displayName > email prefix)
    final u = FirebaseAuth.instance.currentUser;
    if (u != null) {
      if ((u.displayName ?? '').trim().isNotEmpty) {
        _nombre = u.displayName!.trim();
      } else if ((u.email ?? '').trim().isNotEmpty) {
        _nombre = u.email!.split('@').first;
      }
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _goRecomendaciones() {
    Navigator.pushNamed(context, AppRoutes.chatbotRecomendaciones);
  }

  void _openAsistencia() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Necesitas ayuda?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Un asesor puede ayudarte. Elige una opción:', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text('Chat con asesor (próximamente)'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El chat con un asesor estará disponible pronto.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline_rounded),
              title: const Text('Enviar correo a soporte'),
              subtitle: const Text('soporte@bochica.com'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriremos el correo cuando esté configurado.')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F1F6);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Chatbot'),
        actions: [
          TextButton(
            onPressed: _goRecomendaciones,
            child: const Text('Recomendaciones'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  const SizedBox(height: 8),
                  _BubbleBot(text: 'Hola $_nombre, ¿cómo te puedo ayudar hoy?'),
                  const SizedBox(height: 8),
                  _BotQuickOptions(
                    onRecomendaciones: _goRecomendaciones,
                    onAsistencia: _openAsistencia,
                  ),
                ],
              ),
            ),
            _InputBar(
              controller: _input,
              onSend: () {
                FocusScope.of(context).unfocus();
                _input.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mensaje enviado (demo)')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ================== Widgets de soporte ================== */

class _BubbleBot extends StatelessWidget {
  const _BubbleBot({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Text(text),
      ),
    );
  }
}

class _BotQuickOptions extends StatelessWidget {
  const _BotQuickOptions({
    required this.onRecomendaciones,
    required this.onAsistencia,
  });

  final VoidCallback onRecomendaciones;
  final VoidCallback onAsistencia;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Qué deseas hacer?', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _OptionChip(
                  label: 'Recomendaciones',
                  icon: Icons.insights_rounded,
                  onTap: onRecomendaciones,
                ),
                _OptionChip(
                  label: 'Asistencia / hablar con alguien',
                  icon: Icons.support_agent_rounded,
                  onTap: onAsistencia,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const fg = Color(0xFF6A5AE0);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE7FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: fg.withOpacity(.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: fg, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta…',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: onSend, icon: const Icon(Icons.send_rounded)),
          ],
        ),
      ),
    );
  }
}
