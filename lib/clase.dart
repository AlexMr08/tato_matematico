import 'package:flutter/material.dart';

/// **Nombre de la Clase: `Clase`**
///
/// **Descripción:** Clase encargada de representar una clase escolar con sus atributos y métodos asociados.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Andrés Ignacio Mardones Domcke
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class Clase {
  String id;
  String nombre;
  String ano;
  String idTutor;
  List<String> alumnos;

  Clase({
    required this.id,
    required this.nombre,
    required this.ano,
    required this.idTutor,
    required this.alumnos,
  });

  factory Clase.fromMap(String id, Map<dynamic, dynamic> data) {
    List<String> listaAlumnos = [];
    if (data['alumnos'] != null) {
      listaAlumnos = List<String>.from(data['alumnos']);
    }

    return Clase(
      id: id,
      nombre: data['nombre'] ?? 'Sin nombre',
      ano: data['ano'] ?? '',
      idTutor: data['id_tutor'] ?? '',
      alumnos: listaAlumnos,
    );
  }

  /// Para debug / imprimir
  @override
  String toString() {
    return 'Clase{id: $id, nombre: $nombre, ano: $ano, idTutor: $idTutor, alumnos: $alumnos}';
  }

  Widget widgetClase(BuildContext context, VoidCallback onPressed) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          child: Text(
            nombre.isNotEmpty ? nombre[0] : '?',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Año $ano | ${alumnos.length} alumnos'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onPressed,
        ),
        onTap: null,
      ),
    );
  }
}
