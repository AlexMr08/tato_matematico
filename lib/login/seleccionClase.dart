import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/holders/clasesHolder.dart';
import 'package:tato_matematico/login/profesorLogIn.dart';
import 'package:tato_matematico/login/seleccionAlumno.dart';
import 'package:tato_matematico/clase.dart';

/// **Nombre de la Clase: `SeleccionClase`**
///
/// **Descripción:** clase usada para que el profesor seleccione una clase entre las disponibles.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 01/12/2025
/// * **Último cambio:** Se ha rediseñado la interfaz para hacerla mas amigable
///

class SeleccionClase extends StatefulWidget {
  const SeleccionClase({super.key});

  @override
  State<SeleccionClase> createState() => _SeleccionClaseState();
}

class _SeleccionClaseState extends State<SeleccionClase> {
  bool mostrarSoloCursoActual = true;
  int paginaActual = 0;
  final int _clasesPorPagina = 12;

  @override
  Widget build(BuildContext context) {
    ClasesHolder ch = context.watch<ClasesHolder>();

    List<Clase> clasesTodas = mostrarSoloCursoActual
        ? ch.clases.where((clase) => clase.ano == "25/26").toList()
        : ch.clases;

    if (ch.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
      cuerpo: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 0.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Mostrar solo clases del curso 25/26",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 8),
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
          ),

          Expanded(
            child: clasesPagina.isEmpty
                ? const Center(child: Text("No hay clases disponibles"))
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.start,
                      spacing: 32,
                      runSpacing: 32,
                      children: clasesPagina.map((clase) {
                        return SizedBox(
                          width: 150,
                          height: 200,
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
          ),

          BotonesInferiores(
            onPrevious: retroceder(),
            onNext: avanzar(totalPaginas),
          ),
          // Indicador de página (Opcional, ayuda a saber dónde estás)
          /*Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Página ${_paginaActual + 1} de ${totalPaginas == 0 ? 1 : totalPaginas}",
              style: const TextStyle(color: Colors.grey),
            ),
          ),*/
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onPrevious,
                style: bigButtonStyle,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 64),
                    Text("Anterior"),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              ElevatedButton(
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
            ],
          ),
        ],
      ),
    );
  }
}
