import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../datos/alumno.dart';

/// **Nombre de la Clase: `AlumnoHolder`**
///
/// **Descripción:** Clase que permite gestionar el estado del alumno que ha iniciado sesion en la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 04/12/2025
/// * **Último cambio:** Se ha añadido un metodo para la actualizacion del alumno
///

class AlumnoHolder extends ChangeNotifier {
  Alumno? alumno;
  StreamSubscription<DatabaseEvent>? _perfilSubscription;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  AlumnoHolder({this.alumno});

  void setAlumno(Alumno newAlumno) {
    alumno = newAlumno;
    _escucharCambiosPerfil(newAlumno.id);
    notifyListeners();
  }

  void _escucharCambiosPerfil(String id) {
    _perfilSubscription?.cancel();
    final perfilRef = _dbRef.child('tato').child('profesorado').child(id);

    _perfilSubscription = perfilRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

        final alumnoActualizado = Alumno.fromMap(id, data);

        if (alumno != null &&
            alumno!.imagen == alumnoActualizado.imagen) {
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
