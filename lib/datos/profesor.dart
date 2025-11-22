import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class Profesor {
  String id;
  String nombre;
  String username;
  String? imagen;
  String imagenLocal = '';
  bool director;
  File? foto;

  Profesor({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.username,
    required this.director,
  });

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

  void actualizarNombre(String nuevoNombre) {
    nombre = nuevoNombre;
    DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
    _dbRef.child("tato").child("profesorado").child(id).update({
      "nombre": nuevoNombre,
    });
  }

  Future<File?> obtenerImagen(Directory tempDir) async {
    // A. Si ya está en RAM, devolverla
    if (foto != null) return foto;

    // B. Si hay ruta local, verificar si existe el archivo
    if (imagenLocal.isNotEmpty) {
      final archivoDisco = File(imagenLocal);
      if (await archivoDisco.exists()) {
        foto = archivoDisco;
        return foto;
      }
    }

    // C. Si no, descargar de Firebase (aquí llamas a tu lógica de descarga existente)
    // Asumo que tienes un método 'descargarImagen' que baja el archivo y actualiza 'imagenLocal'
    await descargarImagen(tempDir);

    // Verificar si se descargó bien
    if (imagenLocal.isNotEmpty) {
      final archivoRecienDescargado = File(imagenLocal);
      if (await archivoRecienDescargado.exists()) {
        foto = archivoRecienDescargado;
        return foto;
      }
    }
    return null;
  }

  Widget widgetProfesorV2(BuildContext context, VoidCallback navegar) {
    return _ProfesorCardInternal(profesor: this, onTap: navegar);
  }

  Widget widgetProfesor(BuildContext context, VoidCallback navegar) {
    ImageProvider? imageProvider;
    if (imagenLocal.isNotEmpty) {
      imageProvider = FileImage(File(imagenLocal));
      // Si la ruta es una URL, podemos usar esta línea: (No funciona con rutas gs://)
      //imageProvider = imagenLocal.startsWith('http') ? NetworkImage(imagenLocal) : FileImage(File(imagenLocal));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
                  nombre.isNotEmpty ? nombre[0] : '?',
                  style: const TextStyle(fontSize: 20),
                )
              : null,
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(icon: Icon(Icons.edit), onPressed: navegar),
        onTap: null,
      ),
    );
  }
}

class _ProfesorCardInternal extends StatefulWidget {
  final Profesor profesor;
  final VoidCallback onTap;

  const _ProfesorCardInternal({
    Key? key,
    required this.profesor,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_ProfesorCardInternal> createState() => _ProfesorCardInternalState();
}

class _ProfesorCardInternalState extends State<_ProfesorCardInternal> {
  File? _imagenLocal;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarImagen();
  }

  Future<void> _cargarImagen() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final archivo = await widget.profesor.obtenerImagen(tempDir);
      if (mounted) {
        setState(() {
          _imagenLocal = archivo;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _obtenerIniciales(String nombre) {
    if (nombre.isEmpty) return "";
    List<String> palabras = nombre.trim().split(" ");
    String iniciales = "";
    if (palabras.isNotEmpty) {
      iniciales += palabras[0][0];
      if (palabras.length > 1) iniciales += palabras[1][0];
    }
    return iniciales.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    Profesor profe = widget.profesor;
    if (profe.imagenLocal.isNotEmpty) {
      imageProvider = FileImage(File(profe.imagenLocal));
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: widget.onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
            profe.nombre.isNotEmpty ? _obtenerIniciales(profe.nombre) : '?',
            style: const TextStyle(fontSize: 20),
          )
              : null,
        ),
        title: Text(
          widget.profesor.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.profesor.director ? "Director" : "Profesor"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
