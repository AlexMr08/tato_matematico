import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/juegos/juego_1/juego1.dart';
import 'package:tato_matematico/juegos/juego_1/juego1_settings.dart';

class Juego1State with ChangeNotifier {
  final Alumno alumno;
  final Juego1 juego;

  // Audio
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Variables de Juego
  late int numeroAAdivinar;
  List<int> opciones = [];
  int? numeroSeleccionado;

  // Estadísticas y Progreso
  int aciertos = 0;
  int errores = 0;
  int repeticionesTotales = 5; // Configurable igual que en Juego 2
  int repeticionesCompletadas = 0;

  bool falloActual = false; // Si ha fallado en la ronda actual
  bool finalizado = false; // Ronda terminada (listo para aceptar/siguiente)

  Juego1State(this.alumno, this.juego);

  Future<void> init() async {
    await _setupTts();
    iniciarRonda();
  }

  Future<void> _setupTts() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(alumno.ttsRate);
    await _flutterTts.setVolume(alumno.ttsVolume);
    await _flutterTts.setPitch(alumno.ttsPitch);
  }

  void iniciarRonda() {
    Juego1Settings juego1Settings = Juego1Settings(
      numeroOpciones: juego.cantidad,
      numeroMayor: juego.max,
      numeroMenor: juego.min,
    );

    final settings = juego1Settings;

    final random = Random();

    // Calcular rango seguro
    int rango = settings.numeroMayor - settings.numeroMenor;
    if (rango <= 0) rango = 1;

    // Generar objetivo
    numeroAAdivinar = settings.numeroMenor + random.nextInt(rango + 1);

    // Generar opciones (incluyendo el objetivo)
    final Set<int> opcionesSet = {numeroAAdivinar};
    int maxPosibles = settings.numeroMayor - settings.numeroMenor + 1;
    int cantidad = min(settings.numeroOpciones, maxPosibles);

    while (opcionesSet.length < cantidad) {
      opcionesSet.add(settings.numeroMenor + random.nextInt(rango + 1));
    }

    opciones = opcionesSet.toList()..shuffle();
    numeroSeleccionado = null;
    falloActual = false;
    finalizado = false;

    notifyListeners();
    speakObjetivo();
  }

  void seleccionarNumero(int numero) {
    if (finalizado) return; // Bloquear si ya acertó

    numeroSeleccionado = numero;

    // Feedback sonoro de elección (click)
    if (alumno.sonidoEleccion != null) {
      _playSound(alumno.sonidoEleccion);
    }

    notifyListeners();
  }

  /// Retorna true si ha acertado, false si ha fallado
  Future<bool> validarRespuesta() async {
    if (numeroSeleccionado == null) return false;

    bool esCorrecto = numeroSeleccionado == numeroAAdivinar;

    if (esCorrecto) {
      finalizado = true;
      if (!falloActual) aciertos++; // Solo suma acierto si lo hizo a la primera

      repeticionesCompletadas++;

      if (alumno.sonidoAciertoActivado) {
        await _playSound(alumno.sonidoAcierto);
      }

      notifyListeners();
      return true;
    } else {
      if (!falloActual) {
        errores++;
        falloActual = true; // Marca que esta ronda ya tuvo un fallo
      }
      if (alumno.sonidoFalloActivado) {
        await _playSound(alumno.sonidoFallo);
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> speakObjetivo() async {
    await _flutterTts.speak(numeroAAdivinar.toString());
  }

  Future<void> _playSound(String? soundName) async {
    if (soundName == null || soundName.isEmpty) return;
    try {
      await _audioPlayer.stop();
      // Asumiendo estructura estándar de assets
      await _audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      debugPrint("Error audio: $e");
    }
  }

  void reiniciarJuego() {
    aciertos = 0;
    errores = 0;
    repeticionesCompletadas = 0;
    iniciarRonda();
  }

  bool esFinDeJuego() {
    return repeticionesCompletadas >= repeticionesTotales;
  }

  String getRepeticionesString() {
    return "Repeticiones completadas: $repeticionesCompletadas de $repeticionesTotales";
  }

  /// Método para guardar estadísticas (similar a Juego 2)
  void salir() {
    // Aquí iría la llamada a subirEstadisticas si fuera necesario
    // juego.subirEstadisticas(...)
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}
