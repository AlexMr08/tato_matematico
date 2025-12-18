import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldAlumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/juego.dart';
import 'package:tato_matematico/juegos/tarjetaJuego.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';
import 'package:tato_matematico/juegos/juego3/juego3State.dart';
import 'package:tato_matematico/juegos/juego3/juego3.dart';

/// **Nombre de la Clase: `Juego3Screen**
///
/// **Descripción:** Clase que representa visualmente el tercer juego de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Andrés Ignacio Mardones Domcke
/// * **Última modificación por:** Andrés Ignacio Mardones Domcke
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Tamaños dinámicos de tarjetas y contenedores
///
class Juego3Screen extends StatefulWidget {
  final Juego juego;
  final Alumno alumno;
  const Juego3Screen({super.key, required this.juego, required this.alumno});
  @override
  State<Juego3Screen> createState() => _Juego3ScreenState();
}

class _Juego3ScreenState extends State<Juego3Screen> {
  late Juego3State j3s;
  late Alumno alumno;
  List<int>? numeroSeleccionado;
  bool mostrarIncorrectos = false;
  late int numeroARepartir;

  @override
  void initState() {
    super.initState();
    j3s = Juego3State(widget.juego as Juego3, widget.alumno);
    j3s.iniciarJuego();
    j3s.addListener(() {
      if (mounted) setState(() {});
    });
    numeroARepartir = j3s.soluciones[0].reduce((a, b) => a + b);
  }

  @override
  void dispose() {
    j3s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = context.watch<AlumnoHolder>();
    final navigator = Navigator.of(context);

    if (alumnoHolder.alumno == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => navigator.pop());
      return const SizedBox.shrink();
    }
    alumno = alumnoHolder.alumno!;

    PosicionBarra posicionBarra = getPosicionBarra(alumno.posicionBarra);

    var colorTexto = alumno.colorFondo != null
        ? getTextColorForBackground(alumno.colorFondo!)
        : Theme.of(context).colorScheme.onSurface;

    var imagenes = widget.juego.usaImagenes;
    var tipoImagen = widget.juego.tipoImagenes;

    final double tamanoBote = j3s.contenedores.length > 3 ? 250.0 : 300.0;
    final double paddingInterior = tamanoBote * 0.12;

    final int totalSlots = j3s.contenedores[0].length;
    final int columnas = totalSlots <= 6 ? 2 : 3;

    final double espacio = 5.0;

    // tamaño base de tarjeta (puede ajustarse)
    final double tamanoTarjeta = columnas == 2 ? 70.0 : 60.0;

    // ancho EXACTO necesario para forzar columnas
    final double anchoInterior =
        columnas * tamanoTarjeta + (columnas - 1) * espacio;

    return ScaffoldAlumno(
      alumno: alumno,
      textoCabecera: "Reparte el número $numeroARepartir en cada recipiente",
      posicion: posicionBarra,
      hasEstadisticas: false,
      hasAjustes: false,
      onVolver: () {
        mostrarDialogoSiNoAlumnoV2(
          context,
          "Salir",
          "¿Seguro que quieres salir?",
        ).then((confirmed) {
          if (confirmed == true) {
            j3s.salir();
            navigator.pop();
          }
        });
      },
      onAjustes: () {},
      onEstadisticas: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            // --- ZONA DE PROGRESO ---
            Semantics(
              label: j3s.getRepeticionesString(),
              excludeSemantics: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "REPETICIONES DEL JUEGO: ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorTexto,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(j3s.repeticionesTotales, (index) {
                    bool completado = index < j3s.repeticionesCompletadas;
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
              child: j3s.numeros.isNotEmpty
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.start,
                      spacing: 16,
                      runSpacing: 24,
                      children: j3s.numeros
                          .asMap()
                          .map(
                            (index, numero) => MapEntry(
                              index,
                              TarjetaJuego(
                                tamano: 110,
                                label: "Mover $numero",
                                isButton: true,
                                isEnabled: true,
                                radio: 16,
                                onTap: () {
                                  if (numeroSeleccionado != null &&
                                      numeroSeleccionado![1] == index) {
                                    setState(() {
                                      numeroSeleccionado = null;
                                    });
                                    return;
                                  }
                                  setState(() {
                                    numeroSeleccionado = [numero, index];
                                  });
                                },
                                colorFondo: numeroSeleccionado != null
                                    ? (numeroSeleccionado![1] == index
                                          ? alumno.colorSeleccion ??
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiaryContainer
                                          : alumno.colorBotones ??
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primaryContainer)
                                    : alumno.colorBotones ??
                                          Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                imagenes: imagenes,
                                tipoImagen: tipoImagen,
                                numero: numero,
                              ),
                            ),
                          )
                          .values
                          .toList(),
                    )
                  : Center(
                      child: Text(
                        "No quedan números",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorTexto,
                        ),
                      ),
                    ),
            ),

            // --- ZONA DE RESULTADO ---
            Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              spacing: 24,
              runSpacing: 24,
              children: j3s.contenedores.map((contenedor) {
                final indexContenedor = j3s.contenedores.indexOf(contenedor);
                return Column(
                  children: [
                    Semantics(
                      label:
                          "Contenedor ${indexContenedor + 1}, con números ${contenedor.whereType<int>().join(', ')}",
                      button: true,
                      enabled: true,
                      excludeSemantics: true,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          if (numeroSeleccionado == null) return;
                          j3s.moverNumero(
                            numeroSeleccionado,
                            indexContenedor,
                            contenedor.indexOf(null),
                          );
                          setState(() {
                            numeroSeleccionado = null;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                alumno.colorContenedor ??
                                Theme.of(context).colorScheme.surfaceContainer,
                            border: Border.all(color: colorTexto, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // --- IMAGEN DEL CONTENEDOR ---
                              Container(
                                width: tamanoBote,
                                height: tamanoBote,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/bote.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              // --- SLOTS DENTRO DEL CONTENEDOR ---
                              Positioned(
                                top: paddingInterior + 40,
                                child: SizedBox(
                                  width:
                                      anchoInterior, // límite interior del bote
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: espacio,
                                    runSpacing: espacio,
                                    children: contenedor.asMap().entries.map((
                                      entry,
                                    ) {
                                      final indexSlot =
                                          entry.key; // índice REAL del slot
                                      final numero =
                                          entry.value; // valor del slot

                                      return numero != null
                                          ? TarjetaJuego(
                                              tamano: tamanoTarjeta,
                                              label:
                                                  "$numero en contenedor ${indexContenedor + 1}",
                                              isButton: true,
                                              isEnabled: true,
                                              radio: 8,
                                              onTap: () {
                                                // Cambiar una carta por otra
                                                if (numeroSeleccionado !=
                                                    null) {
                                                  j3s.devolverNumero(
                                                    indexSlot,
                                                    indexContenedor,
                                                  );
                                                  j3s.moverNumero(
                                                    numeroSeleccionado,
                                                    indexContenedor,
                                                    indexSlot,
                                                  );
                                                  setState(() {
                                                    numeroSeleccionado = null;
                                                  });
                                                }
                                                // Devolver carta al área de números
                                                else {
                                                  j3s.devolverNumero(
                                                    indexSlot,
                                                    indexContenedor,
                                                  );
                                                  if (mostrarIncorrectos) {
                                                    setState(() {
                                                      mostrarIncorrectos =
                                                          false;
                                                    });
                                                  }
                                                }
                                              },
                                              colorFondo:
                                                  alumno.colorBotones ??
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                              imagenes: imagenes,
                                              tipoImagen: tipoImagen,
                                              numero: numero,
                                            )
                                          : SizedBox(
                                              width: tamanoTarjeta,
                                              height: tamanoTarjeta,
                                            );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Indicador de incorrecto
                    mostrarIncorrectos
                        ? j3s.contenedoresIncorrectos.contains(indexContenedor)
                              ? Icon(
                                  Icons.cancel,
                                  size: 50,
                                  color: getTextColorForBackground(
                                    alumno.colorFondo ??
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                )
                              : Icon(
                                  Icons.check_circle,
                                  size: 50,
                                  color: getTextColorForBackground(
                                    alumno.colorFondo ??
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                )
                        : SizedBox(height: 1),
                  ],
                );
              }).toList(),
            ),
            // --- BOTÓN ACEPTAR ---
            Align(
              alignment: Alignment.bottomRight,
              child: BotonSinIconoAlumno(
                texto: "Aceptar",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                colorFondo: alumno.colorBotones,
                onPressed: j3s.numeros.isEmpty
                    ? () {
                        bool esCorrecto = j3s.verificarSolucion(
                          j3s.contenedores,
                          j3s.soluciones,
                        );
                        bool juegoTerminado = j3s.finalizarJuego(esCorrecto);
                        if (!esCorrecto) {
                          mostrarIncorrectos = true;
                        } else if (juegoTerminado) {
                          // -- DIÁLOGOS FINALIZACIÓN --
                          mostrarDialogoSalirReiniciarAlumnoV2(
                            context,
                            "Lo has hecho increíble!!!",
                            "¿Quieres volver a jugar?, Si quieres volver a jugar pulsa en empezar de nuevo, si no, pulsa en volver al menú.",
                            alumno.colorFondo ??
                                Theme.of(context).colorScheme.surface,
                            alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                          ).then((onValue) {
                            if (onValue != null) {
                              if (onValue) {
                                j3s.reiniciarJuego();
                              } else {
                                j3s.salir();
                                navigator.pop();
                              }
                            }
                          });
                        } else {
                          mostrarDialogoSiguienteAlumnoV2(
                            context,
                            "Lo has hecho increible!!!",
                            "Si quieres seguir jugando pulsa en siguiente",
                            alumno.colorFondo ??
                                Theme.of(context).colorScheme.surface,
                            alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                          ).then((onValue) {
                            if (onValue != null) {
                              if (onValue) {
                                j3s.iniciarJuego();
                              } else {
                                j3s.salir();
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
