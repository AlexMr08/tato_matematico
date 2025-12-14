import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldComunV2.dart';
import 'package:tato_matematico/datos/profesor.dart';
import 'package:tato_matematico/widgetsAuxiliares/perfilProfesor.dart';
import '../holders/clasesHolder.dart';

/// **Nombre de la Clase: `EditarProfesor`**
///
/// **Descripción:** Clase que permite editar los datos de un profesor existente en la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se creo la clase para modificar los datos de un profesor
///

class EditarProfesor extends StatefulWidget {
  final Profesor profesor;

  const EditarProfesor({super.key, required this.profesor});

  @override
  State<EditarProfesor> createState() => _EditarProfesorState();
}

class _EditarProfesorState extends State<EditarProfesor> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var listaClases = context
        .watch<ClasesHolder>()
        .clases
        .where((clase) => clase.idTutor == widget.profesor.id)
        .toList();
    return ScaffoldComunV2(
      titulo: "Editar Perfil",
      subtitulo: widget.profesor.username,
      cuerpo: PerfilProfesor(
        profesor: widget.profesor,
        clases: listaClases,
        propio: false,
      ),
    );
  }
}
