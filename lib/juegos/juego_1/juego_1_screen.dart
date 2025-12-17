import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego_1/juego1State.dart';
import 'package:tato_matematico/juegos/tarjetaJuego.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldAlumno.dart'; // Asegúrate que es el nuevo
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

// Definición de Settings (Mantenemos la clase aquí o en un archivo común)
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
  Juego1State? _state;
  late double size;
  late bool em; // Es móvil
  bool notInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_state == null) {
      final alumno = context.read<AlumnoHolder>().alumno;
      if (alumno != null) {
        _state = Juego1State(alumno, onGameEnd: () {});
        _state!.init();
        _state!.addListener(() {
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _state?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inicialización de dimensiones
    if (notInit) {
      size = MediaQuery.sizeOf(context).width;
      em = size < 600;
      notInit = false;
    }

    final alumno = context.watch<AlumnoHolder>().alumno;
    if (alumno == null || _state == null) return const SizedBox.shrink();

    final Color colorTexto = getTextColorForBackground(
        alumno.colorFondo ?? Theme.of(context).colorScheme.surface);

    // Tamaños responsivos
    double espaciado = em ? 12.0 : 24.0;
    // Cálculo para que quepan las opciones configuradas
    double tamanoFicha = em ? (size - 60) / 3 : (size - 100) / 5;
    if (tamanoFicha > 140) tamanoFicha = 140; // Límite máximo

    PosicionBarra posicionBarra = getPosicionBarra(alumno.posicionBarra);

    return ScaffoldAlumno(
      alumno: alumno,
      textoCabecera: "Encuentra el número",
      posicion: posicionBarra,
      hasAjustes: false, // O true si quieres navegar a los ajustes desde aquí
      hasEstadisticas: false,
      onVolver: () {
        mostrarDialogoSiNoAlumnoV2(
          context,
          "Salir",
          "¿Seguro que quieres salir?",
        ).then((confirmed) {
          if (confirmed == true) {
            Navigator.pop(context);
          }
        });
      },
      onAjustes: () {},
      onEstadisticas: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // --- BARRA DE PROGRESO Y REPRODUCCIÓN ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Repeticiones (Estilo Juego 2)
                ...List.generate(_state!.repeticionesTotales, (index) {
                  bool completado = index < _state!.repeticionesCompletadas;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      width: em ? 20 : 30,
                      height: em ? 20 : 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black12,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: completado
                          ? Icon(Icons.star,
                          size: em ? 16 : 24, color: Colors.amber)
                          : null,
                    ),
                  );
                }),
                const Spacer(),
                // Botón Escuchar Número
                ElevatedButton.icon(
                  onPressed: _state!.speakObjetivo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alumno.colorBotones,
                    foregroundColor: getTextColorForBackground(alumno.colorBotones),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.volume_up),
                  label: Text(
                      _state!.numeroAAdivinar.toString(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // --- GRID DE OPCIONES ---
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: espaciado,
                    runSpacing: espaciado,
                    children: _state!.opciones.map((numero) {
                      bool isSelected = _state!.numeroSeleccionado == numero;

                      // Si ya acertó y este es el correcto, mostrarlo verde/éxito
                      bool isCorrectAndFinished = _state!.finalizado && numero == _state!.numeroAAdivinar;

                      Color fondo = isSelected
                          ? (alumno.colorSeleccion ?? Colors.blueAccent)
                          : (alumno.colorBotones ?? Colors.blue);

                      if (isCorrectAndFinished) fondo = Colors.green;

                      return TarjetaJuego(
                        key: ValueKey(numero),
                        tamano: tamanoFicha,
                        radio: 20,
                        numero: numero,
                        label: numero.toString(),
                        isButton: true,
                        // Deshabilitar interacción si ya terminó la ronda
                        isEnabled: !_state!.finalizado,
                        colorFondo: fondo,
                        imagenes: false, // Juego 1 es solo números por defecto
                        tipoImagen: "",
                        onTap: () => _state!.seleccionarNumero(numero),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // --- BOTÓN ACEPTAR ---
            Align(
              alignment: Alignment.bottomRight,
              child: BotonSinIconoAlumno(
                texto: "Aceptar",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                colorFondo: alumno.colorBotones,
                // Habilitado solo si hay selección
                onPressed: (_state!.numeroSeleccionado != null && !_state!.finalizado)
                    ? () async {
                  bool acertado = await _state!.validarRespuesta();

                  if (acertado) {
                    // Esperar un momento para ver el feedback visual (verde)
                    await Future.delayed(const Duration(seconds: 1));

                    if (!mounted) return;

                    if (_state!.esFinDeJuego()) {
                      // --- FIN DEL JUEGO COMPLETO ---
                      mostrarDialogoSalirReiniciarAlumnoV2(
                        context,
                        "¡Juego Completado!",
                        "Has encontrado todos los números. ¿Quieres jugar otra vez?",
                        alumno.colorFondo ?? Colors.white,
                        alumno.colorBotones ?? Colors.blue,
                      ).then((reiniciar) {
                        if (reiniciar == true) {
                          _state!.reiniciarJuego();
                        } else if (reiniciar == false) {
                          Navigator.pop(context);
                        }
                      });
                    } else {
                      // --- SIGUIENTE RONDA ---
                      mostrarDialogoSiguienteAlumnoV2(
                        context,
                        "¡Muy bien!",
                        "¡Correcto! Vamos a por el siguiente.",
                        alumno.colorFondo ?? Colors.white,
                        alumno.colorBotones ?? Colors.blue,
                      ).then((siguiente) {
                        if (siguiente == true) {
                          _state!.iniciarRonda();
                        } else {
                          Navigator.pop(context);
                        }
                      });
                    }
                  } else {
                    // Feedback de error ya manejado por el estado (sonido)
                    // Aquí podrías mostrar un SnackBar si quisieras
                  }
                }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}