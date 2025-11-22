import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/alumno.dart';
import 'package:tato_matematico/clase.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/login/profesorLogIn.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tato_matematico/login/alumnoLogin.dart';

class SeleccionAlumno extends StatefulWidget {
  Clase clase;
  SeleccionAlumno({super.key, required this.clase});

  @override
  State<SeleccionAlumno> createState() => _SeleccionAlumnoState();
}

class _SeleccionAlumnoState extends State<SeleccionAlumno> {
  List<Alumno> alumnos = [];
  int paginaActual = 0;
  final int itemsPorPagina = 12;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late DatabaseReference _alumnosRef;
  StreamSubscription<DatabaseEvent>? _subAdded;
  StreamSubscription<DatabaseEvent>? _subChanged;
  StreamSubscription<DatabaseEvent>? _subRemoved;
  Future<List<Alumno>>? _futureAlumnos;
  bool _yaCargado = false;

  @override
  initState() {
    super.initState();
    _alumnosRef = _dbRef.child('tato').child('alumnos');
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (!_yaCargado) {
      _futureAlumnos = _loadAlumnos();
      _yaCargado = true; // Para que no vuelva a ejecutarse
    }
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

  Future<List<Alumno>> _loadAlumnos() async {
    final snapshot = await _dbRef.child("tato").child("alumnos").get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final tempDir = await getTemporaryDirectory();
    for (final entry in data.entries) {
      if (widget.clase.alumnos.contains(entry.key)) {
        final alumnoData = Map<dynamic, dynamic>.from(entry.value);
        final alumno = Alumno.fromMap(entry.key, alumnoData);
        await alumno.descargarImagen(tempDir);
        print('Alumno cargado: $alumno');
        alumnos.add(alumno);
      }
    }
    _attachListenersAlumno();
    return alumnos;
  }

  @override
  void dispose() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();
    super.dispose();
  }

  void _attachListenersAlumno() {
    _subAdded = _alumnosRef.onChildAdded.listen(
      (event) => _handleChildAdded(event),
    );
    _subChanged = _alumnosRef.onChildChanged.listen(
      (event) => _handleChildChanged(event),
    );
  }

  Future<void> _handleChildAdded(DatabaseEvent event) async {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    // evita duplicados
    if (alumnos.any((a) => a.id == key)) return;
    if (!widget.clase.alumnos.contains(key)) return;
    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    final newAlumno = Alumno.fromMap(key, data);
    await newAlumno.descargarImagen(await getTemporaryDirectory());
    setState(() => alumnos.add(newAlumno));
    _futureAlumnos = Future.value(alumnos);
  }

  Future<void> _handleChildChanged(DatabaseEvent event) async {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    if (!widget.clase.alumnos.contains(key)) return;
    final index = alumnos.indexWhere((a) => a.id == key);
    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    final updated = Alumno.fromMap(key, data);
    await updated.descargarImagen(await getTemporaryDirectory());
    if (index != -1) {
      setState(() => alumnos[index] = updated);
    } else {
      // si no estaba, añadirlo
      setState(() => alumnos.add(updated));
    }
    _futureAlumnos = Future.value(alumnos);
  }

  @override
  Widget build(BuildContext context) {
    final double spacing = 8;
    final isTabletVar = isTablet(context);
    final int columnas = isTabletVar ? 4 : 3; // hasta 3 por fila

    return ScaffoldComunV2(
      titulo: 'Seleccion de alumno',
      subtitulo: "${widget.clase.nombre} - ${widget.clase.ano}",
      cuerpo: FutureBuilder<List<Alumno>>(
        future: _futureAlumnos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay alumnos'));
          }

          final alumnos = snapshot.data!;
          final int totalPaginas = (alumnos.length / itemsPorPagina).ceil();

          return SafeArea(
            child: Column(
              children: [
                SizedBox(height: 8),
                /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Iniciar sesion como ', style: TextStyle(fontSize: 16)),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {navegar(ProfesorLogIn(), context);},
                      child: Text("profesor", style: TextStyle(fontSize: 16, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
                 */
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
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

                        return GridAlumnos(
                          listaAlumnos: alumnos,
                          paginaActual: paginaActual,
                          totalPaginas: totalPaginas,
                          itemsPorPagina: itemsPorPagina,
                          crossAxisCount: columnas,
                          itemWidth: itemWidth,
                          itemHeight: itemHeight,
                          spacing: spacing,
                          totalItems: alumnos.length,
                        );
                      },
                    ),
                  ),
                ),
                BotonesInferiores(
                  onPrevious: retroceder(),
                  onNext: avanzar(totalPaginas),
                ),
              ],
            ),
          );
        },
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
        return alumnosPagina[index].widgetAlumno(context, () {
          context.read<AlumnoHolder>().setAlumno(alumnosPagina[index]);
          navegar(AlumnoLogIn(), context);
        });
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          SizedBox(height: 8),
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
