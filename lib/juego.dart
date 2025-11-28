import 'package:flutter/material.dart';
import 'package:tato_matematico/auxFunc.dart'; // Importar para usar getTextColorForBackground

class Juego {
  String id;
  Widget actividad;
  String nombre;
  Color color;
  IconData? icono;

  Juego({
    required this.id,
    required this.actividad,
    required this.nombre,
    required this.color,
    this.icono,
  });

  Widget widgetJuego(BuildContext context, VoidCallback navegar, Color? color) {
    final Color backgroundColor = color ?? Theme.of(context).colorScheme.primaryContainer;
    final Color contentColor = getTextColorForBackground(backgroundColor);

    return InkWell(
      onTap: navegar,
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
                  icono ?? Icons.videogame_asset,
                  size: 90, // Icono mucho más grande
                  color: contentColor,
                ),
                const SizedBox(height: 16),
                Text(
                  nombre,
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
