class Pictograma {
  final String id;
  final String descripcion;
  final String url;
  final String categoria;

  Pictograma({
    required this.id,
    required this.descripcion,
    required this.url,
    required this.categoria,
  });

  factory Pictograma.fromMap(String key, Map<dynamic, dynamic> data) {
    return Pictograma(
      id: key,
      descripcion: data['descripcion'] ?? 'Sin descripcion',
      url: data['url'] ?? '',
      categoria: data['categoria'] ?? 'General',
    );
  }

  /// Helper para saber si es un pictograma válido o el fallback vacío
  bool get isEmpty => id.isEmpty && url.isEmpty;
}