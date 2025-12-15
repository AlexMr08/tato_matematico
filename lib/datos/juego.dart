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
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se han hecho los parametros opcionales en el constructor
///

/// **Nombre de la Clase: `JuegoCard`**
///
/// **Descripción:** clase basica que representa un juego dentro de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 12/12/2025
/// * **Último cambio:** Se ha añadido un metodo de guardado en BD
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
    this.min = 0,
    this.max = 10,
    int cantidad = 8,
    bool usaImagenes = false,
    String tipoImagenes = "numeros",
    this.icono = Icons.videogame_asset,
  }) : usaImagenes = max > 10 ? false : usaImagenes,
       cantidad = max - min + 1 < cantidad ? max - min + 1 : cantidad,
       tipoImagenes = tipoImagenes == "" ? "apple" : tipoImagenes;

  factory Juego.fromMap(Map<dynamic, dynamic> data) {
    return Juego(
      id: data["id"] ?? "juego1",
      nombre: data["nombre"] ?? "Juego 1",
      min: data["min"] ?? 1,
      max: data["max"] ?? 10,
      cantidad: data["cantidad"] ?? 8,
      usaImagenes: data["imagenes"] ?? false,
      tipoImagenes: data["tipoImagenes"] ?? "numeros",
    );
  }

  void guardarAjustes({
    required String idAlumno,
    required int rango,
    required int cantidad,
    required String tema,
    required DatabaseReference dbRef,
  }) {
    dbRef.update({"max": rango});
    dbRef.update({"min": id == "juego3" ? 1 : 0});
    dbRef.update({"cantidad": cantidad});
    dbRef.update({"tipoImagenes": tema});
    dbRef.update({"imagenes": tema != "numeros"});
  }

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
    if (omisiones != 0 || aciertos != 0 || errores != 0) {
      // 1. Obtenemos la semana actual para la ruta en la BD
      String semana = obtenerSemana();

      // 2. Referencia a las estadísticas de este juego y semana
      var dbRef = FirebaseDatabase.instance.ref().child(
        "tato/estadisticas/${alumno.id}/$id/$semana",
      );

      // 3. Realizamos la transaccion
      await dbRef.runTransaction((Object? data) {
        // Si no existen datos previos en esa ruta, creamos el mapa inicial

        Map<String, dynamic> stats = {};

        if (data == null) {
          stats = {
            "aciertos": aciertos,
            "errores": errores,
            "omisiones": omisiones,
          };
        } else {
          // Si existen datos, los leemos y los incrementamos
          final Map<String, dynamic> estadisticas = Map<String, dynamic>.from(
            data as Map,
          );

          int aciertosPrevios = (estadisticas['aciertos'] as int?) ?? 0;
          int erroresPrevios = (estadisticas['errores'] as int?) ?? 0;
          int omisionesPrevias = (estadisticas['omisiones'] as int?) ?? 0;

          stats['aciertos'] = aciertosPrevios + aciertos;
          stats['errores'] = erroresPrevios + errores;
          stats['omisiones'] = omisionesPrevias + omisiones;
        }
        // Devolvemos los datos actualizados para que se guarden
        return Transaction.success(stats);
      });
    }
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
/// * **Fecha de modificación:** 08/12/2025
/// * **Último cambio:** Se ha cambiado el orden de Card e InkWell para darle mejor aspecto
///

class JuegoCard extends StatefulWidget {
  final Juego juego;
  final VoidCallback? onTap;
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
    final bool isDisabled = widget.onTap == null;

    final Color backgroundColor2 = isDisabled
        ? Colors.grey.shade500
        : (widget.color ?? Theme.of(context).colorScheme.primaryContainer);
    final Color contentColor = getTextColorForBackground(backgroundColor2);
    return Card(
      color: backgroundColor2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 6,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(24),
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
