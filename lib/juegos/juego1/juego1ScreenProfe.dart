import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego1/juego1.dart';
import 'package:tato_matematico/juegos/juego1/juego1State.dart';
import 'package:tato_matematico/widgetsAuxiliares/tarjetaJuego.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldAlumno.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldComunV2.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

/// **Nombre de la Clase: `Juego1ScreenProfe**
///
/// **Descripción:** Clase usada para los ajustes del juego 1 en el profesor
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Rubi Rodríguez Anguita
/// * **Última modificación por:** Rubi Rodríguez Anguita
/// * **Fecha de modificación:** 18/12/2025
/// * **Último cambio:** Correccion del layout

class Juego1ScreenProfe extends StatefulWidget {
  const Juego1ScreenProfe({super.key});

  @override
  _Juego1ScreenProfeState createState() => _Juego1ScreenProfeState();
}

class _Juego1ScreenProfeState extends State<Juego1ScreenProfe> {
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
    if (notInit) {
      size = MediaQuery.sizeOf(context).width;
      em = size < 600;
      notInit = false;
    }

    final alumno = context.watch<AlumnoHolder>().alumno;
    // Usamos watch aquí para que si settings cambia el juego, se redibuje
    final juego = context.watch<AlumnoHolder>().listaJuegos["juego1"] as Juego1;

    if (alumno == null || _state == null) return const SizedBox.shrink();

    final Color colorTexto = getTextColorForBackground(
      alumno.colorFondo ?? Theme.of(context).colorScheme.surface,
    );

    double espaciado = em ? 12.0 : 24.0;
    double tamanoFicha = em ? (size - 60) / 3 : (size - 100) / 5;
    if (tamanoFicha > 140) tamanoFicha = 140;

    PosicionBarra posicionBarra = getPosicionBarra(alumno.posicionBarra);

    return ScaffoldComunV2(
      titulo: "Juego 1",
      cuerpo: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // --- BARRA SUPERIOR ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  label: "Escuchar número objetivo",
                  child: ElevatedButton.icon(
                    onPressed: _state!.speakObjetivo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          alumno.colorBotones ??
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: getTextColorForBackground(
                        alumno.colorBotones ??
                            Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.volume_up, size: 30),
                    label: const Text("Repetir Número"),
                  ),
                ),
                const Spacer(),
                Semantics(
                  label: _state!.getRepeticionesString(),
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      Text(
                        "REPETICIONES: ",
                        style: TextStyle(
                          fontSize: em ? 18 : 30, // Ajuste responsive
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...List.generate(_state!.repeticionesTotales, (index) {
                        bool completado =
                            index < _state!.repeticionesCompletadas;
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
                      bool isCorrectAndFinished =
                          _state!.finalizado &&
                          numero == _state!.numeroAAdivinar;

                      Color fondo = isSelected
                          ? (alumno.colorSeleccion ??
                                Theme.of(context).colorScheme.tertiaryContainer)
                          : (alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer);

                      if (isCorrectAndFinished) fondo = Colors.green;

                      return TarjetaJuego(
                        key: ValueKey(numero),
                        tamano: tamanoFicha,
                        radio: 20,
                        numero: numero,
                        label: numero.toString(),
                        isButton: true,
                        isEnabled: !_state!.finalizado,
                        colorFondo: fondo,
                        // Aquí es donde se aplican los cambios de ajustes
                        imagenes: juego.usaImagenes,
                        tipoImagen: juego.tipoImagenes,
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
                onPressed:
                    (_state!.numeroSeleccionado != null && !_state!.finalizado)
                    ? () async {
                        bool acertado = await _state!.validarRespuesta(
                          profe: true,
                        );
                        if (acertado) {
                          await Future.delayed(
                            const Duration(milliseconds: 800),
                          );
                          if (!mounted) return;

                          if (_state!.esFinDeJuego()) {
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
