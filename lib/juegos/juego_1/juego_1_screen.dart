import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego_1/juego_1_ajustes_screen.dart';

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

  Future<void> _setupTts() async {
    _alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno!;
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(_alumno.ttsRateJuego1);
    await _flutterTts.setVolume(_alumno.ttsVolumeJuego1);
    await _flutterTts.setPitch(_alumno.ttsPitchJuego1);
    if (_alumno.vozJuego1 != null) {
      await _flutterTts.setVoice({"name": _alumno.vozJuego1!});
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
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
    _numeroAAdivinar =
        _settings.numeroMenor +
        random.nextInt(_settings.numeroMayor - _settings.numeroMenor + 1);

    final Set<int> opcionesTemporales = {_numeroAAdivinar};
    while (opcionesTemporales.length <
        min(
          _settings.numeroOpciones,
          (_settings.numeroMayor - _settings.numeroMenor + 1),
        )) {
      final nuevaOpcion =
          _settings.numeroMenor +
          random.nextInt(_settings.numeroMayor - _settings.numeroMenor + 1);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un número.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 20, 20, 100),
        ),
      );
      return;
    }

    bool esCorrecto = _numeroSeleccionado == _numeroAAdivinar;

    if (esCorrecto && _alumno.sonidoAciertoActivadoJuego1) {
      // TODO: Play sound
    } else if (!esCorrecto && _alumno.sonidoFalloActivadoJuego1) {
      // TODO: Play sound
    }

    if (esCorrecto) {
      snackBarExito(context, "¡Correcto!");
    } else {
      snackBarError(context, "Incorrecto. Prueba de nuevo.");
    }

    if (esCorrecto) {
      setState(() {
        _puntuacion++;
      });
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        _generarNuevoJuego();
      }
    });
  }

  void _navegarAjustes() async {
    final resultado = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Juego1AjustesScreen(
          initialSettings: _settings,
          initialMostrarPuntuacion: _mostrarPuntuacion,
        ),
      ),
    );

    if (resultado is Map && mounted) {
      final newSettings = resultado['settings'] as Juego1Settings?;
      final newMostrarPuntuacion = resultado['mostrarPuntuacion'] as bool?;

      if (newSettings != null && newMostrarPuntuacion != null) {
        try {
          await _dbRef
              .child('tato/alumnos/${_alumno.id}/juego1Settings')
              .set(newSettings.toMap());
          await _dbRef.child('tato/alumnos/${_alumno.id}').update({
            'mostrarPuntuacionJuego1': newMostrarPuntuacion,
          });

          setState(() {
            _settings = newSettings;
            _mostrarPuntuacion = newMostrarPuntuacion;
            _puntuacion = 0;
          });
          _generarNuevoJuego();
        } catch (e) {
          // Handle error
        }
      }
    } else if (resultado == true && mounted) {
      await _loadInitialData();
    }
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

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: buttonTextColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      alumno: _alumno,
      onVolver: Navigator.of(context).pop,
      onAjustes: _navegarAjustes,
      onEstadisticas: () {},
      hasAjustes: _alumno.permisoAjustesJuego1,
      hasEstadisticas: _alumno.permisoEstadisticasJuego1,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_mostrarPuntuacion)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Puntuación: $_puntuacion',
                      style: TextStyle(
                        color: backgroundTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  style: buttonStyle,
                  onPressed: () => _speak(_numeroAAdivinar.toString()),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Volver a escuchar'),
                ),
                SizedBox(height:8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200, // Aumenta el tamaño máximo
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1, // Proporción más ancha
                          ),
                      itemCount: _opciones.length,
                      itemBuilder: (context, index) {
                        final numero = _opciones[index];
                        final bool isSelected = numero == _numeroSeleccionado;
                        final Color cardColor = isSelected
                            ? Color.alphaBlend(Colors.white, buttonColor)
                            : buttonColor;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _numeroSeleccionado = numero),
                          child: Card(
                            color: cardColor,
                            elevation: isSelected ? 12 : 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? selectedButtonBorderColor
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: AutoSizeText(
                                  numero.toString(),
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? getTextColorForBackground(cardColor)
                                        : buttonTextColor,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 8,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: _aceptarRespuesta,
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
    );
  }
}
