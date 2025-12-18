import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldComunV2.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/juego.dart';
import 'package:tato_matematico/juegos/juego2/juego2.dart';
import 'package:tato_matematico/juegos/juego2/juego2State.dart';
import 'package:tato_matematico/widgetsAuxiliares/tarjetaJuego.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

/// **Nombre de la Clase: `Juego2Screen**
///
/// **Descripción:** Clase que representa visualmente el segundo juego de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se ha creado la vista del profesor para el juego 2
///
class Juego2ScreenProfe extends StatefulWidget {
  final Juego juego;
  final Alumno alumno;
  const Juego2ScreenProfe({
    super.key,
    required this.juego,
    required this.alumno,
  });
  @override
  State<Juego2ScreenProfe> createState() => _Juego2ScreenProfeState();
}

class _Juego2ScreenProfeState extends State<Juego2ScreenProfe> {
  late Juego2State j2s;
  late Alumno alumno;
  late double size;
  late bool em;
  bool notInit = true;

  @override
  void initState() {
    super.initState();
    j2s = Juego2State(widget.juego as Juego2, widget.alumno);
    j2s.iniciarJuego();
    j2s.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    j2s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (notInit) {
      size = MediaQuery.sizeOf(context).width;
      em = size < 600;
      notInit = false;
    }

    final alumnoHolder = context.watch<AlumnoHolder>();
    final navigator = Navigator.of(context);
    if (alumnoHolder.alumno == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => navigator.pop());
      return const SizedBox.shrink();
    }
    alumno = alumnoHolder.alumno!;

    var colorTexto = Theme.of(context).colorScheme.onSurface;

    var imagenes = widget.juego.usaImagenes;
    var tipoImagen = widget.juego.tipoImagenes;

    double tamanoFichaArriba;
    double tamanoFichaAbajo;

    double espaciado = em ? 12.0 : 24.0;

    if (em) {
      tamanoFichaArriba = (size - espaciado * 3 - 16) / 4; // Aprox 70-80px
      if (tamanoFichaArriba > 90) tamanoFichaArriba = 90; // Límite máximo
      tamanoFichaAbajo = ((size - 16 - 20 - espaciado / 2 * 5) / 6);
    } else {
      tamanoFichaArriba = (size - espaciado * 7 - 16) / 8;
      tamanoFichaAbajo = ((size - 16 - 20 - espaciado / 2 * 11) / 12);
    }

    double fontSize = 24;

    double radioBordeArriba = tamanoFichaArriba * 0.15;
    double radioBordeAbajo = tamanoFichaAbajo * 0.15;

    return ScaffoldComunV2(
      titulo: "Juego 2 - Ordenar Números",
      cuerpo: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          spacing: 4,
          children: [
            // --- ZONA DE PROGRESO ---
            Semantics(
              label: j2s.getRepeticionesString(),
              excludeSemantics: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "REPETICIONES DEL JUEGO: ",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: colorTexto,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(j2s.repeticionesTotales, (index) {
                    bool completado = index < j2s.repeticionesCompletadas;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: Icon(
                          completado
                              ? Icons.emoji_emotions_rounded
                              : Icons.circle,
                          color: Colors.amberAccent,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // --- ZONA DE FICHAS DISPONIBLES ---
            Expanded(
              child: j2s.numeros.isNotEmpty
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.start,
                      spacing: espaciado,
                      runSpacing: espaciado,
                      children: j2s.numeros.map((numero) {
                        return TarjetaJuego(
                          key: ValueKey(numero),
                          tamano: tamanoFichaArriba,
                          label: "Mover $numero",
                          isButton: true,
                          isEnabled: !j2s.falloActual,
                          radio: radioBordeArriba,
                          // Llamada directa a la lógica
                          onTap: () => j2s.moverNumero(numero),
                          colorFondo:
                              alumno.colorBotones ??
                              Theme.of(context).colorScheme.primaryContainer,
                          imagenes: imagenes,
                          tipoImagen: tipoImagen,
                          numero: numero,
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Text(
                        "No quedan numeros",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: colorTexto,
                        ),
                      ),
                    ),
            ),

            Text(
              "Ordenados",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: colorTexto,
              ),
            ),

            // --- ZONA DE RESULTADO ---
            Container(
              decoration: BoxDecoration(
                color:
                    alumno.colorContenedor ??
                    Theme.of(context).colorScheme.surfaceContainer,
                border: Border.all(color: colorTexto, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                spacing: espaciado / 2,
                runSpacing: 0,
                children: j2s.numerosAbajo.map((numero) {
                  bool? estaBien;
                  if (numero != null) {
                    estaBien = j2s.estaNumeroBienPosicionado(numero);
                  }
                  return Column(
                    children: [
                      TarjetaJuego(
                        key: ValueKey(numero),
                        tamano: tamanoFichaAbajo,
                        radio: radioBordeAbajo,
                        label: () {
                          if (numero == null) return "Contenedor vacío";
                          if (j2s.estaNumeroBienPosicionado(numero)) {
                            return "$numero, correcto";
                          } else {
                            return "$numero, incorrecto";
                          }
                        }(),
                        isButton: numero != null && !estaBien!,
                        isEnabled: numero != null && !estaBien!,
                        onTap: () => numero != null
                            ? j2s.devolverNumero(
                                j2s.numerosAbajo.indexOf(numero),
                              )
                            : null,
                        colorFondo:
                            alumno.colorBotones ??
                            Theme.of(context).colorScheme.primaryContainer,
                        imagenes: imagenes,
                        tipoImagen: tipoImagen,
                        numero: numero,
                      ),
                      Icon(
                        numero != null
                            ? j2s.estaNumeroBienPosicionado(numero)
                                  ? Icons.check_circle
                                  : Icons.cancel
                            : null,
                        color: getTextColorForBackground(
                          alumno.colorContenedor ??
                              Theme.of(context).colorScheme.surfaceContainer,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            // --- BOTÓN ACEPTAR ---
            Align(
              alignment: Alignment.bottomRight,
              child: BotonSinIconoAlumno(
                texto: "Aceptar",
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                colorFondo: alumno.colorBotones,
                onPressed: j2s.finalizado
                    ? () {
                        bool fin = j2s.finalizarJuego(profe: true);
                        if (fin) {
                          mostrarDialogoSalirReiniciarAlumnoV2(
                            context,
                            "¿Quieres volver a jugar?",
                            "¿Quieres volver a jugar?, Si quieres volver a jugar pulsa en empezar de nuevo, si no, pulsa en volver al menú.",
                            alumno.colorFondo ??
                                Theme.of(context).colorScheme.surface,
                            alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                          ).then((onValue) {
                            if (onValue != null) {
                              if (onValue) {
                                j2s.reiniciarJuego();
                              } else {
                                navigator.pop();
                              }
                            }
                          });
                        } else {
                          mostrarDialogoSiguienteAlumnoV2(
                            context,
                            "Lo has hecho increíble!!!",
                            "Si quieres seguir jugando pulsa en siguiente",
                            alumno.colorFondo ??
                                Theme.of(context).colorScheme.surface,
                            alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                          ).then((onValue) {
                            if (onValue != null) {
                              if (onValue) {
                                j2s.iniciarJuego();
                              } else {
                                navigator.pop();
                              }
                            }
                          });
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
