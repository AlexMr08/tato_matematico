import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/agregar/agregarProfesor.dart';
import 'package:tato_matematico/edicion/editarAlumno.dart';
import 'package:tato_matematico/edicion/editarClaseV2.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/holders/alumnosHolder.dart';
import 'package:tato_matematico/holders/clasesHolder.dart';
import 'package:tato_matematico/holders/profesoresHolder.dart';
import 'package:tato_matematico/perfilProfesor.dart';
import 'package:tato_matematico/datos/profesor.dart';
import 'package:tato_matematico/clase.dart';
import 'package:tato_matematico/agregar/agregarAlumno.dart';

import 'datos/alumno.dart';
import 'holders/profesorHolder.dart';

class MainMenuProfe extends StatefulWidget {
  const MainMenuProfe({super.key});
  @override
  State<MainMenuProfe> createState() => _MainMenuProfeState();
}

class _MainMenuProfeState extends State<MainMenuProfe> {
  int currentPageIndex = 0;
  bool esDirector = true;
  int numItems = 0;
  late Profesor profesor;
  final TextEditingController _searchController = TextEditingController();
  List<Alumno> _alumnosFiltrados = [];
  List<Alumno> _alumnos = [];
  List<Profesor> _profesoresFiltrados = [];
  List<Profesor> _profesores = [];
  List<Clase> _clasesFiltradas = [];
  List<Clase> _clases = [];
  List<String> titulos = [
    "Listado de Alumnos",
    "Listado de Profesores",
    "Listado de Clases",
    "Perfil",
  ];

  Widget _buildHeader(ProfesorHolder profesorHolder) {
    String texto = "";
    switch (currentPageIndex) {
      case 0:
        texto = "alumno";
        break;
      case 1:
        texto = "profesor";
        break;
      case 2:
        texto = "clase";
        break;
      default:
        return SizedBox.shrink();
    }
    esDirector = profesorHolder.profesor!.director;
    numItems = esDirector ? 3 : 2;
    if ((profesor.director == false && currentPageIndex == numItems)) {
      return SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primary, // mismo color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 700,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (currentPageIndex == 0) {
                  setState(() {
                    _alumnosFiltrados = _alumnos
                        .where(
                          (alumno) => alumno.nombre.toLowerCase().contains(
                            value.toLowerCase(),
                          ),
                        )
                        .toList();
                  });
                }
                if (currentPageIndex == 1) {
                  setState(() {
                    _profesoresFiltrados = _profesores
                        .where(
                          (profesor) => profesor.nombre.toLowerCase().contains(
                            value.toLowerCase(),
                          ),
                        )
                        .toList();
                  });
                }
                if (currentPageIndex == 2) {
                  setState(() {
                    _clasesFiltradas = _clases
                        .where(
                          (clase) => clase.nombre.toLowerCase().contains(
                            value.toLowerCase(),
                          ),
                        )
                        .toList();
                  });
                }
              },
              decoration: InputDecoration(
                hintText: "Buscar $texto",
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(width: 250),

          // IconButton.filled(
          //   style: IconButton.styleFrom(
          //     backgroundColor: const Color.fromARGB(255, 95, 255, 149),
          //     foregroundColor: Colors.black,
          //     shape: const CircleBorder(),
          //     padding: EdgeInsets.zero,
          //   ),
          //   iconSize: 28,
          //   onPressed: () {
          //     navegar(AgregarProfesor(), context);
          //   },
          //   icon: const Icon(Icons.add),
          // ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (currentPageIndex == 0) {
                navegar(const AgregarAlumno(), context);
              }
              if (currentPageIndex == 1) {
                navegar(const AgregarProfesor(), context);
                /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgregarProfesor(),
                    ),
                  ).then((value) {
                    if (value == true) {
                      setState(() {
                        _futureProfesores = _loadProfesores(profesorHolder);
                      });
                    }
                  });*/
              }
              if (currentPageIndex == 2) {
                //navegar(const AgregarClase(), context);
              }
            },
            label: Text("Añadir $texto"),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final profesorHolder = context.watch<ProfesorHolder>();
    final ah = context.watch<AlumnosHolder>();
    final ch = context.watch<ClasesHolder>();
    final ph = context.watch<ProfesoresHolder>();

    if (profesorHolder.profesor != null &&
        profesorHolder.profesor!.director &&
        !ph.isInit) {
      context.read<ProfesoresHolder>().init();
    }

    _alumnos = ah.alumnos;
    _clases = ch.clases;
    _profesores = ph.profesores;

    if (_searchController.text.isEmpty) {
      _alumnosFiltrados = List.from(_alumnos);
    } else {
      _alumnosFiltrados = _alumnos
          .where(
            (alumno) => alumno.nombre.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    if (_searchController.text.isEmpty) {
      _clasesFiltradas = List.from(_clases);
    } else {
      // Aquí aplicamos el filtro si el usuario escribió algo en el buscador
      _clasesFiltradas = _clases
          .where(
            (clase) => clase.nombre.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    if (_searchController.text.isEmpty) {
      _profesoresFiltrados = List.from(_profesores);
    } else {
      _profesoresFiltrados = _profesores
          .where(
            (profesor) => profesor.nombre.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    final navigator = Navigator.of(context);

    //Seccion hecha con chatgpt
    if (profesorHolder.profesor == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.canPop()) navigator.pop();
      });
      return const SizedBox.shrink();
    }
    //Fin seccion hecha con chatgpt
    profesor = profesorHolder.profesor!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return; // Ya se hizo pop automáticamente, no hacemos nada
        // Mostrar el diálogo de confirmación
        mostrarDialogoCerrarSesion(context).then((confirmed) {
          salirFunc(confirmed, profesorHolder, navigator);
        });
      },
      child: ScaffoldComunV2(
        titulo: (currentPageIndex != 3
                  ? titulos[!profesor.director &&
                            (currentPageIndex == 1 || currentPageIndex == 2)
                        ? currentPageIndex + 1
                        : currentPageIndex]
                  : profesor.username),
        subtitulo: currentPageIndex != 3
            ? "${profesor.director ? "Administrador" : "Profesor"} ${profesor.nombre}"
            : null,
        header: _buildHeader(profesorHolder),
        navBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
              if (profesor.director) {
                _searchController.clear();
                _alumnosFiltrados = List.from(_alumnos);
                _profesoresFiltrados = List.from(_profesores);
              }
            });
          },
          selectedIndex: currentPageIndex,
          destinations: profesor.director
              ? <Widget>[
                  const NavigationDestination(
                    icon: Icon(Icons.group),
                    label: 'Alumnos',
                  ),
                  const NavigationDestination(
                    icon: const Icon(Icons.school),
                    label: 'Profesores',
                  ),
                  const NavigationDestination(
                    icon: const Icon(Icons.menu_book),
                    label: 'Clases',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.account_circle),
                    label: 'Perfil',
                  ),
                ]
              : <Widget>[
                  const NavigationDestination(
                    icon: Icon(Icons.group),
                    label: 'Alumnos',
                  ),
                  const NavigationDestination(
                    icon: const Icon(Icons.menu_book),
                    label: 'Clases',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.account_circle),
                    label: 'Perfil',
                  ),
                ],
        ),
        cuerpo:
            <Widget>[
              /// Alumnos page
              ListView.builder(
                reverse: false,
                itemCount: _alumnosFiltrados.length,
                itemBuilder: (BuildContext context, int index) {
                  return _alumnosFiltrados[index].widgetProfesorV2(onTap: () {
                    context.read<AlumnoHolder>().setAlumno(
                      _alumnosFiltrados[index],
                    );
                    navegar(EditarAlumno(), context);
                  }, icono: Icon(Icons.edit));
                },
              ),

              /// Profesores page
              Builder(
                builder: (context) {
                  if (ph.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    reverse: false,
                    padding: EdgeInsets.only(top: 8),
                    itemCount: _profesoresFiltrados.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _profesoresFiltrados[index].widgetProfesorV2(
                        context,
                        () {},
                      );
                    },
                  );
                },
              ),

              /// Clases page
              Builder(
                builder: (context) {
                  if (_clases.isEmpty) {
                    return const Center(child: Text('No hay clases'));
                  }

                  if (_searchController.text.isNotEmpty &&
                      _clasesFiltradas.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron clases'),
                    );
                  }

                  final double fabOverlapPadding =
                      88.0 + MediaQuery.of(context).padding.bottom;

                  return ListView.builder(
                    reverse: false,
                    padding: EdgeInsets.only(bottom: fabOverlapPadding, top: 8),
                    itemCount: _clasesFiltradas.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _clasesFiltradas[index].widgetClase(context, () {
                        navegar(EditarClaseV2(clase: _clasesFiltradas[index], allAlumnos: _alumnos), context);
                      });
                    },
                  );
                },
              ),

              /// Perfil page
              Center(
                child: PerfilProfesor(
                  profesor: profesor,
                  clases: profesor.director
                      ? _clases
                      : _clases
                            .where((clase) => clase.idTutor == profesor.id)
                            .toList(),
                ),
              ),
            ][!profesor.director &&
                    (currentPageIndex == 1 || currentPageIndex == 2)
                ? currentPageIndex + 1
                : currentPageIndex],
      ),
    );
  }

  void salirFunc(
    bool? confirmed,
    ProfesorHolder profesorHolder,
    NavigatorState navigator,
  ) {
    if (confirmed == true) {
      profesorHolder.clear();
      //context.read<ProfesoresHolder>().desconectar();
      navigator.pop();
    }
  }

  Future<bool?> mostrarDialogoCerrarSesion(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Evita cerrar tocando fuera del diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Salir'),
          content: const Text('¿Seguro que quieres salir?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false); // Cierra el diálogo
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Si', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
