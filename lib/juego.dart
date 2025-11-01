import 'package:flutter/material.dart';


class Juego {
  String id;
  Widget actividad;
  String nombre;
  Color color;
  Widget? icono;

  Juego({required this.id, required this.actividad, required this.nombre, required this.color, this.icono});

  Widget widgetJuego(BuildContext context, VoidCallback navegar) {
    return InkWell(
      onTap: navegar,
      //Boton
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              this.icono != null
                  ? this.icono!
                  : Icon(
                      Icons.videogame_asset,
                      size: 64,
                      color: Color.fromARGB(255, 50, 50, 60),
                    ),
              SizedBox(height: 8),
              Text(
                nombre,
                style: TextStyle(
                  color: Color.fromARGB(255, 50, 50, 60),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}