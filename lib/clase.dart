import 'package:flutter/material.dart';
import 'package:tato_matematico/widgetsAuxiliares/fotoPerfil.dart';

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

}

class SelectorClaseCard extends StatelessWidget {
  final Clase clase;
  final VoidCallback onTap;

  const SelectorClaseCard({super.key, required this.clase, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FotoPerfil(nombre: clase.nombre, idUnico: "", radio: 48),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  clase.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(clase.ano, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfesorClaseCard extends StatelessWidget {
  final Clase clase;
  final VoidCallback onPressed;

  const ProfesorClaseCard({super.key, required this.clase, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          child: Text(
            clase.nombre.isNotEmpty ? clase.nombre[0] : '?',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          clase.nombre,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Año ${clase.ano} | ${clase.alumnos.length} alumnos'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onPressed,
        ),
        onTap: null,
      ),
    );
  }
}
