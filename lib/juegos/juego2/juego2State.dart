import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/juegos/juego2/juego2.dart';

/// **Nombre de la Clase: `Juego2State**
///
/// **Descripción:** Clase que representa el estado de la partida actual del juego 2
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Se ha añadido un parametro en el finalizarJuego para diferenciar si lo llama el profe
///
class Juego2State with ChangeNotifier {
  final Juego2 juego;
  final Alumno alumno;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late List<int> numeros;
  late List<int?> numerosAbajo;
  late List<int> numerosOrdenados;

  int aciertos = 0;
  int errores = 0;

  int repeticionesTotales = 2;
  int repeticionesCompletadas = 0;

  bool falloActual = false;
  bool fallo = false;
  bool finalizado = false;

  Juego2State(this.juego, this.alumno);

  Future<void> _playSound(String? soundName) async {
    if (soundName == null || soundName.isEmpty) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      debugPrint("Error audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  bool estaNumeroBienPosicionado(int num) {
    bool res = false;
    res = numerosOrdenados.indexOf(num) == numerosAbajo.indexOf(num);
    return res;
  }

  void moverNumero(int numero) {
    if (!falloActual) {
      int indiceVacio = numerosAbajo.indexOf(null);
      if (indiceVacio != -1) {
        _playSound(alumno.sonidoEleccion);
        numerosAbajo[indiceVacio] = numero;
        numeros.remove(numero);

        if (numerosOrdenados[indiceVacio] != numero) {
          falloActual = true;
          if (!fallo) {
            fallo = true;
            errores += 1;
            _playSound(alumno.sonidoFallo);
          }
        } else {
          falloActual = false;
        }
        _verificarEstadoFinalizacion();
        notifyListeners();
      }
    }
  }

  void devolverNumero(int index) {
    int? numero = numerosAbajo[index];
    if (numero != null && numerosAbajo[index] != numerosOrdenados[index]) {
      _playSound(alumno.sonidoEleccion);
      numerosAbajo[index] = null;
      numeros.add(numero);
      falloActual = false;
      finalizado = false;
      notifyListeners();
    }
  }

  void _verificarEstadoFinalizacion() {
    if (!numerosAbajo.contains(null)) {
      bool correcto = true;
      for (int i = 0; i < numerosOrdenados.length; i++) {
        if (numerosAbajo[i] != numerosOrdenados[i]) {
          correcto = false;
          break;
        }
      }
      finalizado = correcto;
      if (finalizado) {
        _playSound(alumno.sonidoAcierto);
      }
    }
  }

  void iniciarJuego() {
    fallo = false;
    finalizado = false;
    numeros = juego.generarNuevoJuego();
    numerosAbajo = List.filled(juego.cantidad, null);
    numerosOrdenados = numeros.toList();
    numerosOrdenados.sort();
    if (juego.ordenDescendente) {
      numerosOrdenados = numerosOrdenados.reversed.toList();
    }

    notifyListeners();
  }

  void reiniciarJuego() {
    repeticionesCompletadas = 0;
    aciertos = 0;
    errores = 0;
    iniciarJuego();
  }

  bool finalizarJuego({bool profe = false}) {
    aciertos += 1;
    repeticionesCompletadas += 1;

    bool juegoTerminado = todasLasRepeticionesHechas();

    if (juegoTerminado && !profe) {
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