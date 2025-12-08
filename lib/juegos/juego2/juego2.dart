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
/// * **Fecha de modificación:** 07/12/2025
/// * **Último cambio:** Se ha creado el metodo map
///

class Juego2 extends Juego {
  final bool ordenDescendente;
  Juego2({
    required super.min,
    required super.max,
    required super.cantidad,
    required super.usaImagenes,
    required super.tipoImagenes,
    required this.ordenDescendente,
  }) : super(id: 'juego2', nombre: 'Juego 2', icono: Icons.videogame_asset);

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
      min: data["min"] ?? 1,
      max: data["max"] ?? 10,
      cantidad: data["cantidad"] ?? 10,
      ordenDescendente: data["ordenDescendente"] ?? false,
      usaImagenes: data["imagenes"] ?? false,
      tipoImagenes: data["tipoImagenes"] ?? "numeros",
    );
  }
}
