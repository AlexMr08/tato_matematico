import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';

/// **Nombre de la Clase: `Juego**
///
/// **Descripción:** clase que representa un juego dentro de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se han añadido la descripcion y metadatos de control
///

/// **Nombre de la Clase: `JuegoCard`**
///
/// **Descripción:** clase basica que representa un juego dentro de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 05/12/2025
/// * **Último cambio:** Se han añadido atributos comunes de los juegos y se ha añadido un metodo para generar aleatorios.
/// * **Tambien un metodo para subir estadisticas
///

class Juego {
  String id;
  String nombre;
  IconData? icono;
  int min;
  int max;
  int cantidad;
  bool usaImagenes;
  String tipoImagenes;

  Juego({
    required this.id,
    required this.nombre,
    required this.min,
    required this.max,
    required int cantidad,
    required bool usaImagenes,
    required String tipoImagenes,
    this.icono,
  }) : usaImagenes = max > 10 ? false : usaImagenes,
       cantidad = max - min + 1 < cantidad ? max - min + 1 : cantidad,
       tipoImagenes = tipoImagenes == "" ? "apple" : tipoImagenes;

  int generarNuevoNumero() {
    int res;
    if (max < min) {
      res = 0;
    } else if (min < 0) {
      final random = Random();
      res = min + random.nextInt(max + 1);
    } else if (max == min) {
      res = min;
    } else {
      final random = Random();
      res = min + random.nextInt(max - min + 1);
    }
    return res;
  }

  Future<void> subirEstadisticas({
    required int aciertos,
    required int errores,
    required int omisiones,
    required Alumno alumno,
  }) async {
    if (omisiones == 0 && aciertos == 0 && errores == 0) return;

    // 1. Obtenemos la semana actual para la ruta en la BD
    String semana = obtenerSemana();

    // 2. Referencia a las estadísticas de este juego y semana
    var dbRef = FirebaseDatabase.instance.ref().child(
      "tato/estadisticas/${alumno.id}/$id/$semana",
    );

    // 3. Realizamos la transaccion
    await dbRef.runTransaction((Object? data) {
      // Si no existen datos previos en esa ruta, creamos el mapa inicial
      if (data == null) {
        return Transaction.success({
          "aciertos": aciertos,
          "errores": errores,
          "omisiones": omisiones,
        });
      }

      // Si existen datos, los leemos y los incrementamos
      final Map<String, dynamic> estadisticas = Map<String, dynamic>.from(
        data as Map,
      );

      int aciertosPrevios = (estadisticas['aciertos'] as int?) ?? 0;
      int erroresPrevios = (estadisticas['errores'] as int?) ?? 0;
      int omisionesPrevias = (estadisticas['omisiones'] as int?) ?? 0;

      estadisticas['aciertos'] = aciertosPrevios + aciertos;
      estadisticas['errores'] = erroresPrevios + errores;
      estadisticas['omisiones'] = omisionesPrevias + omisiones;

      // Devolvemos los datos actualizados para que se guarden
      return Transaction.success(estadisticas);
    });
  }
}

/// **Nombre de la Clase: `JuegoCard`**
///
/// **Descripción:** clase que gestiona la vista de las tarjetas de los juegos.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 02/12/2025
/// * **Último cambio:** Se ha creado la clase
///

class JuegoCard extends StatefulWidget {
  final Juego juego;
  final VoidCallback onTap;
  final Color? color;

  const JuegoCard({
    super.key,
    required this.juego,
    required this.onTap,
    required this.color,
  });

  @override
  State<JuegoCard> createState() => _JuegoCardState();
}

class _JuegoCardState extends State<JuegoCard> {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        widget.color ?? Theme.of(context).colorScheme.primaryContainer;
    final Color contentColor = getTextColorForBackground(backgroundColor);

    return InkWell(
      onTap: widget.onTap,
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Bordes más redondeados
        ),
        elevation: 6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.juego.icono ?? Icons.videogame_asset,
                  size: 90, // Icono mucho más grande
                  color: contentColor,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.juego.nombre,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 28, // Texto mucho más grande
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
