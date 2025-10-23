import 'package:flutter/material.dart';

class Alumno{
  int id;
  String nombre;
  String imagen;

  Alumno({required this.id, required this.nombre, required this.imagen});

  @override
  String toString() {
    return 'Alumno{nombre: $nombre, imagen: $imagen}';
  }
}

Widget widgetAlumno(BuildContext context, List<Alumno> alumnosPagina, int index, VoidCallback navegar) {
  return InkWell(
    onTap: navegar,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.contain,
            child: CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Icon(Icons.person, color: Colors.purple, size: 40),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(alumnosPagina[index].nombre),
      ],
    ),
  );
}