import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:tato_matematico/widgetsAuxiliares/fotoPerfil.dart';

/// **Nombre de la Clase: `Profesor`**
///
/// **Descripción:** clase que representa a un profesor en el sistema.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Gonzalo Alganza Luque
/// * **Fecha de modificación:** 02/12/2025
/// * **Último cambio:** Se han eliminado los metodos de los widgets que son dañinos para el rendimiento
///

class Profesor {
  String id;
  String nombre;
  String username;
  String? _imagen;
  String imagenLocal = '';
  bool director;
  File? foto;

  Profesor({
    required this.id,
    required this.nombre,
    required String? imagen,
    required this.username,
    required this.director,
  }) : _imagen = imagen;

  String? get imagen => _imagen;

  set imagen(String? value) {
    if (_imagen != value) {
      _imagen = value;
      // Al cambiar la URL, invalidamos la caché en memoria
      foto = null;
      // Opcional: Invalidar imagenLocal si queremos forzar descarga
      // imagenLocal = '';
    }
  }

  @override
  String toString() {
    return 'Profesor{id: $id,nombre: $nombre, imagen: $imagen, esDirector: $director}';
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

  ImageProvider? _cachedImage;

  ImageProvider? get cachedImage {
    if (imagenLocal.isEmpty) _cachedImage = null;
    _cachedImage ??= FileImage(File(imagenLocal));
    return _cachedImage;
  }

  // Invalidar la imágen de caché para poder editarla
  void invalidarCachedImage() {
    _cachedImage = null;
    foto = null; // Limpiamos también la caché de archivo
  }

  //Descarga una imagen de 10MB como maximo
  Future<void> descargarImagen(
    Directory tempDir, {
    int maxBytes = 10 * 1024 * 1024,
  }) async {
    if (_imagen == null || _imagen!.isEmpty) {
      imagenLocal = '';
      return;
    }

    try {
      final storage = FirebaseStorage.instance;
      Reference ref = storage.refFromURL(_imagen!);
      final Uint8List? bytes = await ref.getData(maxBytes);
      if (bytes == null) {
        imagenLocal = '';
        return;
      }

      // Usamos el nombre del archivo de Firebase (ej. timestamp_perfil.jpg) para evitar caché antiguo
      String nombreArchivo = ref.name;
      final file = File('${tempDir.path}/$nombreArchivo');

      await file.writeAsBytes(bytes, flush: true);
      imagenLocal = file.path;
    } catch (e) {
      imagenLocal = '';
      return;
    }
  }

  void actualizarNombre(String nuevoNombre) {
    nombre = nuevoNombre;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    dbRef.child("tato").child("profesorado").child(id).update({
      "nombre": nuevoNombre,
    });
  }

  void actualizarDirector(bool nuevoAdmin) {
    director = nuevoAdmin;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    dbRef.child("tato").child("profesorado").child(id).update({
      "director": nuevoAdmin,
    });
  }

  Future<File?> obtenerImagen(Directory tempDir) async {
    // B. Si hay ruta local, verificar si existe el archivo
    if (imagenLocal.isNotEmpty) {
      final archivoDisco = File(imagenLocal);
      if (await archivoDisco.exists()) {
        foto = archivoDisco;
      }
    } else {
      await descargarImagen(tempDir);

      // Verificar si se descargó bien
      if (imagenLocal.isNotEmpty) {
        final archivoRecienDescargado = File(imagenLocal);
        if (await archivoRecienDescargado.exists()) {
          foto = archivoRecienDescargado;
        }
      }
    }
    return foto;
  }

  @deprecated
  Widget widgetProfesorV2(BuildContext context, VoidCallback navegar) {
    return ProfesorCard(key: ValueKey(imagen), profesor: this, onTap: navegar);
  }
}

/// **Nombre de la Clase: `_ProfesorCardInternal`**
///
/// **Descripción:** clase que gestiona como se muestra la tarjeta de un profesor.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class ProfesorCard extends StatefulWidget {
  final Profesor profesor;
  final VoidCallback onTap;

  const ProfesorCard({super.key, required this.profesor, required this.onTap});

  @override
  State<ProfesorCard> createState() => _ProfesorCardState();
}

class _ProfesorCardState extends State<ProfesorCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: FotoPerfil(
          key: ValueKey(widget.profesor.imagen),
          nombre: widget.profesor.nombre,
          idUnico: widget.profesor.imagen ?? widget.profesor.id,
          onObtenerImagen: widget.profesor.obtenerImagen,
          radio: 28,
        ),
        title: Text(
          widget.profesor.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.profesor.director ? "Administrador" : "Profesor"),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Editar profesor',
          onPressed: widget.onTap,
        ),
      ),
    );
  }
}
