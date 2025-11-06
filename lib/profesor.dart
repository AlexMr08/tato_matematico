import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

class Profesor {
  String id;
  String nombre;
  String username;
  String? imagen;
  String imagenLocal = '';
  bool director;

  Profesor({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.username,
    required this.director,
  });


  @override
  String toString() {
    return 'Alumno{id: $id,nombre: $nombre, imagen: $imagen, esDirector: $director}';
  }

  factory Profesor.fromMap(String id, Map<dynamic, dynamic> data) {
    return Profesor(
      id: id,
      nombre: data['nombre'] ?? 'Sin nombre',
      imagen: data['imagen'] ?? '',
      username: data['username'] ?? '',
      director: data['director'] ?? false,
    );
  }

  //Descarga una imagen de 10MB como maximo
  Future<void> descargarImagen(
      Directory tempDir, {
        int maxBytes = 10 * 1024 * 1024,
      }) async {
    if (imagen == null || imagen!.isEmpty) {
      imagenLocal = '';
      return;
    }

    try {
      final storage = FirebaseStorage.instance;
      Reference ref = storage.refFromURL(imagen!);
      final Uint8List? bytes = await ref.getData(maxBytes);
      if (bytes == null) {
        imagenLocal = '';
        return;
      }

      final file = File('${tempDir.path}/${id}_avatar.jpg');
      await file.writeAsBytes(bytes, flush: true);
      imagenLocal = file.path;
      //return await ref.getDownloadURL();
    } catch (e) {
      imagenLocal = '';
      return;
    }
  }

}