import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:tato_matematico/alumno.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/gamesMenu.dart';

class AlumnLogIn extends StatefulWidget {
  late final List<Alumno> listaAlumnos;

  AlumnLogIn({super.key});

  @override
  State<AlumnLogIn> createState() => _AlumnLogInState();
}

Widget usuario(BuildContext context, List<Alumno> alumnosPagina, int index) {
  return InkWell(
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
    onTap: () => {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => GamesMenu()),
      ),
    },
  );
}

class _AlumnLogInState extends State<AlumnLogIn> {
  List<Alumno> listaAlumnos = List.generate(
    14,
    (index) => Alumno(
      id: index,
      nombre: 'Alumno $index',
      imagen: 'assets/user${(index % 3) + 1}.png',
    ),
  );
  int paginaActual = 0;
  final int itemsPorPagina = 10;
  @override
  Widget build(BuildContext context) {
    int totalItems = listaAlumnos.length; // Ejemplo de total de elementos
    int totalPaginas = (totalItems / itemsPorPagina).ceil();
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

    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTabletVar = isTablet(context);
              int crossAxisCount = isTabletVar ? 5 : 3; // hasta 3 por fila
              final double spacing = 8;
              final double itemWidth =
                  (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                  crossAxisCount;
              final int rowCount = (listaAlumnos.length / crossAxisCount)
                  .ceil();
              final double itemHeight =
                  (constraints.maxHeight - (spacing * (rowCount - 1))) /
                  rowCount;
              return Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
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
                    final isLastPage = paginaActual == totalPaginas - 1;
                    final isLastItem = index == currentPageItems - 1;
                    if (isLastPage && isLastItem) {
                      return InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, color: Colors.white, size: 40),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Agregar nuevo alumno')),
                          );
                        },
                      );
                    } else {
                      // Elementos normales
                      return usuario(context, alumnosPagina, index);
                    }
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: paginaActual > 0
                    ? () => setState(() => paginaActual--)
                    : null,
                child: Text('atras'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: paginaActual < totalItems / itemsPorPagina - 1
                    ? () => setState(() => paginaActual++)
                    : null,
                child: Text('siguiente'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
