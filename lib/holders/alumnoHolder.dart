import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/juegos/juego2/juego2.dart';
import '../datos/alumno.dart';

/// **Nombre de la Clase: `AlumnoHolder`**
///
/// **Descripción:** Clase que permite gestionar el estado del alumno que ha iniciado sesion en la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 07/12/2025
/// * **Último cambio:** Se ha añadido lo necesario para cargar los juegos (de momento limitado al 2)
///

class AlumnoHolder extends ChangeNotifier {
  Alumno? alumno;
  Juego2? juego2;
  StreamSubscription<DatabaseEvent>? _perfilSubscription;
  StreamSubscription<DatabaseEvent>? _juegosSubscription;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  var isLoaded = false;

  AlumnoHolder({this.alumno});

  void setAlumno(Alumno newAlumno) {
    alumno = newAlumno;
    _escucharCambiosPerfil(newAlumno.id);
    cargarJuegos();
    notifyListeners();
  }

  Future<void> cargarJuegos() async {
    if (alumno == null) return;
    // Apuntamos específicamente al nodo del juego 2
    var dbRef = FirebaseDatabase.instance.ref().child(
      "tato/juegos/${alumno!.id}",
    );

    try {
      final snapshot = await dbRef.get();
      print(snapshot.value);
      if (snapshot.exists && snapshot.value != null) {
        for (var child in snapshot.children) {
          if (child.key == "juego2") {
            // Convertimos los datos de Firebase (que suelen ser dynamic) a Map<String, dynamic>
            final data = Map<String, dynamic>.from(child.value as Map);
            juego2 = Juego2.fromMap(data);
          }
        }

        // Avisamos a las vistas que el juego ya está cargado
        notifyListeners();
        isLoaded = true;
        _escucharCambiosJuegos(alumno!.id);
      }
    } catch (e) {
      print("Error cargando configuración del Juego 2: $e");
    }
  }

  void _escucharCambiosJuegos(String id) {
    _juegosSubscription?.cancel();
    final juegosRef = _dbRef.child('tato/juegos/$id');
    _juegosSubscription = juegosRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        if (data.containsKey('juego2')) {
          final juego2Data = Map<dynamic, dynamic>.from(data['juego2'] as Map);
          juego2 = Juego2.fromMap(juego2Data);
        }
        if (data.containsKey('juego1')) {
          print("TODO");
        }
      }
    });
  }

  void _escucharCambiosPerfil(String id) {
    _perfilSubscription?.cancel();
    final perfilRef = _dbRef.child('tato').child('alumnos').child(id);

    _perfilSubscription = perfilRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

        final alumnoActualizado = Alumno.fromMap(id, data);

        if (alumno != null && alumno!.imagen == alumnoActualizado.imagen) {
          alumnoActualizado.foto = alumno!.foto;
          alumnoActualizado.imagenLocal = alumno!.imagenLocal;
        }

        alumno = alumnoActualizado;
        notifyListeners();
      }
    });
  }

  void clear() {
    _perfilSubscription?.cancel();
    _perfilSubscription = null;
    _juegosSubscription?.cancel();
    _juegosSubscription = null;
    alumno = null;
    notifyListeners();
  }

  void setColorFondo(Color color) {
    if (alumno != null) {
      alumno!.colorFondo = color;
      notifyListeners();
    }
  }

  void setBarraNav(Color color) {
    if (alumno != null) {
      alumno!.colorBarraNav = color;
      notifyListeners();
    }
  }

  void setColorBotones(Color color) {
    if (alumno != null) {
      alumno!.colorBotones = color;
      notifyListeners();
    }
  }

  void setColorSeleccion(Color color) {
    if (alumno != null) {
      alumno!.colorSeleccion = color;
      notifyListeners();
    }
  }

  bool get hasAlumno => alumno != null;
}
