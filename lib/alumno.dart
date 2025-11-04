import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

class Alumno {
  String id;
  String nombre;
  String? imagen;
  String imagenLocal = '';
  Color? _colorFondo;
  Color? _colorBarraNav;
  Color? _colorBotones;
  bool _volverDerecha = false;

  Alumno({
    required this.id,
    required this.nombre,
    required this.imagen,
    Color? colorFondo,
    Color? colorBarraNav,
    Color? colorBotones,
    volverDerecha,
  }) {
    if (volverDerecha != null) {
      _volverDerecha = volverDerecha;
    }
    if (colorFondo != null) {
      _colorFondo = colorFondo;
    }
    if (colorBarraNav != null) {
      _colorBarraNav = colorBarraNav;
    }
    if (colorBotones != null) {
      _colorBotones = colorBotones;
    }
  }

  Color? get colorFondo => _colorFondo;

  set colorFondo(Color color) {
    _colorFondo = color;
  }

  bool get volverDerecha => _volverDerecha;

  set volverDerecha(bool value) {
    _volverDerecha = value;
  }

  Color? get colorBarraNav => _colorBarraNav;

  set colorBarraNav(Color value) {
    _colorBarraNav = value;
  }

  Color? get colorBotones => _colorBotones;

  set colorBotones(Color value) {
    _colorBotones = value;
  }

  @override
  String toString() {
    return 'Alumno{id: $id,nombre: $nombre, colorFondo : $colorFondo, colorBarraNav: $colorBarraNav, colorBotones: $colorBotones, imagen: $imagen, volverDerecha: $volverDerecha}';
  }

  factory Alumno.fromMap(String id, Map<dynamic, dynamic> data) {
    Color? colorFondoLoc, colorBotonesLoc, colorNavLoc;
    if (data['colorFondo'] != null) {
      int hex = int.parse(data['colorFondo']!, radix: 16);
      colorFondoLoc = Color(hex);
    }
    if (data['colorBarraNav'] != null) {
      int hex = int.parse(data['colorBarraNav']!, radix: 16);
      colorNavLoc = Color(hex);
    }

    if (data['colorBotones'] != null) {
      int hex = int.parse(data['colorBotones']!, radix: 16);
      colorBotonesLoc = Color(hex);
    }

    print("colorBotonesLoc: $colorBotonesLoc");

    return Alumno(
      id: id,
      nombre: data['nombre'] ?? 'Sin nombre',
      imagen: data['imagen'] ?? '',
      volverDerecha: data['volverDerecha'] ?? false,
      colorFondo: colorFondoLoc,
      colorBarraNav: colorNavLoc,
      colorBotones: colorBotonesLoc,
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

  Widget widgetAlumno(BuildContext context, VoidCallback navegar) {
    ImageProvider? imageProvider;
    if (imagenLocal.isNotEmpty) {
      imageProvider = FileImage(File(imagenLocal));
      // Si la ruta es una URL, podemos usar esta línea: (No funciona con rutas gs://)
      //imageProvider = imagenLocal.startsWith('http') ? NetworkImage(imagenLocal) : FileImage(File(imagenLocal));
    }

    var ori = MediaQuery.of(context).orientation;

    return InkWell(
      onTap: navegar,
      child: LayoutBuilder(
        builder: (context, constraints) {
          //El avatar ocupa 70% del ancho/alto de celda
          double size = ori == Orientation.portrait
              ? constraints.maxWidth * 0.7
              : constraints.maxHeight * 0.7;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircleAvatar(
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Text(
                          nombre.isNotEmpty ? nombre[0] : '?',
                          style: TextStyle(fontSize: size * 0.4),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nombre,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
