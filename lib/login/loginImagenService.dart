import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tato_matematico/pictograma.dart';

/// Servicio encargado de la lógica de negocio para login con imagenes.
///
/// Gestiona la recuperación de imágenes desde Firebase,
/// diferencia entre distractores manuales y aleatorios.
class LoginImagenService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Genera una lista de [Pictograma] para mostrarla en el grid de login.
  ///
  /// * [idsCorrectos]: Lista de IDs que son la contraseña.
  /// * [idsDistractoresManuales]: Lista de IDs que son incorrectos configurados por el profesor.
  /// * [totalImagenes]: Cantidad total de imagenes que se mostrarán en el grid.
  /// * [esAleatorio]: Si es `true`, rellena imagenes incorrectas con aleatorias de la biblioteca.
  ///
  /// Devuelve una `List<Pictograma>` ya mezclada y ajustada al total de imagenes en el grid.
  Future<List<Pictograma>> generarGrid({
    required List<String> idsCorrectos, // Puede ser uno (imagen) o varios (secuencia)
    required List<String> idsDistractoresManuales,
    required int totalImagenes,
    required bool esAleatorio,
  }) async {
    List<Pictograma> resultado = [];

    // CARGA MANUAL RAPIDA
    if (!esAleatorio) {
      resultado = await _cargarGridManual(idsCorrectos, idsDistractoresManuales);

      // Si se ha borrado alguna imagen de la necesaria, se escoge al azar.
      if (resultado.length < totalImagenes) {
        debugPrint("Advertencia: Faltan imágenes manuales. Rellenando con aleatorias.");
        List<Pictograma> extra = await _cargarGridAleatorio(
            idsCorrectos,
            totalImagenes - resultado.length
        );

        for (var picto in extra) {
          if (!resultado.any((p) => p.id == picto.id)) {
            resultado.add(picto);
          }
        }
      }
    }
    // CARGA ALEATORIA
    else {
      resultado = await _cargarGridAleatorio(idsCorrectos, totalImagenes);
    }

    // Recortar si nos hemos pasado y mezclar
    if (resultado.length > totalImagenes) {
      resultado = resultado.sublist(0, totalImagenes);
    }
    resultado.shuffle();

    return resultado;
  }

  /// Descargar solo los IDs específicos
  ///
  /// Si las imagenes incorrectas se han configurado manualmente,
  /// solo se descargan estas de Firebase en vez de descargar toda la biblioteca.
  Future<List<Pictograma>> _cargarGridManual(List<String> correctos, List<String> manuales) async {
    // Usamos un Set para fusionar correctas e incorrectas y eliminar duplicados
    Set<String> todosIds = {...correctos, ...manuales};
    List<Pictograma> lista = [];

    // Lanzamos peticiones paralelas a Firebase para reducir el tiempo de espera
    List<Future<DataSnapshot>> futuros = todosIds.map((id) {
      return _db.child("tato/bibliotecaImagenes/$id").get();
    }).toList();

    List<DataSnapshot> snapshots = await Future.wait(futuros);

    for (var snap in snapshots) {
      if (snap.exists && snap.value != null) {
        try {
          lista.add(Pictograma.fromMap(snap.key!, snap.value as Map));
        } catch (e) {
          debugPrint("Error pictograma manual: $e");
        }
      }
    }
    return lista;
  }

  /// Descargar toda la biblioteca
  ///
  /// Como las imágenes incorrectas se eligen al azar tenemos que escoger entre
  /// todas la imágenes de la biblioteca.
  Future<List<Pictograma>> _cargarGridAleatorio(List<String> correctos, int cantidadTotal) async {
    // Descargar toda la biblioteca de imágenes
    final snap = await _db.child("tato/bibliotecaImagenes").get();
    List<Pictograma> biblioteca = [];
    List<Pictograma> seleccion = [];

    if (snap.exists && snap.value != null) {
      final map = Map<String, dynamic>.from(snap.value as Map);
      map.forEach((key, value) {
        biblioteca.add(Pictograma.fromMap(key, value));
      });
    }

    // Aseguramos que la imagen correcta está presente
    for (var id in correctos) {
      try {
        var picto = biblioteca.firstWhere((p) => p.id == id);
        seleccion.add(picto);
      } catch (e) {
        debugPrint("Imagen correcta $id no encontrada en biblioteca");
      }
    }

    // Rellenamos las incorrectas y las mezclamos
    List<Pictograma> bolsaRestante = List.from(biblioteca)
      ..removeWhere((p) => correctos.contains(p.id));

    bolsaRestante.shuffle();

    while (seleccion.length < cantidadTotal && bolsaRestante.isNotEmpty) {
      seleccion.add(bolsaRestante.removeAt(0));
    }

    return seleccion;
  }
}