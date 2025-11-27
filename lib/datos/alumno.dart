import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class Alumno {
  String id;
  String nombre;
  
  // Usamos un campo privado para controlar el setter
  String? _imagen;
  
  String imagenLocal = '';
  Color? _colorFondo;
  Color? _colorBarraNav;
  Color? _colorBotones;
  bool _volverDerecha = false;
  int? posicionBarra;
  File? foto;

  Alumno({
    required this.id,
    required this.nombre,
    required String? imagen, // Quitamos 'this.'
    Color? colorFondo,
    Color? colorBarraNav,
    Color? colorBotones,
    volverDerecha,
    posicionBarra,
  }) : _imagen = imagen { // Inicializamos el campo privado
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
    if (posicionBarra != null) {
      this.posicionBarra = posicionBarra;
    }
  }
  
  // Getter y Setter para imagen
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
    return 'Alumno{id: $id,nombre: $nombre, colorFondo : $colorFondo, colorBarraNav: $colorBarraNav, colorBotones: $colorBotones, imagen: $_imagen, volverDerecha: $volverDerecha}';
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

    return Alumno(
      id: id,
      nombre: data['nombre'] ?? 'Sin nombre',
      imagen: data['imagen'] ?? '',
      volverDerecha: data['volverDerecha'] ?? false,
      colorFondo: colorFondoLoc,
      colorBarraNav: colorNavLoc,
      colorBotones: colorBotonesLoc,
      posicionBarra: data['posicionBarra'],
    );
  }

  ImageProvider? _cachedImage;

  ImageProvider? get cachedImage {
    if (imagenLocal.isEmpty) return null;
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

  Widget widgetAlumno(BuildContext context, VoidCallback navegar) {
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
                  backgroundImage: cachedImage,
                  child: cachedImage == null
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

  Widget widgetProfesor(BuildContext c, VoidCallback navegar, Icon icono) {
    ImageProvider? imageProvider;
    if (imagenLocal.isNotEmpty) {
      imageProvider = FileImage(File(imagenLocal));
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
        trailing: IconButton(icon: icono, onPressed: navegar),
        onTap: null,
      ),
    );
  }

  Future<File?> obtenerImagen(Directory tempDir) async {
    // 1. Caché en RAM
    if (foto != null) return foto;

    // 2. Caché en Disco
    if (imagenLocal.isNotEmpty) {
      final archivoDisco = File(imagenLocal);
      if (await archivoDisco.exists()) {
        foto = archivoDisco;
        return foto;
      }
    }

    // 3. Descarga
    await descargarImagen(tempDir);

    if (imagenLocal.isNotEmpty) {
      final archivoRecienDescargado = File(imagenLocal);
      if (await archivoRecienDescargado.exists()) {
        foto = archivoRecienDescargado;
        return foto;
      }
    }

    return null;
  }

  Widget widgetAlumnoV2({required VoidCallback onTap}) {
    // Usamos una Key basada en el ID para que Flutter sepa distinguir widgets
    return _AlumnViewCard(
      key: ValueKey(id), 
      alumno: this, 
      onTap: onTap
    );
  }

  Widget widgetProfesorV2({required VoidCallback onTap, required Icon icono}) {
    // Usamos una Key basada en la imagen para forzar la reconstrucción si cambia la URL
    return _TeacherViewCard(
      key: ValueKey("${id}_${_imagen ?? ''}"), 
      alumno: this, 
      onTap: onTap, 
      icono: icono
    );
  }
}

class _AlumnViewCard extends StatefulWidget {
  final Alumno alumno;
  final VoidCallback onTap;

  const _AlumnViewCard({
    Key? key,
    required this.alumno, 
    required this.onTap
  }) : super(key: key);

  @override
  State<_AlumnViewCard> createState() => _AlumnViewCardState();

}

class _AlumnViewCardState extends State<_AlumnViewCard> {
  File? _imagenLocal;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarImagen();
  }

  @override
  void didUpdateWidget(covariant _AlumnViewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alumno.id != widget.alumno.id) {
      setState(() {
        _imagenLocal = null;
        _cargando = true;
      });
      _cargarImagen();
    }
  }

  Future<void> _cargarImagen() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final archivo = await widget.alumno.obtenerImagen(tempDir);

      if (mounted) {
        setState(() {
          _imagenLocal = archivo;
          _cargando = false;
        });
      }
    } catch (e) {
      print("Error UI Alumno: $e");
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _obtenerIniciales(String nombre) {
    if (nombre.isEmpty) return "";
    List<String> palabras = nombre.trim().split(" ");
    String iniciales = "";
    if (palabras.isNotEmpty) {
      iniciales += palabras[0][0];
      if (palabras.length > 1) {
        iniciales += palabras[1][0];
      }
    }
    return iniciales.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _imagenLocal != null
                    ? Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: FileImage(_imagenLocal!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 45,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          _obtenerIniciales(widget.alumno.nombre),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.alumno.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherViewCard extends StatefulWidget {
  final Alumno alumno;
  final Icon icono;
  final VoidCallback onTap;

  const _TeacherViewCard({
    Key? key, // Añadido Key al constructor
    required this.alumno,
    required this.onTap,
    required this.icono,
  }) : super(key: key);

  @override
  State<_TeacherViewCard> createState() => _TeacherViewCardState();
}

class _TeacherViewCardState extends State<_TeacherViewCard> {
  File? _imagenLocal;
  bool _cargando = true;
  // Guardamos la URL para detectar cambios si el objeto muta sin reconstrucción del widget
  String? _lastImagenUrl;

  @override
  void initState() {
    super.initState();
    _lastImagenUrl = widget.alumno.imagen;
    _cargarImagen();
  }

  @override
  void didUpdateWidget(covariant _TeacherViewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Comparamos la URL actual con la última conocida por este Estado
    if (widget.alumno.imagen != _lastImagenUrl) {
      _lastImagenUrl = widget.alumno.imagen;
      widget.alumno.invalidarCachedImage(); // Aseguramos que se limpie la caché
      _cargarImagen();
    }
  }

  Future<void> _cargarImagen() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final archivo = await widget.alumno.obtenerImagen(tempDir);

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
      if (palabras.length > 1) {
        iniciales += palabras[1][0];
      }
    }
    return iniciales.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_imagenLocal != null) {
      imageProvider = FileImage(_imagenLocal!);
    } else if (widget.alumno.imagenLocal.isNotEmpty) {
        imageProvider = FileImage(File(widget.alumno.imagenLocal));
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
                  widget.alumno.nombre.isNotEmpty ? _obtenerIniciales(widget.alumno.nombre) : '?',
                  style: const TextStyle(fontSize: 20),
                )
              : null,
        ),
        title: Text(
          widget.alumno.nombre,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(icon: widget.icono, onPressed: widget.onTap),
        onTap: null,
      ),
    );
  }
}
