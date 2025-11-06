import 'package:flutter/material.dart';
import '../alumno.dart';

class AlumnListHolder extends ChangeNotifier {
  Future<List<Alumno>>? lista;

  AlumnListHolder({this.lista});

  void setList(Future<List<Alumno>> newAlumno) {
    lista = newAlumno;
    notifyListeners();
  }

  void clear() {
    lista = null;
    notifyListeners();
  }

  bool get hasList => lista != null;
}