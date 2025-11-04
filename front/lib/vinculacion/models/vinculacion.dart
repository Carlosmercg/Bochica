class Vinculacion {
  final String id;
  final String usuarioId;
  final String dispositivoId;
  final DateTime fecha;

  const Vinculacion({
    required this.id,
    required this.usuarioId,
    required this.dispositivoId,
    required this.fecha,
  });

  factory Vinculacion.fromJson(Map<String, dynamic> json) {
    return Vinculacion(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      dispositivoId: json['dispositivoId'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'dispositivoId': dispositivoId,
      'fecha': fecha.toIso8601String(),
    };
  }
}


