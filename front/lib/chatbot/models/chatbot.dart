class Chatbot {
  final String id;
  final String nombre;
  final String version;

  const Chatbot({
    required this.id,
    required this.nombre,
    required this.version,
  });

  factory Chatbot.fromJson(Map<String, dynamic> json) {
    return Chatbot(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'version': version,
    };
  }
}


