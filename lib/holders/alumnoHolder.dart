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
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class AlumnoHolder extends ChangeNotifier {
  Alumno? alumno;

  AlumnoHolder({this.alumno});

  void setAlumno(Alumno newAlumno) {
    alumno = newAlumno;
    notifyListeners();
  }

  void clear() {
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
