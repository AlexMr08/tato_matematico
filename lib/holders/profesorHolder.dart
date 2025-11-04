import 'package:flutter/material.dart';
import 'package:tato_matematico/profesor.dart';
import '../alumno.dart';

class ProfesorHolder extends ChangeNotifier {
  Profesor? profesor;

  ProfesorHolder({this.profesor});

  void setProfesor(Profesor newProfesor) {
    profesor = newProfesor;
    notifyListeners();
  }

  void clear() {
    profesor = null;
    notifyListeners();
  }

  bool get hasProfesor => profesor != null;
}