import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';
import 'package:tato_matematico/widgetsAuxiliares/fotoPerfil.dart';

// Asumo que tienes una clase Juego1Settings en el path especificado
// y que la clase Alumno se está definiendo aquí.

class Alumno {
  String id;
  String nombre;

  // Versión FINAL: Usamos un campo privado para controlar el setter y el cambio de caché
  String? _imagen;

  String imagenLocal = '';
  Color? _colorFondo;
  Color? _colorBarraNav;
  Color? _colorBotones;
  Color? _colorSeleccion;
  bool _volverDerecha = false;
  int? posicionBarra;
  // Versión FINAL: Usamos File? foto para la caché en memoria/disco
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
    // Versión FINAL: Quitamos 'this.' para que sea solo un parámetro y lo asignamos al inicializador
    required String? imagen,
    Color? colorFondo,
    Color? colorBarraNav,
    Color? colorBotones,
    Color? colorSeleccion,
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
    // Combinación: Inicializa _imagen, y usa la lógica de la izquierda para juego1Settings (con default)
  }) : _imagen = imagen,
        juego1Settings = juego1Settings ?? Juego1Settings(numeroOpciones: 4, numeroMayor: 10, numeroMenor: 0) {

    // El cuerpo del constructor permanece igual
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
    if (colorSeleccion != null) {
      _colorSeleccion = colorSeleccion;
    }
    if (posicionBarra != null) {
      this.posicionBarra = posicionBarra;
    }
  }

  // Versión FINAL: Getter y Setter para imagen que limpia la caché (foto) al cambiar la URL
  String? get imagen => _imagen;

  set imagen(String? value) {
    if (_imagen != value) {
      _imagen = value;
      // Al cambiar la URL, invalidamos la caché en memoria y disco
      foto = null;
      // imagenLocal = ''; // Opcional: Si queremos forzar la descarga, lo dejamos comentado por ahora.
    }
  }

  // Getters y Setters para colores y volverDerecha (Tomados de la versión de la izquierda, son idénticos a los de la final)
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

  Color? get colorSeleccion => _colorSeleccion;

  set colorSeleccion(Color? value) {
    _colorSeleccion = value;
  }

  @override
  String toString() {
    // Usamos _imagen en lugar de imagen, ya que es el campo real
    return 'Alumno{id: $id,nombre: $nombre, colorFondo : $colorFondo, colorBarraNav: $colorBarraNav, colorBotones: $colorBotones, imagen: $_imagen, volverDerecha: $volverDerecha}';
  }


  factory Alumno.fromMap(String id, Map<dynamic, dynamic> data) {
    Color? colorFondoLoc, colorBotonesLoc, colorNavLoc, colorSeleccionLoc;
    if (data['colorFondo'] != null) {
      // Manejo de null con operador de nulidad seguro
      final colorStr = data['colorFondo'] as String?;
      if (colorStr != null) {
        int hex = int.parse(colorStr, radix: 16);
        colorFondoLoc = Color(hex);
      }
    }
    if (data['colorBarraNav'] != null) {
      final colorStr = data['colorBarraNav'] as String?;
      if (colorStr != null) {
        int hex = int.parse(colorStr, radix: 16);
        colorNavLoc = Color(hex);
      }
    }

    if (data['colorBotones'] != null) {
      final colorStr = data['colorBotones'] as String?;
      if (colorStr != null) {
        int hex = int.parse(colorStr, radix: 16);
        colorBotonesLoc = Color(hex);
      }
    }

    if (data['colorSeleccion'] != null) {
      final colorStr = data['colorSeleccion'] as String?;
      if (colorStr != null) {
        int hex = int.parse(colorStr, radix: 16);
        colorSeleccionLoc = Color(hex);
      }
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
      colorSeleccion: colorSeleccionLoc,
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

  // Cache para widgetProfesor/widgetAlumno
  ImageProvider? _cachedImage;

  ImageProvider? get cachedImage {
    if (imagenLocal.isEmpty) return null;
    // La versión FINAL añade el null-aware operator para inicializar una sola vez
    _cachedImage ??= FileImage(File(imagenLocal));
    return _cachedImage;
  }

  // Versión FINAL: Limpia la caché de ImageProvider y del archivo File? foto
  void invalidarCachedImage() {
    _cachedImage = null;
    foto = null; // Limpiamos también la caché de archivo
  }

  Future<void> descargarImagen(
      Directory tempDir, {
        int maxBytes = 10 * 1024 * 1024,
      }) async {
    // Usamos _imagen que es el campo privado y real
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

      // Versión FINAL: Usa el nombre del archivo de Firebase para evitar la caché antigua del sistema
      String nombreArchivo = ref.name;
      final file = File('${tempDir.path}/$nombreArchivo');

      await file.writeAsBytes(bytes, flush: true);
      imagenLocal = file.path;
    } catch (e) {
      imagenLocal = '';
      return;
    }
  }

  // Lógica de obtención de imagen mejorada
  Future<File?> obtenerImagen(Directory tempDir) async {
    // 1. Caché en RAM (File? foto)
    if (foto != null) return foto;

    // 2. Caché en Disco (imagenLocal)
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

  // --- Widgets deprecados (widgetAlumno, widgetProfesor) ---
  // Mantenidos por si acaso, pero las versiones V2 con State mejoran la gestión de caché/carga.

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

  // --- Widgets V2 (usando State) ---

  Widget widgetAlumnoV2({required VoidCallback onTap}) {
    // Versión FINAL: Añade ValueKey para que Flutter distinga los widgets cuando la lista cambia
    return _AlumnViewCard(
        key: ValueKey(id),
        alumno: this,
        onTap: onTap
    );
  }

  Widget widgetProfesorV2({required VoidCallback onTap, required Icon icono}) {
    // Versión FINAL: Añade ValueKey basada en el ID y la URL de la imagen para forzar reconstrucción si cambia la imagen
    return _TeacherViewCard(
        key: ValueKey("${id}_${_imagen ?? ''}"),
        alumno: this,
        onTap: onTap,
        icono: icono
    );
  }
}

// -----------------------------------------------------------------------------
// --- _AlumnViewCard (StatefulWidget) ---
// -----------------------------------------------------------------------------

class _AlumnViewCard extends StatefulWidget {
  final Alumno alumno;
  final VoidCallback onTap;

  const _AlumnViewCard({
    Key? key, // Versión FINAL: Se añade Key
    required this.alumno,
    required this.onTap
  }) : super(key: key); // Versión FINAL: Se usa Key

  @override
  State<_AlumnViewCard> createState() => _AlumnViewCardState();

}

class _AlumnViewCardState extends State<_AlumnViewCard> {

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
                child: FotoPerfil(
                  key: ValueKey(widget.alumno.imagen),
                  nombre: widget.alumno.nombre,
                  idUnico: widget.alumno.imagen ?? widget.alumno.id,
                  onObtenerImagen: widget.alumno.obtenerImagen,
                  radio: 56,
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

// -----------------------------------------------------------------------------
// --- _TeacherViewCard (StatefulWidget) ---
// -----------------------------------------------------------------------------

class _TeacherViewCard extends StatefulWidget {
  final Alumno alumno;
  final Icon icono;
  final VoidCallback onTap;

  const _TeacherViewCard({
    Key? key, // Versión FINAL: Se añade Key
    required this.alumno,
    required this.onTap,
    required this.icono,
  }) : super(key: key); // Versión FINAL: Se usa Key

  @override
  State<_TeacherViewCard> createState() => _TeacherViewCardState();
}

class _TeacherViewCardState extends State<_TeacherViewCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: FotoPerfil(
          key: ValueKey(widget.alumno.imagen ?? widget.alumno.id),
          nombre: widget.alumno.nombre,
          idUnico: widget.alumno.imagen ?? widget.alumno.id,
          onObtenerImagen: widget.alumno.obtenerImagen,
          radio: 28,
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