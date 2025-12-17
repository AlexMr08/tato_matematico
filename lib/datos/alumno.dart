'''
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';
import 'package:tato_matematico/widgetsAuxiliares/fotoPerfil.dart';

// Definición movida de ScaffoldAlumno.dart para evitar importaciones circulares
enum PosicionBarra { arriba, abajo, izquierda, derecha }

class Alumno {
  String id;
  String nombre;
  String? _imagen;
  String imagenLocal = '';
  File? foto;

  // Colores
  Color? colorFondo;
  Color? colorBarraNav;
  Color? colorBotones;
  Color? colorSeleccion;
  Color? colorContenedor;

  // Ajustes de Interfaz
  bool volverDerecha = false;
  int? posicionBarra;

  // --- AJUSTES GLOBALES DE SONIDO Y VOZ ---
  String? sonidoEleccion;
  String sonidoAcierto;
  bool sonidoAciertoActivado;
  String sonidoFallo;
  bool sonidoFalloActivado;
  String? voz;
  double ttsRate;
  double ttsVolume;
  double ttsPitch;

  // --- PERMISOS GLOBALES ---
  bool permisoColor;
  bool permisoSonido;

  // --- AJUSTES Y PERMISOS POR JUEGO ---
  bool permisoAjustesJuego1;
  bool permisoEstadisticasJuego1;
  bool mostrarPuntuacionJuego1;
  Juego1Settings juego1Settings;

  bool permisoAjustesJuego2;
  bool permisoAjustesJuego3;
  bool permisoAjustesJuego4;

  Alumno({
    required this.id,
    required this.nombre,
    required String? imagen,
    this.colorFondo,
    this.colorBarraNav,
    this.colorBotones,
    this.colorSeleccion,
    this.colorContenedor,
    this.volverDerecha = false,
    this.posicionBarra,
    
    // Globales
    this.permisoColor = true,
    this.permisoSonido = true,
    this.sonidoEleccion,
    this.sonidoAcierto = 'Pim',
    this.sonidoAciertoActivado = true,
    this.sonidoFallo = 'Pton',
    this.sonidoFalloActivado = true,
    this.voz,
    this.ttsRate = 0.5,
    this.ttsVolume = 1.0,
    this.ttsPitch = 1.0,
    
    // Juego 1
    this.permisoAjustesJuego1 = true,
    this.permisoEstadisticasJuego1 = true,
    this.mostrarPuntuacionJuego1 = true,
    Juego1Settings? juego1Settings,
    
    // Otros juegos
    this.permisoAjustesJuego2 = true,
    this.permisoAjustesJuego3 = true,
    this.permisoAjustesJuego4 = true,

  }) : _imagen = imagen,
       juego1Settings = juego1Settings ?? Juego1Settings(numeroOpciones: 4, numeroMayor: 10, numeroMenor: 0);

  String? get imagen => _imagen;
  set imagen(String? value) {
    if (_imagen != value) {
      _imagen = value;
      foto = null;
    }
  }

  Color? get colorTextos => colorSeleccion;
  set colorTextos(Color? value) => colorSeleccion = value;

  // --- COMPATIBILIDAD HACIA ATRÁS (los campos antiguos ahora apuntan a los nuevos) ---
  double get ttsRateJuego1 => ttsRate;
  set ttsRateJuego1(double value) => ttsRate = value;
  
  double get ttsVolumeJuego1 => ttsVolume;
  set ttsVolumeJuego1(double value) => ttsVolume = value;

  double get ttsPitchJuego1 => ttsPitch;
  set ttsPitchJuego1(double value) => ttsPitch = value;

  String? get vozJuego1 => voz;
  set vozJuego1(String? value) => voz = value;

  String get sonidoAciertoJuego1 => sonidoAcierto;
  set sonidoAciertoJuego1(String value) => sonidoAcierto = value;

  bool get sonidoAciertoActivadoJuego1 => sonidoAciertoActivado;
  set sonidoAciertoActivadoJuego1(bool value) => sonidoAciertoActivado = value;

  String get sonidoFalloJuego1 => sonidoFallo;
  set sonidoFalloJuego1(String value) => sonidoFallo = value;

  bool get sonidoFalloActivadoJuego1 => sonidoFalloActivado;
  set sonidoFalloActivadoJuego1(bool value) => sonidoFalloActivado = value;
  
  String? get sonidoEleccionJuego1 => sonidoEleccion;
  set sonidoEleccionJuego1(String? value) => sonidoEleccion = value;

  // --- CONVERSIÓN DE DATOS ---

  factory Alumno.fromMap(String id, Map<dynamic, dynamic> data) {
    Color? parseColor(String? hex) {
      return hex != null ? Color(int.parse(hex, radix: 16)) : null;
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
      imagen: data['imagen'],
      volverDerecha: data['volverDerecha'] ?? false,
      colorFondo: parseColor(data['colorFondo']),
      colorBarraNav: parseColor(data['colorBarraNav']),
      colorBotones: parseColor(data['colorBotones']),
      colorSeleccion: parseColor(data['colorSeleccion']),
      colorContenedor: parseColor(data['colorContenedor']),
      posicionBarra: data['posicionBarra'],
      
      permisoColor: data['permisoColor'] ?? true,
      permisoSonido: data['permisoSonido'] ?? true,
      
      permisoAjustesJuego1: data['permisoAjustesJuego1'] ?? true,
      permisoEstadisticasJuego1: data['permisoEstadisticasJuego1'] ?? true,
      mostrarPuntuacionJuego1: data['mostrarPuntuacionJuego1'] ?? true,

      permisoAjustesJuego2: data['permisoAjustesJuego2'] ?? true,
      permisoAjustesJuego3: data['permisoAjustesJuego3'] ?? true,
      permisoAjustesJuego4: data['permisoAjustesJuego4'] ?? true,
      
      sonidoEleccion: data['sonidoEleccion'] ?? data['sonidoEleccionJuego1'],
      sonidoAcierto: data['sonidoAcierto'] ?? data['sonidoAciertoJuego1'] ?? 'Pim',
      sonidoAciertoActivado: data['sonidoAciertoActivado'] ?? data['sonidoAciertoActivadoJuego1'] ?? true,
      sonidoFallo: data['sonidoFallo'] ?? data['sonidoFalloJuego1'] ?? 'Pton',
      sonidoFalloActivado: data['sonidoFalloActivado'] ?? data['sonidoFalloActivadoJuego1'] ?? true,
      
      voz: data['voz'] ?? data['vozJuego1'],
      ttsRate: (data['ttsRate'] as num? ?? data['ttsRateJuego1'] as num? ?? 0.5).toDouble(),
      ttsVolume: (data['ttsVolume'] as num? ?? data['ttsVolumeJuego1'] as num? ?? 1.0).toDouble(),
      ttsPitch: (data['ttsPitch'] as num? ?? data['ttsPitchJuego1'] as num? ?? 1.0).toDouble(),
      
      juego1Settings: juego1Settings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'imagen': _imagen,
      'colorFondo': colorFondo?.value.toRadixString(16),
      'colorBarraNav': colorBarraNav?.value.toRadixString(16),
      'colorBotones': colorBotones?.value.toRadixString(16),
      'colorSeleccion': colorSeleccion?.value.toRadixString(16),
      'colorContenedor': colorContenedor?.value.toRadixString(16),
      'volverDerecha': volverDerecha,
      'posicionBarra': posicionBarra,
      
      'permisoColor': permisoColor,
      'permisoSonido': permisoSonido,

      'permisoAjustesJuego1': permisoAjustesJuego1,
      'permisoEstadisticasJuego1': permisoEstadisticasJuego1,
      'mostrarPuntuacionJuego1': mostrarPuntuacionJuego1,

      'permisoAjustesJuego2': permisoAjustesJuego2,
      'permisoAjustesJuego3': permisoAjustesJuego3,
      'permisoAjustesJuego4': permisoAjustesJuego4,

      'sonidoEleccion': sonidoEleccion,
      'sonidoAcierto': sonidoAcierto,
      'sonidoAciertoActivado': sonidoAciertoActivado,
      'sonidoFallo': sonidoFallo,
      'sonidoFalloActivado': sonidoFalloActivado,
      'voz': voz,
      'ttsRate': ttsRate,
      'ttsVolume': ttsVolume,
      'ttsPitch': ttsPitch,
      
      'juego1Settings': juego1Settings.toMap(),
    };
  }

  // --- WIDGETS Y OTROS MÉTODOS ---

  ImageProvider? _cachedImage;

  ImageProvider? get cachedImage {
    if (imagenLocal.isEmpty) return null;
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
}

// Clases de Widgets movidas aquí para simplicidad en este paso

class AlumnViewCard extends StatefulWidget {
  final Alumno alumno;
  final VoidCallback onTap;

  const AlumnViewCard({
    Key? key,
    required this.alumno,
    required this.onTap,
  }) : super(key: key);

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

class TeacherViewCard extends StatefulWidget {
  final Alumno alumno;
  final Icon icono;
  final VoidCallback onTap;
  final VoidCallback onEstadisticasTap;

  const TeacherViewCard({
    Key? key,
    required this.alumno,
    required this.onTap,
    required this.icono,
    required this.onEstadisticasTap,
  }) : super(key: key);

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
            IconButton(icon: widget.icono, onPressed: widget.onTap),
            IconButton(icon: const Icon(Icons.bar_chart), onPressed: widget.onEstadisticasTap),
          ],
        ),
        onTap: null,
      ),
    );
  }
}
'''