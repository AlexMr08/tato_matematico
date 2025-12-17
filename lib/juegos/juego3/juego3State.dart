import 'package:flutter/material.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/juegos/juego3/juego3.dart';
/// **Nombre de la Clase: `Juego3State**
///
/// **Descripción:** Clase que representa el estado de la partida actual del juego 3
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Andrés Ignacio Mardones Domcke
/// * **Última modificación por:** Andrés Ignacio Mardones Domcke
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Arreglos en la verificación de la solución (solo marcar contenedores incorrectos)
///
class Juego3State with ChangeNotifier {
  final Juego3 juego;
  final Alumno alumno;

  late List<int> numeros;
  late List<List<int?>> contenedores;
  late List<List<int>> soluciones;
  List<int> contenedoresIncorrectos = [];

  int aciertos = 0;
  int errores = 0;

  int repeticionesTotales = 2;
  int repeticionesCompletadas = 0;

  bool falloActual = false;
  bool fallo = false;
  bool finalizado = false;

  Juego3State(this.juego, this.alumno);

  void moverNumero(List<int>? numero, int contenedorIndex, int slotIndex) {
    contenedores[contenedorIndex][slotIndex] = numero![0];
    numeros.removeAt(numero[1]);
    notifyListeners();
  }

  void devolverNumero(int numIndex, int contenedorIndex) {
    int? numero = contenedores[contenedorIndex][numIndex];
    if (numero != null) {
      contenedores[contenedorIndex][numIndex] = null;
      numeros.add(numero);
      notifyListeners();
    }
  }

 bool verificarSolucion(List<List<int?>> contenedores, List<List<int>> soluciones) {
      // Normalizar soluciones (ordenadas)
    List<List<int>> solucionesNorm =
        soluciones.map((c) => List<int>.from(c)..sort()).toList();

    // Contar multiplicidad de soluciones
    Map<String, int> disponibles = {};
    for (var sol in solucionesNorm) {
      final key = sol.join(',');
      disponibles[key] = (disponibles[key] ?? 0) + 1;
    }

    List<int> incorrectos = [];

    for (int i = 0; i < contenedores.length; i++) {
      final cont = contenedores[i];

      // 🔑 Ignorar null
      final valores =
          cont.whereType<int>().toList()..sort();

      final key = valores.join(',');

      if (disponibles.containsKey(key) &&
          disponibles[key]! > 0) {
        disponibles[key] = disponibles[key]! - 1;
      } else {
        incorrectos.add(i);
      }
    }
    contenedoresIncorrectos = incorrectos;
    return incorrectos.isEmpty;
  }

  void iniciarJuego() {
    fallo = false;
    finalizado = false;
    soluciones = juego.generarNuevoJuego();
    numeros = soluciones.expand((x) => x).toList();
    numeros.shuffle();
    contenedores = List.generate(
      juego.cantContenedores,
      (_) => List.filled(juego.cantidad, null),
    );

    notifyListeners();
  }

  void reiniciarJuego() {
    repeticionesCompletadas = 0;
    aciertos = 0;
    errores = 0;
    iniciarJuego();
  }

  bool finalizarJuego(bool esCorrecto) {
    bool juegoTerminado = false;
    if (esCorrecto) {
      aciertos += 1;
      repeticionesCompletadas += 1;
      juegoTerminado = todasLasRepeticionesHechas();
    }
     else {
      if(errores < 1){
        errores += 1;
      }
     }
    if (juegoTerminado) {
      juego.subirEstadisticas(
        aciertos: aciertos,
        errores: errores,
        omisiones: 0,
        alumno: alumno,
      );

      aciertos = 0;
      errores = 0;
    }

    notifyListeners();
    return juegoTerminado;
  }

  /// Acción de salir (guardar progreso parcial si es necesario)
  void salir() {
    juego.subirEstadisticas(
      aciertos: aciertos,
      errores: errores,
      alumno: alumno,
      omisiones: repeticionesTotales - repeticionesCompletadas,
    );
  }

  bool todasLasRepeticionesHechas() {
    return repeticionesCompletadas >= repeticionesTotales;
  }

  String getRepeticionesString() {
    return "Progreso: $repeticionesCompletadas de $repeticionesTotales";
  }
}