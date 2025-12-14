import 'package:flutter/material.dart';
import 'package:tato_matematico/datos/juego.dart';
import 'dart:math';


/// **Nombre de la Clase: `Juego3**
///
/// **Descripción:** Clase que representa el tercer juego de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Andrés Ignacio Mardones Domcke
/// * **Última modificación por:** Andrés Ignacio Mardones Domcke
/// * **Fecha de modificación:** 06/12/2025
/// * **Último cambio:** Algoritmo de generación de juego
///

class Juego3 extends Juego {
  final int cantContenedores;
  Juego3({
    super.min = 1,
    super.max = 10,
    super.cantidad = 6,
    super.usaImagenes = false,
    super.tipoImagenes = "numeros",
    this.cantContenedores = 2,
  }) : super(
        id: 'juego3',
        nombre: 'Juego 3',
        icono: Icons.videogame_asset,
      );

  final Random _randomGlobal = Random(DateTime.now().millisecondsSinceEpoch);
  List<List<int>> generarNuevoJuego() {
    List<List<int>> solucionContenedores = [];

    // 1. Repartir cartas por contenedor
    List<int> tamGrupos = List.filled(
      cantContenedores,
      cantidad ~/ cantContenedores,
    );
    for (int i = 0; i < (cantidad % cantContenedores); i++) tamGrupos[i]++;

    // 2. Calcular límites globales para la suma objetivo
    int maxCont = tamGrupos.reduce(max);
    int minCont = tamGrupos.reduce(min);

    int sumaMin = maxCont * this.min;
    int sumaMax = minCont * this.max;

    if (sumaMin > sumaMax) return [];

    // 3. ELEGIR OBJETIVO CON VARIEDAD
    // Forzamos que no siempre elija el mínimo sumando un factor aleatorio real
    int sumaObjetivo = sumaMin + _randomGlobal.nextInt(sumaMax - sumaMin + 1);

    // 4. Generar cada grupo y CAPTURAR LA SOLUCIÓN
    for (int n in tamGrupos) {
      int sumaRestante = sumaObjetivo;
      List<int> contenedorActual = []; // Creamos el contenedor

      for (int i = 0; i < n; i++) {
        int cRest = n - 1 - i;

        // LÍMITES DINÁMICOS (la lógica constructiva)
        int bajo = (sumaRestante - (cRest * this.max)).clamp(
          this.min,
          this.max,
        );
        int alto = (sumaRestante - (cRest * this.min)).clamp(
          this.min,
          this.max,
        );

        int num = bajo + _randomGlobal.nextInt(alto - bajo + 1);

        contenedorActual.add(num); // Añadimos al contenedor
        sumaRestante -= num;
      }
      // Guardamos el contenedor completo en la lista de soluciones
      solucionContenedores.add(contenedorActual);
    }

    return solucionContenedores;
  }

    factory Juego3.fromMap(Map<dynamic, dynamic> data) {
    return Juego3(
      min: data["min"] ?? 0,
      max: data["max"] ?? 10,
      cantidad: data["cantidad"] ?? 8,
      usaImagenes: data["imagenes"] ?? false,
      tipoImagenes: data["tipoImagenes"] ?? "numeros",
      cantContenedores: data["cantContenedores"] ?? 2,
    );
  }
}