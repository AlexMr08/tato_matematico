import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/holders/clasesHolder.dart';
import 'package:tato_matematico/login/profesorLogIn.dart';
import 'package:tato_matematico/login/seleccionAlumno.dart';
import 'package:tato_matematico/datos/clase.dart';

/// **Nombre de la Clase: `SeleccionClase`**
///
/// **Descripción:** clase usada para que el profesor seleccione una clase entre las disponibles.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 07/12/2025
/// * **Último cambio:** Se ha rediseñado la interfaz para hacerla mas amigable en su version movil
///

class SeleccionClase extends StatefulWidget {
  const SeleccionClase({super.key});

  @override
  State<SeleccionClase> createState() => _SeleccionClaseState();
}

class _SeleccionClaseState extends State<SeleccionClase> {
  bool mostrarSoloCursoActual = true;
  int paginaActual = 0;
  late int _clasesPorPagina;
  bool notInit = true;
  late double size;
  late bool em;
  @override
  Widget build(BuildContext context) {
    ClasesHolder ch = context.watch<ClasesHolder>();

    List<Clase> clasesTodas = mostrarSoloCursoActual
        ? ch.clases.where((clase) => clase.ano == "25/26").toList()
        : ch.clases;

    if (ch.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

      size = MediaQuery.sizeOf(context).width;
      em = size < 600;
      notInit = false;

      var spacing = em ? 12.0 : 32.0;
    var width = em
        ? (size - spacing - 16 * 2) / 2
        : (size - spacing * 5 - 16 * 2) / 6;
    var height = 200.0;
    _clasesPorPagina = em ? 4 : 12;
    int totalPaginas = (clasesTodas.length / _clasesPorPagina).ceil();
    if (paginaActual >= totalPaginas && totalPaginas > 0) {
      paginaActual = totalPaginas - 1;
    }

    int inicio = paginaActual * _clasesPorPagina;
    int fin = (inicio + _clasesPorPagina) < clasesTodas.length
        ? (inicio + _clasesPorPagina)
        : clasesTodas.length;

    var clasesPagina = clasesTodas.isEmpty
        ? []
        : clasesTodas.sublist(inicio, fin);

    return ScaffoldComunV2(
      titulo: "Selección de clase",
      funcionLeading: () => navegar(ProfesorLogIn(), context),
      iconoLeading: Icons.school,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 8,
              children: [
                const Text(
                  "Mostrar solo clases del curso 25/26",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Switch(
                  value: mostrarSoloCursoActual,
                  onChanged: (val) {
                    setState(() {
                      mostrarSoloCursoActual = val;
                      paginaActual = 0;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: clasesPagina.isEmpty
                  ? const Center(child: Text("No hay clases disponibles"))
                  : Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.start,
                      spacing: spacing,
                      runSpacing: spacing,
                      children: clasesPagina.map((clase) {
                        return SizedBox(
                          width: width,
                          height: height,
                          child: SelectorClaseCard(
                            clase: clase,
                            onTap: () {
                              navegar(SeleccionAlumno(clase: clase), context);
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
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
      ),
    );
  }
}
