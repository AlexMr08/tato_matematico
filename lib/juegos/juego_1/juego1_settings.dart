class Juego1Settings {
  int numeroOpciones;
  int numeroMayor;
  int numeroMenor;
  bool usarImagenes; // <-- AÑADIDO
  String tipoImagen;   // <-- AÑADIDO

  Juego1Settings({
    required this.numeroOpciones,
    required this.numeroMayor,
    required this.numeroMenor,
    this.usarImagenes = false, // Valor por defecto
    this.tipoImagen = 'pictogramas', // Valor por defecto
  });

  Map<String, dynamic> toMap() {
    return {
      'numeroOpciones': numeroOpciones,
      'numeroMayor': numeroMayor,
      'numeroMenor': numeroMenor,
      'usarImagenes': usarImagenes,
      'tipoImagen': tipoImagen,
    };
  }
}
