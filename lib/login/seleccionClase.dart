import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/holders/clasesHolder.dart';
import 'package:tato_matematico/login/profesorLogIn.dart';
import 'package:tato_matematico/login/seleccionAlumno.dart';

class SeleccionClase extends StatefulWidget {
  @override
  State<SeleccionClase> createState() => _SeleccionClaseState();
}

class _SeleccionClaseState extends State<SeleccionClase> {

  @override
  Widget build(BuildContext context) {
    ClasesHolder ch = context.watch<ClasesHolder>();
    var clases = ch.clases;

    if (ch.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ch.clases.isEmpty) {
      return ScaffoldComunV2(
        titulo: "Seleccion de clase",
        cuerpo: const Center(child: Text("No hay clases")),
      );
    }

    return ScaffoldComunV2(
      titulo: "Seleccion de clase",
      funcionLeading: () {
        navegar(ProfesorLogIn(), context);
      },
      iconoLeading: Icons.school,
      cuerpo: ListView.builder(
        padding: EdgeInsets.only(
          bottom: 88.0 + MediaQuery.of(context).padding.bottom,
          top: 8,
        ),
        itemCount: clases.length,
        itemBuilder: (BuildContext context, int index) {
          final clase = clases[index];
          return KeyedSubtree(
            key: ValueKey(clase.id),
            child: clase.widgetClase(context, () {
              navegar(SeleccionAlumno(clase: clase), context);
            }),
          );
        },
      ),
    );
  }
}
