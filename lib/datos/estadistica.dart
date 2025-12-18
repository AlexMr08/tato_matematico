class EstadisticaSemanal {
  String id;
  int aciertos;
  int errores;
  int omisiones;
  late DateTime fecha;

  EstadisticaSemanal({
    required this.id,
    required this.aciertos,
    required this.errores,
    required this.omisiones,
  }) {
    try {
      List<String> partes = id.split('-');
      fecha = DateTime(
        int.parse(partes[0]), // año
        int.parse(partes[1]), // mes
        int.parse(partes[2]), // dia
      );
    } catch (e) {
      fecha = DateTime.now();
      print("Error parseando fecha del ID $id: $e");
    }
  }
}

class EstadisticaJuego {
  String juegoId;
  List<EstadisticaSemanal> estadisticasSemanales;

  EstadisticaJuego({
    required this.juegoId,
    required this.estadisticasSemanales,
  });

  factory EstadisticaJuego.fromMap(String id, Map<dynamic, dynamic> data) {
    List<EstadisticaSemanal> listaSemanas = [];

    //para cada hijo del mapa de data
    data.forEach((key, value) {
      final semanaData = Map<dynamic, dynamic>.from(value as Map);
      final semana = key;
      final aciertos = semanaData['aciertos'] ?? 0;
      final errores = semanaData['errores'] ?? 0;
      final omisiones = semanaData['omisiones'] ?? 0;
      listaSemanas.add(
        EstadisticaSemanal(
          id: semana,
          aciertos: aciertos,
          errores: errores,
          omisiones: omisiones,
        ),
      );
    });

    return EstadisticaJuego(estadisticasSemanales: listaSemanas, juegoId: id);
  }

  @override
  String toString() {
    return 'EstadisticaJuego{juegoId: $juegoId, estadisticasSemanales: $estadisticasSemanales}';
  }
}
