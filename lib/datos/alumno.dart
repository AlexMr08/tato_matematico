import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';

class Alumno {
  String id;
  String nombre;
  String? imagen;
  String imagenLocal = '';
  Color? _colorFondo;
  Color? _colorBarraNav;
  Color? _colorBotones;
  bool _volverDerecha = false;
  int? posicionBarra;
  File? foto;
  bool permisoAjustesJuego1;
  bool permisoEstadisticasJuego1;
  bool mostrarPuntuacionJuego1;
  
  // Ajustes de sonido Juego 1
  String? vozJuego1;
  double ttsRateJuego1;
  double ttsVolumeJuego1;
  double ttsPitchJuego1;
  String sonidoAciertoJuego1;
  bool sonidoAciertoActivadoJuego1;
  String sonidoFalloJuego1;
  bool sonidoFalloActivadoJuego1;

  Juego1Settings juego1Settings;

  Alumno({
    required this.id,
    required this.nombre,
    required this.imagen,
    Color? colorFondo,
    Color? colorBarraNav,
    Color? colorBotones,
    this.permisoAjustesJuego1 = true,
    this.permisoEstadisticasJuego1 = true,
    this.mostrarPuntuacionJuego1 = true,
    this.vozJuego1,
    this.ttsRateJuego1 = 0.5,
    this.ttsVolumeJuego1 = 1.0,
    this.ttsPitchJuego1 = 1.0,
    this.sonidoAciertoJuego1 = 'Pim',
    this.sonidoAciertoActivadoJuego1 = true,
    this.sonidoFalloJuego1 = 'Pton',
    this.sonidoFalloActivadoJuego1 = true,
    Juego1Settings? juego1Settings,
    volverDerecha,
    posicionBarra,
  }) : juego1Settings = juego1Settings ?? Juego1Settings(numeroOpciones: 4, numeroMayor: 10, numeroMenor: 0) {
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

  Color? get colorFondo => _colorFondo;

  set colorFondo(Color? color) {
    _colorFondo = color;
  }

  bool get volverDerecha => _volverDerecha;

  set volverDerecha(bool value) {
    _volverDerecha = value;
  }

  Color? get colorBarraNav => _colorBarraNav;

  set colorBarraNav(Color? value) {
    _colorBarraNav = value;
  }

  Color? get colorBotones => _colorBotones;

  set colorBotones(Color? value) {
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

    Juego1Settings? juego1Settings;
    if (data['juego1Settings'] != null) {
      final settingsMap = data['juego1Settings'] as Map<dynamic, dynamic>;
      juego1Settings = Juego1Settings(
        numeroOpciones: settingsMap['numeroOpciones'] ?? 4,
        numeroMayor: settingsMap['numeroMayor'] ?? 10,
        numeroMenor: settingsMap['numeroMenor'] ?? 0,
      );
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
      permisoAjustesJuego1: data['permisoAjustesJuego1'] ?? true,
      permisoEstadisticasJuego1: data['permisoEstadisticasJuego1'] ?? true,
      mostrarPuntuacionJuego1: data['mostrarPuntuacionJuego1'] ?? true,
      vozJuego1: data['vozJuego1'],
      ttsRateJuego1: (data['ttsRateJuego1'] as num? ?? 0.5).toDouble(),
      ttsVolumeJuego1: (data['ttsVolumeJuego1'] as num? ?? 1.0).toDouble(),
      ttsPitchJuego1: (data['ttsPitchJuego1'] as num? ?? 1.0).toDouble(),
      sonidoAciertoJuego1: data['sonidoAciertoJuego1'] ?? 'Pim',
      sonidoAciertoActivadoJuego1: data['sonidoAciertoActivadoJuego1'] ?? true,
      sonidoFalloJuego1: data['sonidoFalloJuego1'] ?? 'Pton',
      sonidoFalloActivadoJuego1: data['sonidoFalloActivadoJuego1'] ?? true,
      juego1Settings: juego1Settings,
    );
  }

  ImageProvider? _cachedImage;

  ImageProvider? get cachedImage {
    if (imagenLocal.isEmpty) return null;
    _cachedImage ??= FileImage(File(imagenLocal));
    return _cachedImage;
  }

  void invalidarCachedImage() {
    _cachedImage = null;
  }

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
    if (foto != null) return foto;

    if (imagenLocal.isNotEmpty) {
      final archivoDisco = File(imagenLocal);
      if (await archivoDisco.exists()) {
        foto = archivoDisco;
        return foto;
      }
    }

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
    return _AlumnViewCard(alumno: this, onTap: onTap);
  }

  Widget widgetProfesorV2({
    required VoidCallback onTap,
    required Icon icono,
  }) {
    return _TeacherViewCard(alumno: this, onTap: onTap, icono: icono,);
  }
}

class _AlumnViewCard extends StatefulWidget {
  final Alumno alumno;
  final VoidCallback onTap;

  const _AlumnViewCard({required this.alumno, required this.onTap});

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
                            fit: BoxFit
                                .cover, 
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 45,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Text(
                          _obtenerIniciales(widget.alumno.nombre),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
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

  const _TeacherViewCard({required this.alumno, required this.onTap, required this.icono});

  @override
  State<_TeacherViewCard> createState() => _TeacherViewCardState();
}

class _TeacherViewCardState extends State<_TeacherViewCard> {
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
    ImageProvider? imageProvider;
    Alumno alum = widget.alumno;
    if (alum.imagenLocal.isNotEmpty) {
      imageProvider = FileImage(File(alum.imagenLocal));
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
            alum.nombre.isNotEmpty ? _obtenerIniciales(alum.nombre) : '?',
            style: const TextStyle(fontSize: 20),
          )
              : null,
        ),
        title: Text(
          alum.nombre,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(icon: widget.icono, onPressed: widget.onTap),
        onTap: null,
      ),
    );
  }
}
