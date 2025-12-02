import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/configColorAlumno.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:flutter/foundation.dart';

/// **Nombre de la Clase: `Juego2**
///
/// **Descripción:** Clase que representa el segundo juego de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 02/12/2025
/// * **Último cambio:** Se ha creado la clase
///

class Juego2Screen extends StatefulWidget {
  const Juego2Screen({super.key});
  @override
  State<Juego2Screen> createState() => _Juego2ScreenState();
}

class _Juego2ScreenState extends State<Juego2Screen> {
  late Alumno alumno;
  int min = 33;
  int max = 100;
  int numOpciones = 12;
  List<int> numeros = [];
  List<int?> numerosAbajo = List.filled(12, null);
  List<int> numerosOrdenados = [];
  int repeticiones = 0;

  @override
  void initState() {
    super.initState();
    // 1. GENERAMOS EL JUEGO SOLO UNA VEZ AQUÍ
    numeros = _generarNuevoJuego(min, max, numOpciones);
    numerosAbajo = List.filled(numOpciones, null);
    numerosOrdenados = numeros.toList();
    numerosOrdenados.sort();
  }

  void moverNumero(int numero) {
    // Buscamos el primer hueco vacío abajo
    int indiceVacio = numerosAbajo.indexOf(null);

    if (indiceVacio != -1) {
      setState(() {
        // Ponemos el número abajo
        numerosAbajo[indiceVacio] = numero;
        // Lo quitamos de arriba para que no se duplique
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

  List<int> _generarNuevoJuego(int min, int max, int opciones) {
    List<int> res = [];
    final random = Random();
    while (res.length < opciones) {
      int num = min + random.nextInt(max - min + 1);
      if (!res.contains(num)) {
        res.add(num);
      }
    }
    return res;
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

    //numeros = _generarNuevoJuego(min, max, numOpciones);

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
          children: [
            Expanded(
              child: numeros.isNotEmpty
                  ? Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      spacing: 32,
                      runSpacing: 32,
                      children: numeros.map((num) {
                        return SizedBox(
                          width: 140,
                          height: 140,
                          child: InkWell(
                            onTap: () => moverNumero(num),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: AutoSizeText(
                                    num.toString(),
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
                  : Center(child: Text("No quedan numeros")),
            ),
            const SizedBox(height: 16),
            Text(
              "Ordenados",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.start,
                spacing: 16,
                runSpacing: 16,
                children: numerosAbajo.map((num) {
                  return SizedBox(
                    width: 75,
                    height: 75,
                    child: InkWell(
                      onTap: () => devolverNumero(
                        num == null ? -1 : numerosAbajo.indexOf(num),
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: AutoSizeText(
                              num != null ? num.toString() : "",
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
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (listEquals(numerosAbajo, numerosOrdenados)) {
                    // Correcto
                    snackBarExito(
                      context,
                      "Has ordenado los números correctamente.",
                    );
                  } else {
                    // Incorrecto
                    snackBarError(
                      context,
                      "El orden no es correcto. Inténtalo de nuevo.",
                    );
                  }
                },
                child: const Text('Aceptar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
