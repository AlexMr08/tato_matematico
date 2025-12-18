import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/datos/juego.dart';

/// **Nombre de la Clase: `Juego2**
///
/// **Descripción:** Clase que representa el segundo juego de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 12/12/2025
/// * **Último cambio:** Se ha añadido un metodo de guardado en BD
///

class Juego2 extends Juego {
  final bool ordenDescendente;
  Juego2({
    super.min = 0,
    super.max = 10,
    super.cantidad = 10,
    super.usaImagenes = false,
    super.tipoImagenes = "numeros",
    this.ordenDescendente = false,
  }) : super(id: 'juego2', nombre: 'Juego 2', icono: Icons.videogame_asset, imagen: "assets/images/ordenar.png");

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

  factory Juego2.fromMap(Map<dynamic, dynamic> data) {
    return Juego2(
      min: data["min"] ?? 0,
      max: data["max"] ?? 10,
      cantidad: data["cantidad"] ?? 8,
      ordenDescendente: data["ordenDescendente"] ?? false,
      usaImagenes: data["imagenes"] ?? false,
      tipoImagenes: data["tipoImagenes"] ?? "numeros",
    );
  }
}
