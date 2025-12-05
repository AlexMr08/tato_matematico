import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/configColorAlumno.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/juego.dart';
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
  Juego2(int min, int max, int cantidad)
    : super(
        id: 'juego2',
        nombre: 'Juego 2',
        icono: Icons.sort,
        min: min,
        max: max,
        cantidad: cantidad,
      );

  List<int> generarNuevoJuego(int min, int max, int opciones) {
    List<int> res = [];
    final random = Random();
    while (res.length < opciones) {
      int num = generarNuevoNumero();
      if (!res.contains(num)) {
        res.add(num);
      }
    }
    return res;
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
/// * **Fecha de modificación:** 02/12/2025
/// * **Último cambio:** Se ha creado la clase
///

class Juego2Screen extends StatefulWidget {
  final Juego juego;
  const Juego2Screen({super.key, required this.juego});
  @override
  State<Juego2Screen> createState() => _Juego2ScreenState();
}

class _Juego2ScreenState extends State<Juego2Screen> {
  late int min;
  late int max;
  late Alumno alumno;
  late int numOpciones;
  List<int> numeros = [];
  List<int?> numerosAbajo = List.filled(12, null);
  List<int> numerosOrdenados = [];
  Set<int> _indicesError = {};
  int repeticionesTotales = 1;
  int repeticionesCompletadas = 0;
  bool modoImagenes = false;
  late Juego2 juego;

  @override
  void initState() {
    super.initState();
    min = widget.juego.min;
    max = widget.juego.max;
    numOpciones = widget.juego.cantidad;
    juego = widget.juego as Juego2;
    numeros = juego.generarNuevoJuego(min, max, numOpciones);
    numerosAbajo = List.filled(numOpciones, null);
    numerosOrdenados = numeros.toList();
    numerosOrdenados.sort();
  }

  void moverNumero(int numero) {
    int indiceVacio = numerosAbajo.indexOf(null);

    if (indiceVacio != -1) {
      setState(() {
        numerosAbajo[indiceVacio] = numero;
        numeros.remove(numero);
      });
    }
  }

  void devolverNumero(int index) {
    int? numero = numerosAbajo[index];
    if (numero != null) {
      setState(() {
        numerosAbajo[index] = null;
        numeros.add(numero);
      });
    }
  }

  /*
  int numeroTotal = 0;
  int numeroRestante = 0;
  List<int> numeros = [];
  int contenedores = 3;

  List<int> _generarNuevoJuego(int min, int max, int contenedores) {
    List<int> res = [];
    final random = Random();

    int metaDeCadaParte = min + random.nextInt(max - min + 1) * contenedores;
    List<List<int>> listas = [];
    for (int i = 0; i < contenedores; i++) {
      listas.add(_generarListaQueSume(metaDeCadaParte));
    }

    res = listas.expand((x) => x).toList();
    res.shuffle();
    numeroTotal = metaDeCadaParte * contenedores;
    print("Meta mitad: $metaDeCadaParte | Total: $numeroTotal");
    print("Lista: $numeros");
    for (var lista in listas) {
      print("  Sublista: $lista");
    }

    return res;
  }

  List<int> _generarListaQueSume(int objetivo) {
    List<int> lista = [];
    int restante = objetivo;
    final random = Random();

    while (restante > 0) {
      int maxPosible = (restante > max) ? max : restante;
      if (maxPosible < min) {
        lista.add(restante);
        restante = 0;
      } else {
        int numero = min + random.nextInt(maxPosible - min);
        if (restante - numero < min && restante - numero != 0) {
          numero = restante;
        }

        lista.add(numero);
        restante -= numero;
      }
    }
    return lista;
  }
  */

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = context.watch<AlumnoHolder>();
    final navigator = Navigator.of(context);

    if (alumnoHolder.alumno == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.canPop()) navigator.pop();
      });
      return const SizedBox.shrink();
    }
    alumno = alumnoHolder.alumno!;

    PosicionBarra posicionBarra = switch (alumno.posicionBarra) {
      0 => PosicionBarra.arriba,
      1 => PosicionBarra.abajo,
      2 => PosicionBarra.izquierda,
      3 => PosicionBarra.derecha,
      _ => PosicionBarra.abajo,
    };

    var colorTexto = alumno.colorFondo != null
        ? getTextColorForBackground(alumno.colorFondo!)
        : Theme.of(context).colorScheme.onSurface;

    return ScaffoldAlumno(
      alumno: alumno,
      posicion: posicionBarra,
      hasEstadisticas: true,
      hasAjustes: true,
      onVolver: () {
        navigator.pop();
      },
      onAjustes: () {
        navegar(ConfigColorAlumno(alum: alumno), context);
      },
      onEstadisticas: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            Row(
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
                ...List.generate(repeticionesTotales, (index) {
                  bool completado = index < repeticionesCompletadas;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      completado ? Icons.emoji_emotions_rounded : Icons.circle,
                      color: colorTexto,
                      size: 24,
                    ),
                  );
                }),
              ],
            ),

            Expanded(
              child: numeros.isNotEmpty
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.start,
                      spacing: 24,
                      runSpacing: 24,
                      children: numeros.map((numero) {
                        return SizedBox(
                          width: 110,
                          height: 110,
                          child: InkWell(
                            onTap: () => moverNumero(numero),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: modoImagenes
                                      ? Image.asset(
                                          "assets/images/${numero}ball.png",
                                        )
                                      : AutoSizeText(
                                          numero.toString(),
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          minFontSize: 8,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Text(
                        "No quedan numeros",
                        style: TextStyle(
                          fontSize: 24,
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
                children: numerosAbajo.map((numero) {
                  return Column(
                    children: [
                      SizedBox(
                        width: 85,
                        height: 85,
                        child: InkWell(
                          onTap: () => numero != null
                              ? devolverNumero(numerosAbajo.indexOf(numero))
                              : null,
                          child: Card(
                            elevation: 4,
                            color:
                            _indicesError.contains(numerosAbajo.indexOf(numero))
                                ? Colors.red.shade300
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: numero != null
                                  ? Container(
                                padding: const EdgeInsets.all(8.0),
                                child: modoImagenes
                                    ? Image.asset(
                                  "assets/images/${numero}ball.png",
                                )
                                    : AutoSizeText(
                                  numero.toString(),
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 8,
                                ),
                              )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        numero != null ? numero %2 == 0 ? Icons.error : Icons.ac_unit : null,
                        color: Colors.red,
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: BotonSinIcono(
                  texto: "Aceptar",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  colorFondo: alumno.colorBotones,
                  onPressed: () {
                    Set<int> nuevosErrores = {};

                    _indicesError.clear();
                    for (int i = 0; i < numerosAbajo.length; i++) {
                      if (numerosAbajo[i] != numerosOrdenados[i]) {
                        nuevosErrores.add(i);
                      }
                    }

                    if (nuevosErrores.isEmpty) {
                      // Correcto
                      snackBarExito(
                        context,
                        "Has ordenado los números correctamente.",
                      );
                      repeticionesCompletadas += 1;
                      if (repeticionesCompletadas >= repeticionesTotales) {
                        mostrarDialogoSalirReiniciarAlumnoV2(
                          context,
                          "Quieres volver a jugar?",
                          "Si quieres volver a jugar pulsa en reiniciar, si no, pulsa en salir.",
                          alumno.colorFondo ??
                              Theme.of(context).colorScheme.surface,
                          alumno.colorBotones ??
                              Theme.of(context).colorScheme.primaryContainer,
                        ).then((onValue) {
                          if (onValue != null) {
                            if (onValue) {
                              // Reiniciar
                              setState(() {
                                repeticionesCompletadas = 0;
                                numeros = juego.generarNuevoJuego(
                                  min,
                                  max,
                                  numOpciones,
                                );
                                numerosAbajo = List.filled(numOpciones, null);
                                numerosOrdenados = numeros.toList();
                                numerosOrdenados.sort();
                                _indicesError.clear();
                              });
                            } else {
                              navigator.pop();
                            }
                          }
                        });
                      }
                      setState(() {
                        numeros = juego.generarNuevoJuego(
                          min,
                          max,
                          numOpciones,
                        );
                        numerosAbajo = List.filled(numOpciones, null);
                        numerosOrdenados = numeros.toList();
                        numerosOrdenados.sort();
                        _indicesError.clear();
                      });
                    } else {
                      setState(() {
                        _indicesError = nuevosErrores;
                      });
                      snackBarError(
                        context,
                        "El orden no es correcto. Inténtalo de nuevo.",
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
