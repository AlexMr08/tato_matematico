import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/juego.dart';
import 'package:tato_matematico/juegos/tarjetaJuego.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

/// **Nombre de la Clase: `Juego2**
///
/// **Descripción:** Clase que representa el segundo juego de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 03/12/2025
/// * **Último cambio:** Se ha creado la clase
///

class Juego2 extends Juego {
  final bool ordenDescendente;
  Juego2(
    int min,
    int max,
    int cantidad,
    bool usaImagenes,
    String tipoImagenes,
    this.ordenDescendente,
  ) : super(
        id: 'juego2',
        nombre: 'Juego 2',
        icono: Icons.videogame_asset,
        min: min,
        max: max,
        cantidad: cantidad,
        usaImagenes: usaImagenes,
        tipoImagenes: tipoImagenes,
      );

  List<int> generarNuevoJuego() {
    List<int> res = [];
    while (res.length < cantidad) {
      int num = generarNuevoNumero();
      if (!res.contains(num)) {
        res.add(num);
      }
    }
    return res;
  }
}

/// **Nombre de la Clase: `Juego2State**
///
/// **Descripción:** Clase que representa el estado de la partida actual del juego 2
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 06/12/2025
/// * **Último cambio:** Se ha creado la clase
///
class Juego2State with ChangeNotifier {
  final Juego2 juego;
  final Alumno alumno;

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

  bool estaNumeroBienPosicionado(int num) {
    if (!numerosOrdenados.contains(num)) return false;
    return numerosOrdenados.indexOf(num) == numerosAbajo.indexOf(num);
  }

  void moverNumero(int numero) {
    int indiceVacio = numerosAbajo.indexOf(null);
    if (indiceVacio != -1) {
      numerosAbajo[indiceVacio] = numero;
      numeros.remove(numero);

      if (numerosOrdenados[indiceVacio] != numero) {
        falloActual = true;
        if (!fallo) {
          fallo = true;
          errores += 1;
        }
      } else {
        falloActual = false;
      }
      _verificarEstadoFinalizacion();
      notifyListeners();
    }
  }

  void devolverNumero(int index) {
    int? numero = numerosAbajo[index];
    if (numero != null && numerosAbajo[index] != numerosOrdenados[index]) {
      numerosAbajo[index] = null;
      numeros.add(numero);
      falloActual = false;
      finalizado = false;
      notifyListeners();
    }
  }

  void _verificarEstadoFinalizacion() {
    if (numerosAbajo.contains(null)) {
      finalizado = false;
      return;
    }

    bool correcto = true;
    for (int i = 0; i < numerosOrdenados.length; i++) {
      if (numerosAbajo[i] != numerosOrdenados[i]) {
        correcto = false;
        break;
      }
    }

    finalizado = correcto;
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

  bool finalizarJuego() {
    aciertos += 1;
    repeticionesCompletadas += 1;

    bool juegoTerminado = todasLasRepeticionesHechas();

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

/// **Nombre de la Clase: `Juego2Screen**
///
/// **Descripción:** Clase que representa visualmente el segundo juego de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 06/12/2025
/// * **Último cambio:** Se ha hecho el estado de la partida independiente de la vista
///
class Juego2Screen extends StatefulWidget {
  final Juego juego;
  final Alumno alumno;
  const Juego2Screen({super.key, required this.juego, required this.alumno});
  @override
  State<Juego2Screen> createState() => _Juego2ScreenState();
}

class _Juego2ScreenState extends State<Juego2Screen> {
  late Juego2State j2s;
  late Alumno alumno;

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

    return ScaffoldAlumno(
      alumno: alumno,
      textoCabecera: j2s.juego.ordenDescendente
          ? "Coloca de mayor a menor"
          : "Coloca de menor a mayor",
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
            j2s.salir();
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
              label: j2s.getRepeticionesString(),
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
                  ...List.generate(j2s.repeticionesTotales, (index) {
                    bool completado = index < j2s.repeticionesCompletadas;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        completado
                            ? Icons.emoji_emotions_rounded
                            : Icons.circle,
                        color: colorTexto,
                        size: 24,
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
                      spacing: 24,
                      runSpacing: 24,
                      children: j2s.numeros.map((numero) {
                        return TarjetaJuego(
                          tamano: 110,
                          label: "Mover $numero",
                          isButton: true,
                          isEnabled: true,
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
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: colorTexto,
                        ),
                      ),
                    ),
            ),

            Text(
              "Ordenados",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorTexto,
              ),
            ),

            // --- ZONA DE RESULTADO ---
            Container(
              decoration: BoxDecoration(
                color: alumno.colorBotones,
                border: Border.all(color: colorTexto, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                spacing: 4,
                runSpacing: 16,
                children: j2s.numerosAbajo.map((numero) {
                  return Column(
                    children: [
                      TarjetaJuego(
                        tamano: 85,
                        label: () {
                          if (numero == null) return "Contenedor vacío";
                          if (j2s.estaNumeroBienPosicionado(numero)) {
                            return "$numero, correcto";
                          } else {
                            return "$numero, incorrecto";
                          }
                        }(),
                        isButton:
                            numero != null &&
                            !j2s.estaNumeroBienPosicionado(numero),
                        isEnabled:
                            numero != null &&
                            !j2s.estaNumeroBienPosicionado(numero),
                        onTap: () => numero != null
                            ? j2s.devolverNumero(
                                j2s.numerosAbajo.indexOf(numero),
                              )
                            : null,
                        colorFondo:
                            alumno.colorSeleccion ??
                            Theme.of(context).colorScheme.primaryContainer,
                        imagenes: imagenes,
                        tipoImagen: tipoImagen,
                        numero: numero,
                      ),
                      Icon(
                        numero != null
                            ? j2s.estaNumeroBienPosicionado(numero)
                                  ? Icons.emoji_emotions_rounded
                                  : Icons.report_gmailerrorred
                            : null,
                        color:
                            alumno.colorSeleccion ??
                            Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            // --- BOTÓN ACEPTAR ---
            Align(
              alignment: Alignment.bottomRight,
              child: BotonSinIcono(
                texto: "Aceptar",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                colorFondo: alumno.colorBotones,
                onPressed: j2s.finalizado
                    ? () {
                        bool fin = j2s.finalizarJuego();
                        if (fin) {
                          mostrarDialogoSalirReiniciarAlumnoV2(
                            context,
                            "¿Quieres volver a jugar?",
                            "Si quieres volver a jugar pulsa en reiniciar, si no, pulsa en salir.",
                            alumno.colorFondo ??
                                Theme.of(context).colorScheme.surface,
                            alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                          ).then((onValue) {
                            if (onValue != null) {
                              if (onValue) {
                                j2s.reiniciarJuego();
                              } else {
                                j2s.salir();
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
                                j2s.iniciarJuego();
                              } else {
                                j2s.salir();
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
