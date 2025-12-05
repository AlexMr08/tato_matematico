import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tato_matematico/auxFunc.dart';

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
/// * **Fecha de modificación:** 02/12/2025
/// * **Último cambio:** Se ha eliminado el widget
///

class Juego {
  String id;
  String nombre;
  IconData? icono;
  int min;
  int max;
  int cantidad;


  Juego({
    required this.id,
    required this.nombre,
    required this.min,
    required this.max,
    required this.cantidad,
    this.icono,
  });

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
    super.key, // Versión FINAL: Se añade Key
    required this.juego,
    required this.onTap,
    required this.color,
  }); // Versión FINAL: Se usa Key

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
