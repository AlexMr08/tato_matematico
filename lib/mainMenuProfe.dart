import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComun.dart';
import 'package:tato_matematico/agregarProfesor.dart';
import 'package:tato_matematico/edicion%20alumnos/editarAlumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/colorPicker.dart';
import 'package:tato_matematico/perfilProfesor.dart';
import 'package:tato_matematico/profesor.dart';
import 'package:tato_matematico/clase.dart';
import 'package:tato_matematico/edicion/editarClase.dart';
import 'package:tato_matematico/agregarAlumno.dart';


import 'alumno.dart';
import 'holders/profesorHolder.dart';

class MainMenuProfe extends StatefulWidget {
  const MainMenuProfe({super.key});
  @override
  State<MainMenuProfe> createState() => _MainMenuProfeState();
}

class _MainMenuProfeState extends State<MainMenuProfe> {
  int currentPageIndex = 0;
  bool esDirector = true;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Future<List<Alumno>>? _futureAlumnos;
  Future<List<Profesor>>? _futureProfesores;
  Future<List<Clase>>? _futureClases;
  late Profesor profesor;
  final TextEditingController _searchController = TextEditingController();
  List<Alumno> _alumnosFiltrados = [];
  List<Alumno> _alumnos = [];
  List<Profesor> _profesoresFiltrados = [];
  List<Profesor> _profesores = [];
  List<Clase> _clases = [];
  Clase? claseActual;
  bool editandoClase = false;
  bool _yaCargado = false;
  List<String> titulos = ["Listado de Alumnos", "Listado de Profesores", "Clases", "Perfil"];

  @override
  initState() {
    super.initState();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_yaCargado) {
      final profesorHolder = context.read<ProfesorHolder>();

      // Si el profesor ya está listo, podemos tomar una decisión
      if (profesorHolder.profesor != null) {
        // Siempre carga los alumnos
        _futureAlumnos = _loadAlumnos();
        _futureClases = _loadClases();
        // Solo carga profesores si es director
        if (profesorHolder.profesor!.director) {
          _futureProfesores = _loadProfesores(profesorHolder);
        }
        _yaCargado = true; // Para que no vuelva a ejecutarse
      }
    }
  }
  Widget _buildHeader(ProfesorHolder profesorHolder) {
    String texto = "";
    switch (currentPageIndex) {
      case 0:
        texto = "alumno";
        break;
      case 1:
        texto = "profesor";
        break;
      default:
        return SizedBox.shrink();
    }
    if(profesor.director == false && currentPageIndex == 1){
      return SizedBox.shrink();
    }
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primary, // mismo color
          child:
          Center(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 700,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (currentPageIndex == 0){
                        setState(() {
                          _alumnosFiltrados = _alumnos
                              .where((alumno) => alumno.nombre
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      }
                      if (currentPageIndex == 1){
                        setState(() {
                          _profesoresFiltrados = _profesores
                              .where((profesor) => profesor.nombre
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Buscar $texto",
                      filled: true,
                      fillColor: Colors.white,
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
                  // ALUMNOS
                  if (currentPageIndex == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgregarAlumno()),
                    ).then((value) {
                      if (value == true) {
                        setState(() {
                          _futureAlumnos = _loadAlumnos();
                        });
                      }
                    });
                  }
                  if (currentPageIndex == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgregarProfesor()),
                    ).then((value) {
                      if (value == true) {
                        setState(() {
                          _futureProfesores = _loadProfesores(profesorHolder);
                        });
                      }
                    });
                  }
                },
                label: Text("Añadir $texto"),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          ),
        );
  }

  Future<List<Profesor>> _loadProfesores(ProfesorHolder profesorHolder) async {
    final snapshot = await _dbRef.child("tato").child("profesorado").get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final tempDir = await getTemporaryDirectory();

    final List<Profesor> profesores = [];
    for (final entry in data.entries) {
      final profesorData = Map<dynamic, dynamic>.from(entry.value);
      final profesor = Profesor.fromMap(entry.key, profesorData);
      await profesor.descargarImagen(tempDir);
      print('Profesor cargado: $profesor');
      if(profesor.id != profesorHolder.profesor!.id) {
        profesores.add(profesor);
      }else{
        profesorHolder.setProfesor(profesor);
      }
    }
    _profesores = profesores;
    _profesoresFiltrados = List.from(profesores);
    return profesores;
  }

  Future<List<Alumno>> _loadAlumnos() async {
    final snapshot = await _dbRef.child("tato").child("alumnos").get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final tempDir = await getTemporaryDirectory();

    final List<Alumno> alumnos = [];
    for (final entry in data.entries) {
      final alumnoData = Map<dynamic, dynamic>.from(entry.value);
      final alumno = Alumno.fromMap(entry.key, alumnoData);
      await alumno.descargarImagen(tempDir);
      print('Alumno cargado: $alumno');
      alumnos.add(alumno);
    }
    _alumnos = alumnos;
    _alumnosFiltrados = List.from(alumnos);
    return alumnos;
  }

  Future<List<Clase>> _loadClases() async {
    final snapshot = await _dbRef.child("tato").child("clases").get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final List<Clase> clases = [];

    for (final entry in data.entries) {
      print("-----------------------------------");
      print(entry.value);
      final claseData = Map<String, dynamic>.from(entry.value as Map);
      final clase = Clase.fromMap(entry.key, claseData);
      clases.add(clase);
      print('Clase cargada: $clase');
    }

    _clases = clases;
    return clases;
  }

  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final profesorHolder = context.watch<ProfesorHolder>();
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
      child: ScaffoldComun(
        titulo: editandoClase ? "Edición de Clase" : (currentPageIndex != 3 ? titulos [!profesor.director && (currentPageIndex == 1 || currentPageIndex == 2) ? currentPageIndex + 1  : currentPageIndex]: profesor.username),
        subtitulo: currentPageIndex != 3 ? (profesor.director ? "Administrador" : "Profesor") + " ${profesor.nombre}" : null,
        funcionSalir: () {
          mostrarDialogoCerrarSesion(context).then((confirmed) {
            salirFunc(confirmed, profesorHolder, navigator);
          });
        },
        header: _buildHeader(profesorHolder),
        navBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
              if (profesor.director && (index == 0 || index == 1)) {
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
                    label: 'Clases'
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
                    label: 'Clases'
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.account_circle),
                    label: 'Perfil',
                  ),
                ],
        ),
        cuerpo: <Widget>[
          /// Alumnos page
          FutureBuilder(
            future: _futureAlumnos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay alumnos'));
              }
              final double fabOverlapPadding =
                  88.0 + MediaQuery.of(context).padding.bottom;

              return ListView.builder(
                reverse: false,
                padding: EdgeInsets.only(bottom: fabOverlapPadding, top: 8),
                itemCount: _alumnosFiltrados.length,
                itemBuilder: (BuildContext context, int index) {
                  return _alumnosFiltrados[index].widgetProfesor(context, () {
                    context.read<AlumnoHolder>().setAlumno(_alumnosFiltrados[index]);
                    navegar(EditarAlumno(), context);
                  }, Icon(Icons.edit) );
                },
              );
            },
          ),

          /// Profesores page
          FutureBuilder(
            future: _futureProfesores,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay profesores'));
              }
              final double fabOverlapPadding =
                  88.0 + MediaQuery.of(context).padding.bottom;

              return ListView.builder(
                reverse: false,
                padding: EdgeInsets.only(bottom: fabOverlapPadding, top: 8),
                itemCount: _profesoresFiltrados.length,
                itemBuilder: (BuildContext context, int index) {
                  return _profesoresFiltrados[index].widgetProfesor(context, () {});
                },
              );
            },
          ),

          /// Clases page
          FutureBuilder(
            future: _futureClases,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay clases'));
              }

              if (editandoClase && claseActual != null) {
                return EditarClase(
                  clase: claseActual!,
                  allAlumnos: _alumnos,
                  salirDeEdicion: () {
                    setState(() {
                      editandoClase = false;
                      claseActual = null;
                    });
                  },
                );
              }


              final double fabOverlapPadding =
                  88.0 + MediaQuery.of(context).padding.bottom;
              return ListView.builder(
                reverse: false,
                padding: EdgeInsets.only(bottom: fabOverlapPadding, top: 8),
                itemCount: _clases.length,
                itemBuilder: (BuildContext context, int index) {
                  return _clases[index].widgetClase(context, () {
                    setState(() {
                      claseActual = _clases[index];
                      editandoClase = true;
                    });
                  });
                },
              );
            },
          ),

          /// Perfil page
          Center(
            child: PerfilProfesor(profesor: profesor, clases: profesor.director ? _clases : _clases.where((clase) => clase.idTutor == profesor.id).toList())
          ),
        ][!profesor.director && (currentPageIndex == 1 || currentPageIndex == 2) ? currentPageIndex + 1  : currentPageIndex],
      ),
    );
  }

  void salirFunc(
    bool? confirmed,
    ProfesorHolder alumnoHolder,
    NavigatorState navigator,
  ) {
    if (confirmed == true) {
      alumnoHolder.clear();
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

