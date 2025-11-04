class ConfigDisp {
  final String id;
  final String dispositivoId;
  final Map<String, dynamic> parametros;

  const ConfigDisp({
    required this.id,
    required this.dispositivoId,
    required this.parametros,
  });

  factory ConfigDisp.fromJson(Map<String, dynamic> json) {
    return ConfigDisp(
      id: json['id'] as String,
      dispositivoId: json['dispositivoId'] as String,
      parametros: Map<String, dynamic>.from(json['parametros'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dispositivoId': dispositivoId,
      'parametros': parametros,
    };
  }
}


