import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';
import 'package:tato_matematico/widgetsAuxiliares/fotoPerfil.dart';

/// **Nombre de la Clase: `Alumno`**
///
/// **Descripción:** clase que representa a un alumno en el sistema.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se han añadido los campos para los ajustes de color y sonido
///

class Alumno {
  String id;
  String nombre;
  String? _imagen;
  String imagenLocal = '';
  Color? _colorFondo;
  Color? _colorBarraNav;
  Color? _colorBotones;
  Color? _colorSeleccion;
  Color? _colorContenedor;
  bool _volverDerecha = false;
  int? posicionBarra;
  File? foto;

  bool permisoEstadisticasJuego1;
  bool mostrarPuntuacionJuego1;

  bool permisoAjustesJuego1;
  bool permisoAjustesJuego2;
  bool permisoAjustesJuego3;
  bool permisoAjustesJuego4;
  bool permisoColor;
  bool permisoSonido;

  // Ajustes de sonido Juego 1
  String? vozJuego1;
  double ttsRateJuego1;
  double ttsVolumeJuego1;
  double ttsPitchJuego1;
  String sonidoAciertoJuego1;
  bool sonidoAciertoActivadoJuego1;
  String sonidoFalloJuego1;
  bool sonidoFalloActivadoJuego1;
  String? sonidoEleccionJuego1;

  // Ajustes de sonido Globales (nuevos)
  String? sonidoEleccion;
  String sonidoAcierto;
  bool sonidoAciertoActivado;
  String sonidoFallo;
  bool sonidoFalloActivado;
  double ttsRate;
  double ttsVolume;
  double ttsPitch;

  Juego1Settings juego1Settings;

  Alumno({
    required this.id,
    required this.nombre,
    required String? imagen,
    Color? colorFondo,
    Color? colorBarraNav,
    Color? colorBotones,
    Color? colorSeleccion,
    Color? colorContenedor,
    this.permisoAjustesJuego1 = true,
    this.permisoEstadisticasJuego1 = true,
    this.mostrarPuntuacionJuego1 = true,
    // Antiguos
    this.vozJuego1,
    this.ttsRateJuego1 = 0.5,
    this.ttsVolumeJuego1 = 1.0,
    this.ttsPitchJuego1 = 1.0,
    this.sonidoAciertoJuego1 = 'Pim',
    this.sonidoAciertoActivadoJuego1 = true,
    this.sonidoFalloJuego1 = 'Pton',
    this.sonidoFalloActivadoJuego1 = true,
    this.sonidoEleccionJuego1,
    // Nuevos
    this.sonidoEleccion,
    this.sonidoAcierto = 'Pim',
    this.sonidoAciertoActivado = true,
    this.sonidoFallo = 'Pton',
    this.sonidoFalloActivado = true,
    this.ttsRate = 0.5,
    this.ttsVolume = 1.0,
    this.ttsPitch = 1.0,

    Juego1Settings? juego1Settings,
    volverDerecha,
    posicionBarra,
    this.permisoAjustesJuego2 = true,
    this.permisoAjustesJuego3 = true,
    this.permisoAjustesJuego4 = true,
    this.permisoColor = true,
    this.permisoSonido = true,
    // Combinación: Inicializa _imagen, y usa la lógica de la izquierda para juego1Settings (con default)
  }) : _imagen = imagen,
       juego1Settings =
           juego1Settings ??
           Juego1Settings(numeroOpciones: 4, numeroMayor: 10, numeroMenor: 0) {
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
    if (colorContenedor != null) {
      _colorContenedor = colorContenedor;
    }
    if (posicionBarra != null) {
      this.posicionBarra = posicionBarra;
    }
  }

  String? get imagen => _imagen;

  set imagen(String? value) {
    if (_imagen != value) {
      _imagen = value;
      foto = null;
    }
  }

  Color? get colorFondo => _colorFondo;
  set colorFondo(Color? color) => _colorFondo = color;

  Color? get colorContenedor => _colorContenedor;

  set colorContenedor(Color? color) {
    _colorContenedor = color;
  }

  bool get volverDerecha => _volverDerecha;
  set volverDerecha(bool value) => _volverDerecha = value;

  Color? get colorBarraNav => _colorBarraNav;
  set colorBarraNav(Color? value) => _colorBarraNav = value;

  Color? get colorBotones => _colorBotones;
  set colorBotones(Color? value) => _colorBotones = value;

  Color? get colorSeleccion => _colorSeleccion;
  set colorSeleccion(Color? value) => _colorSeleccion = value;

  Color? get colorTextos => _colorSeleccion;
  set colorTextos(Color? value) => _colorSeleccion = value;

  @override
  String toString() {
    return 'Alumno{id: $id,nombre: $nombre, colorFondo : $colorFondo, colorBarraNav: $colorBarraNav, colorBotones: $colorBotones, imagen: $_imagen, volverDerecha: $volverDerecha}';
  }

  factory Alumno.fromMap(String id, Map<dynamic, dynamic> data) {
    Color? colorFondoLoc,
        colorBotonesLoc,
        colorNavLoc,
        colorSeleccionLoc,
        colorContenedorLoc;
    if (data['colorFondo'] != null) {
      final colorStr = data['colorFondo'] as String?;
      if (colorStr != null) colorFondoLoc = Color(int.parse(colorStr, radix: 16));
    }
    if (data['colorBarraNav'] != null) {
      final colorStr = data['colorBarraNav'] as String?;
      if (colorStr != null) colorNavLoc = Color(int.parse(colorStr, radix: 16));
    }
    if (data['colorBotones'] != null) {
      final colorStr = data['colorBotones'] as String?;
      if (colorStr != null) colorBotonesLoc = Color(int.parse(colorStr, radix: 16));
    }
    if (data['colorSeleccion'] != null) {
      final colorStr = data['colorSeleccion'] as String?;
      if (colorStr != null) colorSeleccionLoc = Color(int.parse(colorStr, radix: 16));
    }

    if (data['colorContenedor'] != null) {
      final colorStr = data['colorContenedor'] as String?;
      if (colorStr != null) {
        int hex = int.parse(colorStr, radix: 16);
        colorContenedorLoc = Color(hex);
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
      colorContenedor: colorContenedorLoc,
      posicionBarra: data['posicionBarra'],
      permisoAjustesJuego1: data['permisoAjustesJuego1'] ?? true,
      permisoEstadisticasJuego1: data['permisoEstadisticasJuego1'] ?? true,
      mostrarPuntuacionJuego1: data['mostrarPuntuacionJuego1'] ?? true,
      // Antiguos
      vozJuego1: data['vozJuego1'],
      ttsRateJuego1: (data['ttsRateJuego1'] as num? ?? 0.5).toDouble(),
      ttsVolumeJuego1: (data['ttsVolumeJuego1'] as num? ?? 1.0).toDouble(),
      ttsPitchJuego1: (data['ttsPitchJuego1'] as num? ?? 1.0).toDouble(),
      sonidoAciertoJuego1: data['sonidoAciertoJuego1'] ?? 'Pim',
      sonidoAciertoActivadoJuego1: data['sonidoAciertoActivadoJuego1'] ?? true,
      sonidoFalloJuego1: data['sonidoFalloJuego1'] ?? 'Pton',
      sonidoFalloActivadoJuego1: data['sonidoFalloActivadoJuego1'] ?? true,
      sonidoEleccionJuego1: data['sonidoEleccionJuego1'],
      // Nuevos
      sonidoEleccion: data['sonidoEleccion'],
      sonidoAcierto: data['sonidoAcierto'] ?? 'Pim',
      sonidoAciertoActivado: data['sonidoAciertoActivado'] ?? true,
      sonidoFallo: data['sonidoFallo'] ?? 'Pton',
      sonidoFalloActivado: data['sonidoFalloActivado'] ?? true,
      ttsRate: (data['ttsRate'] as num? ?? 0.5).toDouble(),
      ttsVolume: (data['ttsVolume'] as num? ?? 1.0).toDouble(),
      ttsPitch: (data['ttsPitch'] as num? ?? 1.0).toDouble(),
      juego1Settings: juego1Settings,
      permisoAjustesJuego2: data['permisoAjustesJuego2'] ?? true,
      permisoAjustesJuego3: data['permisoAjustesJuego3'] ?? true,
      permisoAjustesJuego4: data['permisoAjustesJuego4'] ?? true,
      permisoColor: data['permisoColor'] ?? true,
      permisoSonido: data['permisoSonido'] ?? true,
    );
  }

  ImageProvider? _cachedImage;

  ImageProvider? get cachedImage {
    if (imagenLocal.isEmpty) _cachedImage = null;
    // La versión FINAL añade el null-aware operator para inicializar una sola vez
    _cachedImage ??= FileImage(File(imagenLocal));
    return _cachedImage;
  }

  void invalidarCachedImage() {
    _cachedImage = null;
    foto = null;
  }

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

      String nombreArchivo = ref.name;
      final file = File('${tempDir.path}/$nombreArchivo');

      await file.writeAsBytes(bytes, flush: true);
      imagenLocal = file.path;
    } catch (e) {
      imagenLocal = '';
      return;
    }
  }

  Future<File?> obtenerImagen(Directory tempDir) async {
    // 1. Caché en RAM (File? foto)
    File? res;
    if (foto != null) {
      res = foto;
    }

    if (imagenLocal.isNotEmpty) {
      final archivoDisco = File(imagenLocal);
      if (await archivoDisco.exists()) {
        foto = archivoDisco;
      }
    } else {
      // 2. Descarga
      await descargarImagen(tempDir);

      if (imagenLocal.isNotEmpty) {
        final archivoRecienDescargado = File(imagenLocal);
        if (await archivoRecienDescargado.exists()) {
          foto = archivoRecienDescargado;
        }
      }
    }

    return foto;
  }
}

    return null;
  }

  @deprecated
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

  @deprecated
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

  @deprecated
  Widget widgetAlumnoV2({required VoidCallback onTap}) {
    return AlumnViewCard(key: ValueKey(id), alumno: this, onTap: onTap);
  }

  @deprecated
  Widget widgetProfesorV2({required VoidCallback onTap, required Icon icono}) {
    return TeacherViewCard(
      key: ValueKey("${id}_${_imagen ?? ''}"),
      alumno: this,
      onTap: onTap,
      icono: icono,
    );
  }
}

class AlumnViewCard extends StatefulWidget {
  final Alumno alumno;
  final VoidCallback onTap;

  const AlumnViewCard({
    super.key,
    required this.alumno,
    required this.onTap,
  });

  @override
  State<AlumnViewCard> createState() => _AlumnViewCardState();
}

class _AlumnViewCardState extends State<AlumnViewCard> {
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

/// **Nombre de la Clase: `TeacherViewCard`**
///
/// **Descripción:** clase que gestiona la vista de un alumno en la perspectiva del profesor.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Se ha añadido un boton para acceder a las estadisticas
///

class TeacherViewCard extends StatefulWidget {
  final Alumno alumno;
  final Icon icono;
  final VoidCallback onTap;
  final VoidCallback onEstadisticasTap;
  final bool verStats;

  const TeacherViewCard({
    super.key,
    required this.alumno,
    required this.onTap,
    required this.icono,
    required this.onEstadisticasTap,
    this.verStats = false,
  });

  @override
  State<TeacherViewCard> createState() => _TeacherViewCardState();
}

class _TeacherViewCardState extends State<TeacherViewCard> {
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?widget.verStats
                ? IconButton(
                    icon: const Icon(Icons.bar_chart),
                    tooltip: 'Ver Estadísticas',
                    onPressed: widget.verStats
                        ? () {
                            widget.onEstadisticasTap();
                          }
                        : null,
                  )
                : null,
            IconButton(icon: widget.icono, onPressed: widget.onTap),
          ],
        ),

        onTap: null,
      ),
    );
  }
}
