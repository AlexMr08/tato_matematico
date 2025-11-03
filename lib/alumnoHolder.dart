import 'package:flutter/material.dart';
import 'alumno.dart';

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

  void setColorPrincipal(Color color) {
    if (alumno != null) {
      alumno!.colorPrincipal = color;
      notifyListeners();
    }
  }

  bool get hasAlumno => alumno != null;
}