class Dashboard {
  final String id;
  final String titulo;
  final List<String> widgets;

  const Dashboard({
    required this.id,
    required this.titulo,
    required this.widgets,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      widgets: (json['widgets'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'widgets': widgets,
    };
  }
}


