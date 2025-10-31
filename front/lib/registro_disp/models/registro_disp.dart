class RegistroDisp {
  final String id;
  final String dispositivoId;
  final DateTime registradoEn;

  const RegistroDisp({
    required this.id,
    required this.dispositivoId,
    required this.registradoEn,
  });

  factory RegistroDisp.fromJson(Map<String, dynamic> json) {
    return RegistroDisp(
      id: json['id'] as String,
      dispositivoId: json['dispositivoId'] as String,
      registradoEn: DateTime.parse(json['registradoEn'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dispositivoId': dispositivoId,
      'registradoEn': registradoEn.toIso8601String(),
    };
  }
}


