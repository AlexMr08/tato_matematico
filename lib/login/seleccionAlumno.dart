import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/datos/clase.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/holders/alumnosHolder.dart';
import 'package:tato_matematico/login/AlumnoLoginSecuencia.dart';
import 'package:tato_matematico/login/alumnoLogin.dart';
import 'package:tato_matematico/login/LoginConImagen.dart';

/// **Nombre de la Clase: `SeleccionAlumno`**
///
/// **Descripción:** Clase usada para diseñar la interfaz de seleccion de alumno
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 07/12/2025
/// * **Último cambio:** Se ha hecho cambios en el diseño para adaptarlo a moviles
///

class SeleccionAlumno extends StatefulWidget {
  final Clase clase;
  const SeleccionAlumno({super.key, required this.clase});

  @override
  State<SeleccionAlumno> createState() => _SeleccionAlumnoState();
}

//Se obtiene el tipo de login del alumno
Future<String?> cargarTipoLogin(String alumnoId) async {
  final snap = await FirebaseDatabase.instance
      .ref()
      .child("tato")
      .child("login")
      .child(alumnoId)
      .child("tipoLogin")
      .get();

  if (!snap.exists || snap.value == null) return null;

  return snap.value.toString();
}

class _SeleccionAlumnoState extends State<SeleccionAlumno> {
  List<Alumno> alumnos = [];
  int paginaActual = 0;
  late int itemsPorPagina = 10;
  bool notInit = true;
  late double size;
  late bool em;

  /*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - Si la clase no tiene alumnos, se indica que no hay alumnos
  - Si la clase tiene alumnos, sale un listado de los mismos
  - Al pulsar un alumno, se pasa al inicio de sesion de este
  - Al pulsar la flecha de "Siguiente", se pasa a la siguiente parte de la
    visualizacion de alumnos para clases con muchos alumnos
  - Al pulsar la flecha de "Atras" se vuelve a la parte anterior de la
    visualizacion de la clase.
   */

  @override
  Widget build(BuildContext context) {
    AlumnosHolder ah = context.watch<AlumnosHolder>();
    if (ah.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    var alumnos = ah.obtenerAlumnosPorClase(widget.clase);

    if (notInit) {
      size = MediaQuery.sizeOf(context).width;
      em = size < 600;
      notInit = false;
    }

    itemsPorPagina = em ? 6 : 12;
    var spacing = em ? 16.0 : 24.0;
    final int totalPaginas = (alumnos.length / itemsPorPagina).ceil();

    if (paginaActual >= totalPaginas && totalPaginas > 0) {
      paginaActual = totalPaginas - 1;
    }

    int inicio = paginaActual * itemsPorPagina;
    int fin = (inicio + itemsPorPagina) < alumnos.length
        ? (inicio + itemsPorPagina)
        : alumnos.length;

    var alumnosPagina = alumnos.isEmpty ? [] : alumnos.sublist(inicio, fin);

    var width = em ? (size - spacing - 32) / 2 : (size - spacing * 5 - 32) / 6;

    var height = em ? width : 200.0;

    if (alumnos.isEmpty) {
      return ScaffoldComunV2(
        titulo: "Seleccion de alumno",
        subtitulo: "${widget.clase.nombre} - ${widget.clase.ano}",
        cuerpo: const Center(child: Text("La clase no tiene alumnos")),
      );
    }

    return ScaffoldComunV2(
      titulo: "Seleccion de alumno",
      subtitulo: "${widget.clase.nombre} - ${widget.clase.ano}",
      cuerpo: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            alumnosPagina.isEmpty
                ? const Center(child: Text("No hay clases disponibles"))
                : Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.start,
                      spacing: spacing,
                      runSpacing: spacing,
                      children: alumnosPagina.map((alumno) {
                        return SizedBox(
                          width: width,
                          height: height,
                          child: AlumnViewCard(
                            alumno: alumno,
                            onTap: () {
                              context.read<AlumnoHolder>().setAlumno(alumno);
                              cargarTipoLogin(alumno.id).then((tipo) {
                                if (mounted) {
                                  setState(() {
                                    if (tipo == "seleccionImagen") {
                                      navegar(
                                        LoginConImagen(alumnoId: alumno.id),
                                        context,
                                      );
                                    } else if (tipo == "secuenciaImagenes") {
                                      navegar(
                                        AlumnoLoginSecuencia(
                                          alumnoId: alumno.id,
                                        ),
                                        context,
                                      );
                                    } else if (tipo == "alfanumerica") {
                                      navegar(AlumnoLogIn(), context);
                                    }
                                  });
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            BotonesInferiores(
              onPrevious: retroceder(),
              onNext: avanzar(totalPaginas),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? retroceder() {
    return paginaActual > 0
        ? () => setState(() {
            paginaActual--;
          })
        : null;
  }

  VoidCallback? avanzar(int totalPaginas) {
    return paginaActual < totalPaginas - 1
        ? () => setState(() {
            paginaActual++;
          })
        : null;
  }
}

class GridAlumnos extends StatelessWidget {
  final List<Alumno> listaAlumnos;
  final int paginaActual;
  final int totalPaginas;
  final int itemsPorPagina;
  final int crossAxisCount;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final int totalItems;
  const GridAlumnos({
    super.key,
    required this.listaAlumnos,
    required this.totalPaginas,
    required this.paginaActual,
    required this.itemsPorPagina,
    required this.crossAxisCount,
    required this.itemWidth,
    required this.itemHeight,
    required this.spacing,
    this.totalItems = 0,
  });

  @override
  Widget build(BuildContext context) {
    int currentPageItems = (paginaActual == totalPaginas - 1)
        ? (totalItems % itemsPorPagina == 0
              ? itemsPorPagina
              : totalItems % itemsPorPagina)
        : itemsPorPagina;
    int inicio = paginaActual * itemsPorPagina;
    int fin = (inicio + itemsPorPagina) < listaAlumnos.length
        ? (inicio + itemsPorPagina)
        : listaAlumnos.length;
    List<Alumno> alumnosPagina = listaAlumnos.sublist(inicio, fin);
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: itemWidth / itemHeight,
      ),
      itemCount: currentPageItems,
      itemBuilder: (context, index) {
        final alumno = alumnosPagina[index];
        return AlumnViewCard(
          alumno: alumno,
          onTap: () {
            context.read<AlumnoHolder>().setAlumno(alumno);
            cargarTipoLogin(alumno.id).then((tipo) {
              if (tipo == "seleccionImagen") {
                navegar(LoginConImagen(alumnoId: alumno.id), context);
              } else if (tipo == "secuenciaImagenes") {
                navegar(AlumnoLoginSecuencia(alumnoId: alumno.id), context);
              } else if (tipo == "alfanumerica") {
                navegar(AlumnoLogIn(), context);
              }
            });
          },
        );
      },
    );
  }
}

class BotonesInferiores extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  const BotonesInferiores({
    super.key,
    required this.onPrevious,
    required this.onNext,
  });
  @override
  Widget build(BuildContext context) {
    final ButtonStyle bigButtonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(0, 72),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 16,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPrevious,
            style: bigButtonStyle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.arrow_back, size: 64), Text("Anterior")],
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: bigButtonStyle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward, size: 64),
                Text("Siguiente"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
