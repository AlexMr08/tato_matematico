import 'package:flutter/material.dart';


class Juego {
  String id;
  Widget actividad;
  String nombre;
  Color color;

  Juego({required this.id, required this.actividad, required this.nombre, required this.color});

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
          child: Text(
            nombre,
            style: TextStyle(
              color: Color.fromARGB(255, 50, 50, 60),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}