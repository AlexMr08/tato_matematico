import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/datos/juego.dart';

class Juego1 extends Juego {
  Juego1({
    super.min = 0,
    super.max = 10,
    super.cantidad = 10,
    super.usaImagenes = false,
    super.tipoImagenes = "numeros",
  }) : super(id: 'juego1', nombre: 'Juego 1', icono: Icons.videogame_asset);

  @override
  Future<void> guardarAjustes({
    required String idAlumno,
    required int rango,
    required int cantidad,
    required String tema,
    required DatabaseReference dbRef,
    bool? orden,
  }) async {
    var dbRef2 = dbRef.child("tato/juegos/$idAlumno/$id");
    dbRef2.update({"ordenDescendente": orden});
    super.guardarAjustes(
      idAlumno: idAlumno,
      rango: rango,
      cantidad: cantidad,
      tema: tema,
      dbRef: dbRef2,
    );
  }

  List<int> generarNuevoJuego() {
    List<int> res = [];
    while (res.length < cantidad) {
      int num = generarNuevoNumero();
      if (!res.contains(num)) {
        res.add(num);
      }
    }
    return res;
  }

  factory Juego1.fromMap(Map<dynamic, dynamic> data) {
    return Juego1(
      min: data["min"] ?? 0,
      max: data["max"] ?? 10,
      cantidad: data["cantidad"] ?? 8,
      usaImagenes: data["imagenes"] ?? false,
      tipoImagenes: data["tipoImagenes"] ?? "numeros",
    );
  }
}
