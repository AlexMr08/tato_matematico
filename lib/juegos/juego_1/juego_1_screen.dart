import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart'; // Importante para sonidos
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';

// Definición de Settings si no está en otro archivo importado
class Juego1Settings {
  int numeroOpciones;
  int numeroMayor;
  int numeroMenor;

  Juego1Settings({
    required this.numeroOpciones,
    required this.numeroMayor,
    required this.numeroMenor,
  });

  Map<String, int> toMap() {
    return {
      'numeroOpciones': numeroOpciones,
      'numeroMayor': numeroMayor,
      'numeroMenor': numeroMenor,
    };
  }
}

class Juego1Screen extends StatefulWidget {
  const Juego1Screen({Key? key}) : super(key: key);

  @override
  _Juego1ScreenState createState() => _Juego1ScreenState();
}

class _Juego1ScreenState extends State<Juego1Screen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer(); // Player para efectos

  late Alumno _alumno;
  int _puntuacion = 0;

  late Juego1Settings _settings;
  late int _numeroAAdivinar;
  late List<int> _opciones = [];
  int? _numeroSeleccionado;
  bool _isLoading = true;
  bool _mostrarPuntuacion = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _setupTts() async {
    // Usamos las configuraciones globales de TTS del alumno
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(_alumno.ttsRate);
    await _flutterTts.setVolume(_alumno.ttsVolume);
    await _flutterTts.setPitch(_alumno.ttsPitch);
    // Si quisieras usar la voz específica antigua:
    // if (_alumno.vozJuego1 != null) { ... }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Función auxiliar para reproducir los sonidos configurados
  Future<void> _playSound(String? soundName) async {
    if (soundName == null || soundName.isEmpty) return;
    try {
      // Asume que los archivos están en assets/sounds/{nombre}.mp3
      // Coincidiendo con la lógica de ajustes_sonidos_screen.dart
      await _audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      print("Error reproduciendo sonido: $e");
    }
  }

  Future<void> _loadInitialData() async {
    final alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno;
    if (alumno == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    _alumno = alumno;
    _settings = _alumno.juego1Settings;
    _mostrarPuntuacion = _alumno.mostrarPuntuacionJuego1;

    await _setupTts();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _generarNuevoJuego();
    }
  }

  void _generarNuevoJuego() {
    if (_isLoading) return;

    final random = Random();
    // Asegurar rango válido
    int rango = _settings.numeroMayor - _settings.numeroMenor;
    if (rango <= 0) rango = 1;

    _numeroAAdivinar = _settings.numeroMenor + random.nextInt(rango + 1);

    final Set<int> opcionesTemporales = {_numeroAAdivinar};

    // Evitar bucle infinito si hay menos opciones posibles que las solicitadas
    int maxPosibles = _settings.numeroMayor - _settings.numeroMenor + 1;
    int cantidadAObtener = min(_settings.numeroOpciones, maxPosibles);

    while (opcionesTemporales.length < cantidadAObtener) {
      final nuevaOpcion = _settings.numeroMenor + random.nextInt(rango + 1);
      opcionesTemporales.add(nuevaOpcion);
    }

    setState(() {
      _opciones = opcionesTemporales.toList()..shuffle();
      _numeroSeleccionado = null;
    });

    _speak(_numeroAAdivinar.toString());
  }

  void _aceptarRespuesta() {
    if (_numeroSeleccionado == null) {
      // Opcional: Sonido de error leve o feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un número.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    bool esCorrecto = _numeroSeleccionado == _numeroAAdivinar;

    if (esCorrecto) {
      if (_alumno.sonidoAciertoActivado) {
        _playSound(_alumno.sonidoAcierto);
      }
      snackBarExito(context, "¡Correcto!");
      setState(() {
        _puntuacion++;
      });
    } else {
      if (_alumno.sonidoFalloActivado) {
        _playSound(_alumno.sonidoFallo);
      }
      snackBarError(context, "Incorrecto. Prueba de nuevo.");
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && esCorrecto) {
        _generarNuevoJuego();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor =
        _alumno.colorBotones ?? Theme.of(context).colorScheme.secondary;
    final Color fondoColor =
        _alumno.colorFondo ?? Theme.of(context).colorScheme.surface;
    final Color backgroundTextColor = getTextColorForBackground(fondoColor);
    final Color buttonTextColor = getTextColorForBackground(buttonColor);
    final Color selectedButtonBorderColor =
        _alumno.colorSeleccion ?? Theme.of(context).colorScheme.secondary;

    // Estilo para el botón de escuchar
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: buttonTextColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );

    PosicionBarra posicionBarra = switch (_alumno.posicionBarra) {
      0 => PosicionBarra.arriba,
      1 => PosicionBarra.abajo,
      2 => PosicionBarra.izquierda,
      3 => PosicionBarra.derecha,
      _ => PosicionBarra.abajo,
    };

    return ScaffoldAlumno(
      posicion: posicionBarra,
      textoCabecera: "Encuentra el número", // Texto más corto
      alumno: _alumno,
      onVolver: Navigator.of(context).pop,
      onAjustes: () {}, // Opcional: navegar a ajustes
      onEstadisticas: () {},
      hasAjustes: false,
      hasEstadisticas: false,
      // Botón flotante para Aceptar, posición estándar
      floatingActionButton: FloatingActionButton(
        onPressed: _aceptarRespuesta,
        backgroundColor: buttonColor,
        child: Icon(Icons.check, size: 35, color: buttonTextColor),
      ),
      child: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
        ),
      )
          : Column(
        children: [
          // Cabecera con puntuación y repetición de audio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_mostrarPuntuacion)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(
                      'Puntos: $_puntuacion',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Spacer(),

                ElevatedButton.icon(
                  style: buttonStyle,
                  onPressed: () => _speak(_numeroAAdivinar.toString()),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Escuchar'),
                ),
              ],
            ),
          ),

          // Área de juego
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _opciones.length,
                itemBuilder: (context, index) {
                  final numero = _opciones[index];
                  final bool isSelected = numero == _numeroSeleccionado;

                  // Color visual
                  final Color cardColor = isSelected
                      ? Color.alphaBlend(Colors.white.withOpacity(0.3), buttonColor)
                      : buttonColor;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _numeroSeleccionado = numero);
                      // Reproducir sonido de elección (click) si está configurado
                      if (_alumno.sonidoEleccion != null) {
                        _playSound(_alumno.sonidoEleccion);
                      }
                    },
                    child: Card(
                      color: cardColor,
                      elevation: isSelected ? 10 : 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? selectedButtonBorderColor
                              : Colors.transparent,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AutoSizeText(
                            numero.toString(),
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: getTextColorForBackground(cardColor),
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Espacio extra para el FAB
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}