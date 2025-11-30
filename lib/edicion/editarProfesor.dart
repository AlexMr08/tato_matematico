import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/datos/profesor.dart';
import 'package:tato_matematico/perfilProfesor.dart';
import '../holders/clasesHolder.dart';

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
