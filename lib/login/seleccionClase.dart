import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/clase.dart';
import 'package:tato_matematico/holders/clasesHolder.dart';
import 'package:tato_matematico/login/profesorLogIn.dart';
import 'package:tato_matematico/login/seleccionAlumno.dart';

class SeleccionClase extends StatefulWidget {
  @override
  State<SeleccionClase> createState() => _SeleccionClaseState();
}

class _SeleccionClaseState extends State<SeleccionClase> {
  Future<List<Clase>>? _futureClases;
  List<Clase> _clases = [];
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late DatabaseReference _clasesRef;
  bool _isLoading = true;
  StreamSubscription<DatabaseEvent>? _subAdded;
  StreamSubscription<DatabaseEvent>? _subChanged;
  StreamSubscription<DatabaseEvent>? _subRemoved;

  @override
  void initState() {
    super.initState();
    _clasesRef = _dbRef.child('tato').child('clases');

    // Cargamos datos iniciales y LUEGO escuchamos cambios
    /*
    _loadClases().then((clases) {
      if (mounted) {
        setState(() {
          _clases = clases;
          _isLoading = false; // Ya no estamos cargando
        });
        _attachListenersAlumno(); // Escuchamos cambios DESPUÉS de la carga inicial
      }
    });
     */
  }

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

  /*
  void _attachListenersAlumno() {
    _subAdded = _clasesRef.onChildAdded.listen(
      (event) => _handleChildAdded(event),
    );
    _subChanged = _clasesRef.onChildChanged.listen(
      (event) => _handleChildChanged(event),
    );
  }

  @override
  void dispose() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();
    super.dispose();
  }

  Future<void> _handleChildAdded(DatabaseEvent event) async {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    // evita duplicados
    if (_clases.any((a) => a.id == key)) return;
    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    final newAlumno = Clase.fromMap(key, data);
    setState(() => _clases.add(newAlumno));
    _futureClases = Future.value(_clases);
  }

  Future<void> _handleChildChanged(DatabaseEvent event) async {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    final index = _clases.indexWhere((a) => a.id == key);
    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    final updated = Clase.fromMap(key, data);

    if (index != -1) {
      // Si existe, actualizamos SOLO ese elemento en la lista
      // Usamos setState para avisar que LA LISTA cambió, pero Flutter es inteligente
      // y el ListView solo repintará lo necesario si las Keys son correctas (ver build)
      setState(() => _clases[index] = updated);
    } else {
      setState(() => _clases.add(updated));
    }
    // ELIMINAR ESTA LÍNEA: _futureClases = Future.value(_clases);
  }
  @override
  Widget build(BuildContext context) {
    ClasesHolder hc = context.watch<ClasesHolder>();
    var clases = hc.clases;
    return ScaffoldComunV2(
      titulo: "Seleccion de clase",
      funcionLeading: (){navegar(ProfesorLogIn(), context);},
      iconoLeading: Icons.school,
      // Ya no usamos FutureBuilder para la UI principal, usamos la variable de estado
      cuerpo: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clases.isEmpty
          ? const Center(child: Text('No hay clases'))
          : ListView.builder(
              padding: EdgeInsets.only(
                bottom: 88.0 + MediaQuery.of(context).padding.bottom,
                top: 8,
              ),
              itemCount: clases.length,
              itemBuilder: (BuildContext context, int index) {
                // IMPORTANTE: Asigna una KEY única basada en el ID
                final clase = clases[index];
                return KeyedSubtree(
                  key: ValueKey(
                    clase.id,
                  ), // <--- Esto ayuda a Flutter a saber cuál widget actualizar
                  child: clase.widgetClase(context, () {
                    navegar(SeleccionAlumno(clase: clase), context);
                  }),
                );
              },
            ),
    );
  }

  Future<List<Clase>> _loadClases() async {
    var _dbRef = FirebaseDatabase.instance.ref();
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
    clases.sort((a, b) => b.ano.compareTo(a.ano));
    _clases = clases;
    return clases;
  }

 */
}
