import 'package:flutter/material.dart';
import 'package:tato_matematico/alumno.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/gamesMenu.dart';
import 'package:tato_matematico/login/profesorLogIn.dart';

class AlumnLogIn extends StatefulWidget {
  late final List<Alumno> listaAlumnos;

  AlumnLogIn({super.key});

  @override
  State<AlumnLogIn> createState() => _AlumnLogInState();
}

class _AlumnLogInState extends State<AlumnLogIn> {
  List<Alumno> listaAlumnos = List.generate(
    32,
    (index) => Alumno(
      id: index,
      nombre: 'Alumno $index',
      imagen: 'assets/user${(index % 3) + 1}.png',
    ),
  );
  int paginaActual = 0;
  final int itemsPorPagina = 8;

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

  @override
  Widget build(BuildContext context) {
    int totalPaginas = (listaAlumnos.length / itemsPorPagina).ceil();
    final isTabletVar = isTablet(context);
    final int columnas = isTabletVar ? 4 : 3; // hasta 3 por fila
    final double spacing = 8;

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text('Seleccion alumno', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double itemWidth =
                            (constraints.maxWidth -
                                (spacing * (columnas - 1))) /
                            columnas;
                        final int rowCount = (itemsPorPagina / columnas).ceil();
                        final double itemHeight =
                            (constraints.maxHeight -
                                (spacing * (rowCount - 1))) /
                            rowCount;
                        return Expanded(
                          child: GridAlumnos(
                            listaAlumnos: listaAlumnos,
                            paginaActual: paginaActual,
                            totalPaginas: totalPaginas,
                            itemsPorPagina: itemsPorPagina,
                            crossAxisCount: columnas,
                            itemWidth: itemWidth,
                            itemHeight: itemHeight,
                            spacing: spacing,
                            totalItems: listaAlumnos.length,
                          ),
                        );
                      },
                    ),
                  ),
                  BotonesInferiores(
                    onPrevious: retroceder(),
                    onNext: avanzar(totalPaginas),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        return widgetAlumno(
          context,
          alumnosPagina,
          index,
          () => navegar(GamesMenu(alumno: listaAlumnos[index],), context),
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
      minimumSize: const Size(0, 72), // altura grande
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
              Text('Iniciar sesion como '),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () => navegar(ProfesorLogIn(), context),
                child: Text("profesor"),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onPrevious,
                style: bigButtonStyle,
                child: Text('anterior'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onNext,
                style: bigButtonStyle,
                child: Text('siguiente'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
