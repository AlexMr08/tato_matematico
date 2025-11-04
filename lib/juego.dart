import 'package:flutter/material.dart';

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
    return InkWell(
      onTap: navegar,
      //Boton
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono != null
                    ? icono!
                    : Icons.videogame_asset,
                      size: 64,
                      color: color != null
                          ? color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              SizedBox(height: 8),
              Text(
                nombre,
                style: TextStyle(
                  color: color != null
                      ? color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
