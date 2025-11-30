import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/datos/profesor.dart';

/// **Nombre de la Clase: `ProfesorHolder`**
///
/// **Descripción:** Clase que permite gestionar el estado de el profesor que ha iniciado sesion en la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class ProfesorHolder extends ChangeNotifier {
  Profesor? profesor;
  StreamSubscription<DatabaseEvent>? _perfilSubscription;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  ProfesorHolder({this.profesor});

  void setProfesor(Profesor newProfesor) {
    profesor = newProfesor;
    _escucharCambiosPerfil(newProfesor.id);
    notifyListeners();
  }

  void _escucharCambiosPerfil(String id) {
    _perfilSubscription?.cancel();
    final perfilRef = _dbRef.child('tato').child('profesorado').child(id);

    _perfilSubscription = perfilRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

        final profesorActualizado = Profesor.fromMap(id, data);

        if (profesor != null &&
            profesor!.imagen == profesorActualizado.imagen) {
          profesorActualizado.foto = profesor!.foto;
          profesorActualizado.imagenLocal = profesor!.imagenLocal;
        }

        profesor = profesorActualizado;
        notifyListeners();
      }
    });
  }

  void clear() {
    _perfilSubscription?.cancel();
    _perfilSubscription = null;
    profesor = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _perfilSubscription?.cancel();
    super.dispose();
  }

  bool get hasProfesor => profesor != null;
}
