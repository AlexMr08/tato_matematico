import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart'; // Import correcto raíz
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego_1/juego1.dart';
import 'package:tato_matematico/juegos/juego_1/juego1State.dart';
import 'package:tato_matematico/juegos/tarjetaJuego.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldAlumno.dart'; // Import correcto widgets
import 'package:tato_matematico/widgetsAuxiliares/botones.dart'; // Import correcto widgets

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
      final juego = context.read<AlumnoHolder>().listaJuegos["juego1"];
      if (alumno != null) {
        _state = Juego1State(alumno, juego as Juego1);
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
    // Inicialización de dimensiones (Idéntico a Juego 2)
    if (notInit) {
      size = MediaQuery.sizeOf(context).width;
      em = size < 600;
      notInit = false;
    }

    final alumno = context.watch<AlumnoHolder>().alumno;
    if (alumno == null || _state == null) return const SizedBox.shrink();

    final Color colorTexto = getTextColorForBackground(
        alumno.colorFondo ?? Theme.of(context).colorScheme.surface);

    // Tamaños responsivos consistentes con Juego 2
    double espaciado = em ? 12.0 : 24.0;
    // Cálculo para que quepan las opciones (3 en móvil, más en tablet)
    double tamanoFicha = em ? (size - 60) / 3 : (size - 100) / 5;
    if (tamanoFicha > 140) tamanoFicha = 140; // Límite máximo

    PosicionBarra posicionBarra = getPosicionBarra(alumno.posicionBarra);

    return ScaffoldAlumno(
      alumno: alumno,
      textoCabecera: "Encuentra el número",
      posicion: posicionBarra,
      hasAjustes: false, // Habilitamos botón ajustes
      hasEstadisticas: false,
      onVolver: () {
        mostrarDialogoSiNoAlumnoV2(
          context,
          "Salir",
          "¿Seguro que quieres salir?",
        ).then((confirmed) {
          if (confirmed == true) {
            _state!.salir();
            Navigator.pop(context);
          }
        });
      },
      onAjustes: () {
        // Navegación a ajustes (implementada más abajo)
        Navigator.pushNamed(context, '/juego1_ajustes');
      },
      onEstadisticas: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // --- BARRA DE PROGRESO Y REPRODUCCIÓN ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Botón Escuchar a la izquierda
                Semantics(
                  label: "Escuchar número objetivo",
                  child: ElevatedButton(
                    onPressed: _state!.speakObjetivo,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20), // Más grande
                      backgroundColor: alumno.colorBotones,
                      foregroundColor: getTextColorForBackground(
                          alumno.colorBotones ?? Theme.of(context).colorScheme.primary),
                    ),
                    child: const Icon(Icons.volume_up, size: 40), // Más grande
                  ),
                ),

                const Spacer(),

                // Contador de repeticiones en el centro
                Semantics(
                  label: _state!.getRepeticionesString(), // Accesibilidad
                  excludeSemantics: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "REPETICIONES: ",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorTexto,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(_state!.repeticionesTotales, (index) {
                        bool completado = index < _state!.repeticionesCompletadas;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Icon(
                              completado ? Icons.emoji_emotions : Icons.circle,
                              color: Colors.amberAccent,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const Spacer(),

                // Placeholder para centrar el contador.
                const SizedBox(width: 80),
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
                        label: alumno.juego1Settings.usarImagenes ? '' : numero.toString(), // Ocultar si hay imágenes
                        isButton: true,
                        // Deshabilitar interacción si ya terminó la ronda
                        isEnabled: !_state!.finalizado,
                        colorFondo: fondo,
                        imagenes: alumno.juego1Settings.usarImagenes,
                        tipoImagen: alumno.juego1Settings.tipoImagen,
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
                // Habilitado solo si hay selección y no ha terminado animación de éxito
                onPressed: (_state!.numeroSeleccionado != null && !_state!.finalizado)
                    ? () async {
                  bool acertado = await _state!.validarRespuesta();

                  if (acertado) {
                    // Pequeña pausa para ver el color verde antes del diálogo
                    await Future.delayed(const Duration(milliseconds: 800));

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
                    // El feedback de error (sonido) ya se maneja en el State.
                    // Aquí podrías añadir vibración o shake animation si quisieras.
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
