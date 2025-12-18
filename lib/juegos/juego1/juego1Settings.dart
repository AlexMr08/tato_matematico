/// **Nombre de la Clase: `Juego1Settings**
///
/// **Descripción:** Clase usada para los ajustes del juego 1, proximamente deprecated
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Rubi Rodríguez Anguita
/// * **Última modificación por:** Rubi Rodríguez Anguita
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Creacion de la clase

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
